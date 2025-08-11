import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { ReputeDao } from "../target/types/repute_dao";
import { 
  TOKEN_PROGRAM_ID, 
  createMint, 
  createAssociatedTokenAccount,
  mintTo,
  getAssociatedTokenAddress
} from "@solana/spl-token";
import { assert } from "chai";

describe("repute_dao", () => {
  // Configure the client to use the local cluster
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.ReputeDao as Program<ReputeDao>;
  
  // Generate keypairs for our test
  const admin = anchor.web3.Keypair.generate();
  const voter1 = anchor.web3.Keypair.generate();
  const voter2 = anchor.web3.Keypair.generate();
  const target = anchor.web3.Keypair.generate();
  
  // Additional targets for batch operations
  const batchTargets = Array(5).fill(0).map(() => anchor.web3.Keypair.generate());
  
  // Program state PDA
  const [programStatePda] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("state")],
    program.programId
  );
  
  // User score PDA for target
  const [userScorePda] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("user-score"), target.publicKey.toBuffer()],
    program.programId
  );
  
  // User score PDAs for batch targets
  const batchUserScorePdas = batchTargets.map(target => {
    return anchor.web3.PublicKey.findProgramAddressSync(
      [Buffer.from("user-score"), target.publicKey.toBuffer()],
      program.programId
    )[0];
  });
  
  // Vote record PDAs
  const [voteRecord1] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("vote-record"), voter1.publicKey.toBuffer(), target.publicKey.toBuffer()],
    program.programId
  );
  
  const [voteRecord2] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("vote-record"), voter2.publicKey.toBuffer(), target.publicKey.toBuffer()],
    program.programId
  );
  
  // Vote record PDAs for batch operations
  const batchVoteRecordPdas = batchTargets.map(target => {
    return anchor.web3.PublicKey.findProgramAddressSync(
      [Buffer.from("vote-record"), voter1.publicKey.toBuffer(), target.publicKey.toBuffer()],
      program.programId
    )[0];
  });
  
  // Role PDAs
  const [rolePda1] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("role"), Buffer.from([0])],
    program.programId
  );
  
  const [rolePda2] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("role"), Buffer.from([1])],
    program.programId
  );
  
  // Token variables
  let tokenMint: anchor.web3.PublicKey;
  let adminTokenAccount: anchor.web3.PublicKey;
  let voter1TokenAccount: anchor.web3.PublicKey;
  let voter2TokenAccount: anchor.web3.PublicKey;
  let targetTokenAccount: anchor.web3.PublicKey;
  
  // Constants
  const COOLDOWN_PERIOD = 5; // 5 seconds for testing
  const DECAY_RATE = 10; // 10% decay per period
  const DECAY_PERIOD = 10; // 10 seconds between decay calculations
  const VOTE_POWER_MULTIPLIER = 2; // Multiplier for weighted voting
  
  before(async () => {
    // Airdrop SOL to our test accounts
    await provider.connection.requestAirdrop(admin.publicKey, 10 * anchor.web3.LAMPORTS_PER_SOL);
    await provider.connection.requestAirdrop(voter1.publicKey, 10 * anchor.web3.LAMPORTS_PER_SOL);
    await provider.connection.requestAirdrop(voter2.publicKey, 10 * anchor.web3.LAMPORTS_PER_SOL);
    await provider.connection.requestAirdrop(target.publicKey, 10 * anchor.web3.LAMPORTS_PER_SOL);
    
    // Airdrop SOL to batch targets
    for (const target of batchTargets) {
      await provider.connection.requestAirdrop(target.publicKey, 1 * anchor.web3.LAMPORTS_PER_SOL);
    }
    
    // Create token mint
    tokenMint = await createMint(
      provider.connection,
      admin,
      admin.publicKey,
      null,
      0
    );
    
    // Create token accounts
    adminTokenAccount = await createAssociatedTokenAccount(
      provider.connection,
      admin,
      tokenMint,
      admin.publicKey
    );
    
    voter1TokenAccount = await createAssociatedTokenAccount(
      provider.connection,
      voter1,
      tokenMint,
      voter1.publicKey
    );
    
    voter2TokenAccount = await createAssociatedTokenAccount(
      provider.connection,
      voter2,
      tokenMint,
      voter2.publicKey
    );
    
    targetTokenAccount = await createAssociatedTokenAccount(
      provider.connection,
      target,
      tokenMint,
      target.publicKey
    );
    
    // Mint tokens to voters with different amounts to test weighted voting
    await mintTo(
      provider.connection,
      admin,
      tokenMint,
      voter1TokenAccount,
      admin.publicKey,
      100
    );
    
    await mintTo(
      provider.connection,
      admin,
      tokenMint,
      voter2TokenAccount,
      admin.publicKey,
      1000
    );
  });

  it("Initializes the program with advanced features", async () => {
    await program.methods
      .initialize(
        new anchor.BN(COOLDOWN_PERIOD),
        DECAY_RATE,
        new anchor.BN(DECAY_PERIOD),
        VOTE_POWER_MULTIPLIER
      )
      .accounts({
        programState: programStatePda,
        tokenMint: tokenMint,
        admin: admin.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([admin])
      .rpc();
    
    // Verify program state
    const programState = await program.account.programState.fetch(programStatePda);
    assert.equal(programState.admin.toString(), admin.publicKey.toString());
    assert.equal(programState.tokenMint.toString(), tokenMint.toString());
    assert.equal(programState.cooldownPeriod.toString(), COOLDOWN_PERIOD.toString());
    assert.equal(programState.roleCount, 0);
    assert.equal(programState.decayEnabled, true);
    assert.equal(programState.decayRate, DECAY_RATE);
    assert.equal(programState.decayPeriod.toString(), DECAY_PERIOD.toString());
    assert.isAbove(programState.lastDecayTime.toNumber(), 0);
    assert.equal(programState.votePowerMultiplier, VOTE_POWER_MULTIPLIER);
  });

  it("Configures roles", async () => {
    // Configure "Curator" role
    await program.methods
      .configureRole("Curator", new anchor.BN(100), 0)
      .accounts({
        programState: programStatePda,
        role: rolePda1,
        admin: admin.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([admin])
      .rpc();
    
    // Configure "Governor" role
    await program.methods
      .configureRole("Governor", new anchor.BN(500), 1)
      .accounts({
        programState: programStatePda,
        role: rolePda2,
        admin: admin.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([admin])
      .rpc();
    
    // Verify roles
    const role1 = await program.account.role.fetch(rolePda1);
    assert.equal(role1.name, "Curator");
    assert.equal(role1.threshold.toString(), "100");
    assert.equal(role1.index, 0);
    
    const role2 = await program.account.role.fetch(rolePda2);
    assert.equal(role2.name, "Governor");
    assert.equal(role2.threshold.toString(), "500");
    assert.equal(role2.index, 1);
    
    // Verify program state role count
    const programState = await program.account.programState.fetch(programStatePda);
    assert.equal(programState.roleCount, 2);
  });

  it("Upvotes a target wallet with weighted voting", async () => {
    await program.methods
      .upvote(target.publicKey)
      .accounts({
        programState: programStatePda,
        userScore: userScorePda,
        voteRecord: voteRecord1,
        voter: voter1.publicKey,
        voterTokenAccount: voter1TokenAccount,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([voter1])
      .rpc();
    
    // Verify user score - should be higher than 1 due to weighted voting
    const userScore = await program.account.userScore.fetch(userScorePda);
    assert.equal(userScore.user.toString(), target.publicKey.toString());
    assert.isAbove(userScore.score.toNumber(), 1);
    assert.isAbove(userScore.lastUpdated.toNumber(), 0);
    
    // Verify vote record
    const voteRecord = await program.account.voteRecord.fetch(voteRecord1);
    assert.equal(voteRecord.voter.toString(), voter1.publicKey.toString());
    assert.equal(voteRecord.target.toString(), target.publicKey.toString());
    assert.isAbove(voteRecord.lastVoteTime.toNumber(), 0);
    
    // Store the initial score for later comparison
    const initialScore = userScore.score.toNumber();
    console.log(`Initial weighted vote score: ${initialScore}`);
  });

  it("Enforces cooldown period", async () => {
    try {
      await program.methods
        .upvote(target.publicKey)
        .accounts({
          programState: programStatePda,
          userScore: userScorePda,
          voteRecord: voteRecord1,
          voter: voter1.publicKey,
          voterTokenAccount: voter1TokenAccount,
          tokenProgram: TOKEN_PROGRAM_ID,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([voter1])
        .rpc();
      
      assert.fail("Should have thrown an error due to cooldown period");
    } catch (error) {
      assert.include(error.message, "User must wait before voting again");
    }
  });

  it("Allows different voter to upvote with higher weight", async () => {
    // Voter2 has more tokens (1000 vs 100), so should have higher vote power
    await program.methods
      .upvote(target.publicKey)
      .accounts({
        programState: programStatePda,
        userScore: userScorePda,
        voteRecord: voteRecord2,
        voter: voter2.publicKey,
        voterTokenAccount: voter2TokenAccount,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([voter2])
      .rpc();
    
    // Verify user score increased by more than the first vote
    const userScore = await program.account.userScore.fetch(userScorePda);
    const scoreAfterVoter2 = userScore.score.toNumber();
    console.log(`Score after voter2 (with more tokens): ${scoreAfterVoter2}`);
    
    // Get the initial score from the previous test
    const initialScore = (await program.account.userScore.fetch(userScorePda)).score.toNumber() - scoreAfterVoter2;
    
    // Voter2 should have higher vote power due to more tokens
    assert.isAbove(scoreAfterVoter2 - initialScore, initialScore);
  });

  it("Downvotes a target wallet with weighted voting", async () => {
    // Wait for cooldown period to pass
    await new Promise(resolve => setTimeout(resolve, (COOLDOWN_PERIOD + 1) * 1000));
    
    // Get current score before downvote
    const beforeScore = (await program.account.userScore.fetch(userScorePda)).score.toNumber();
    
    await program.methods
      .downvote(target.publicKey)
      .accounts({
        programState: programStatePda,
        userScore: userScorePda,
        voteRecord: voteRecord1,
        voter: voter1.publicKey,
        voterTokenAccount: voter1TokenAccount,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([voter1])
      .rpc();
    
    // Verify user score decreased by the weighted vote amount
    const userScore = await program.account.userScore.fetch(userScorePda);
    const afterScore = userScore.score.toNumber();
    console.log(`Score after downvote: ${afterScore}`);
    
    // The decrease should match the initial upvote amount
    assert.approximately(beforeScore - afterScore, 3, 1); // Allow small variation due to decay
  });

  it("Performs batch voting on multiple targets", async () => {
    // Wait for cooldown period to pass
    await new Promise(resolve => setTimeout(resolve, (COOLDOWN_PERIOD + 1) * 1000));
    
    // Create remaining accounts array for batch vote
    const remainingAccounts = [];
    
    // Initialize user score and vote record accounts for batch targets
    for (let i = 0; i < batchTargets.length; i++) {
      // Initialize user score account
      await program.methods
        .upvote(batchTargets[i].publicKey)
        .accounts({
          programState: programStatePda,
          userScore: batchUserScorePdas[i],
          voteRecord: batchVoteRecordPdas[i],
          voter: voter1.publicKey,
          voterTokenAccount: voter1TokenAccount,
          tokenProgram: TOKEN_PROGRAM_ID,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([voter1])
        .rpc();
      
      // Wait for cooldown period to pass
      await new Promise(resolve => setTimeout(resolve, (COOLDOWN_PERIOD + 1) * 1000));
      
      // Add to remaining accounts for batch operation
      remainingAccounts.push(
        { pubkey: batchUserScorePdas[i], isWritable: true, isSigner: false },
        { pubkey: batchVoteRecordPdas[i], isWritable: true, isSigner: false }
      );
    }
    
    // Perform batch upvote
    await program.methods
      .batchVote(
        batchTargets.map(t => t.publicKey),
        true // isUpvote = true
      )
      .accounts({
        programState: programStatePda,
        voter: voter1.publicKey,
        voterTokenAccount: voter1TokenAccount,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .remainingAccounts(remainingAccounts)
      .signers([voter1])
      .rpc();
    
    // Verify all targets were upvoted
    for (let i = 0; i < batchTargets.length; i++) {
      const userScore = await program.account.userScore.fetch(batchUserScorePdas[i]);
      assert.isAbove(userScore.score.toNumber(), 3); // Initial vote + batch vote with weight
      console.log(`Batch target ${i} score: ${userScore.score.toNumber()}`);
    }
  });

  it("Performs batch downvote on multiple targets", async () => {
    // Wait for cooldown period to pass
    await new Promise(resolve => setTimeout(resolve, (COOLDOWN_PERIOD + 1) * 1000));
    
    // Create remaining accounts array for batch vote
    const remainingAccounts = [];
    
    // Add to remaining accounts for batch operation
    for (let i = 0; i < batchTargets.length; i++) {
      remainingAccounts.push(
        { pubkey: batchUserScorePdas[i], isWritable: true, isSigner: false },
        { pubkey: batchVoteRecordPdas[i], isWritable: true, isSigner: false }
      );
    }
    
    // Get scores before batch downvote
    const beforeScores = [];
    for (let i = 0; i < batchTargets.length; i++) {
      const userScore = await program.account.userScore.fetch(batchUserScorePdas[i]);
      beforeScores.push(userScore.score.toNumber());
    }
    
    // Perform batch downvote
    await program.methods
      .batchVote(
        batchTargets.map(t => t.publicKey),
        false // isUpvote = false
      )
      .accounts({
        programState: programStatePda,
        voter: voter1.publicKey,
        voterTokenAccount: voter1TokenAccount,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .remainingAccounts(remainingAccounts)
      .signers([voter1])
      .rpc();
    
    // Verify all targets were downvoted
    for (let i = 0; i < batchTargets.length; i++) {
      const userScore = await program.account.userScore.fetch(batchUserScorePdas[i]);
      assert.isBelow(userScore.score.toNumber(), beforeScores[i]);
      console.log(`Batch target ${i} score after downvote: ${userScore.score.toNumber()}`);
    }
  });

  it("Tests score decay over time", async () => {
    // Wait for decay period to pass
    await new Promise(resolve => setTimeout(resolve, (DECAY_PERIOD + 1) * 1000));
    
    // Get score before triggering decay
    const beforeScore = (await program.account.userScore.fetch(userScorePda)).score.toNumber();
    
    // Trigger global decay
    await program.methods
      .triggerGlobalDecay()
      .accounts({
        programState: programStatePda,
      })
      .remainingAccounts([
        { pubkey: userScorePda, isWritable: true, isSigner: false },
        ...batchUserScorePdas.map(pda => ({ pubkey: pda, isWritable: true, isSigner: false }))
      ])
      .rpc();
    
    // Verify score has decayed
    const afterScore = (await program.account.userScore.fetch(userScorePda)).score.toNumber();
    console.log(`Score before decay: ${beforeScore}, after decay: ${afterScore}`);
    
    // Score should be lower after decay
    assert.isBelow(afterScore, beforeScore);
    
    // Verify decay percentage is approximately correct (10%)
    const expectedScore = Math.floor(beforeScore * 0.9); // 10% decay
    assert.approximately(afterScore, expectedScore, 1); // Allow small rounding difference
  });

  it("Updates program configuration", async () => {
    // Update program config
    const newCooldownPeriod = 10;
    const newDecayRate = 20;
    const newDecayPeriod = 20;
    const newVotePowerMultiplier = 3;
    
    await program.methods
      .updateProgramConfig(
        new anchor.BN(newCooldownPeriod),
        newDecayRate,
        new anchor.BN(newDecayPeriod),
        newVotePowerMultiplier
      )
      .accounts({
        programState: programStatePda,
        admin: admin.publicKey,
      })
      .signers([admin])
      .rpc();
    
    // Verify updated config
    const programState = await program.account.programState.fetch(programStatePda);
    assert.equal(programState.cooldownPeriod.toString(), newCooldownPeriod.toString());
    assert.equal(programState.decayRate, newDecayRate);
    assert.equal(programState.decayPeriod.toString(), newDecayPeriod.toString());
    assert.equal(programState.votePowerMultiplier, newVotePowerMultiplier);
  });

  it("Performs batch reset of scores", async () => {
    // Get current scores
    const mainScore = (await program.account.userScore.fetch(userScorePda)).score.toNumber();
    const batchScores = [];
    for (let i = 0; i < batchTargets.length; i++) {
      const userScore = await program.account.userScore.fetch(batchUserScorePdas[i]);
      batchScores.push(userScore.score.toNumber());
    }
    
    // Verify we have non-zero scores
    assert.notEqual(mainScore, 0);
    assert.isTrue(batchScores.some(score => score !== 0));
    
    // Perform batch reset
    await program.methods
      .batchResetScores()
      .accounts({
        programState: programStatePda,
        admin: admin.publicKey,
      })
      .remainingAccounts([
        { pubkey: userScorePda, isWritable: true, isSigner: false },
        ...batchUserScorePdas.map(pda => ({ pubkey: pda, isWritable: true, isSigner: false }))
      ])
      .signers([admin])
      .rpc();
    
    // Verify all scores are reset to zero
    const resetMainScore = (await program.account.userScore.fetch(userScorePda)).score.toNumber();
    assert.equal(resetMainScore, 0);
    
    for (let i = 0; i < batchTargets.length; i++) {
      const userScore = await program.account.userScore.fetch(batchUserScorePdas[i]);
      assert.equal(userScore.score.toNumber(), 0);
    }
  });

  it("Gets user role based on score", async () => {
    // Reset the score first
    await program.methods
      .resetScores()
      .accounts({
        programState: programStatePda,
        userScore: userScorePda,
        admin: admin.publicKey,
      })
      .signers([admin])
      .rpc();
    
    // Upvote multiple times to reach Curator role threshold
    for (let i = 0; i < 20; i++) {
      // Wait for cooldown period to pass
      await new Promise(resolve => setTimeout(resolve, 11 * 1000)); // New cooldown is 10 seconds
      
      await program.methods
        .upvote(target.publicKey)
        .accounts({
          programState: programStatePda,
          userScore: userScorePda,
          voteRecord: voteRecord1,
          voter: voter1.publicKey,
          voterTokenAccount: voter1TokenAccount,
          tokenProgram: TOKEN_PROGRAM_ID,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([voter1])
        .rpc();
    }
    
    // Verify user score is now above 100 (Curator threshold)
    const userScore = await program.account.userScore.fetch(userScorePda);
    console.log(`Final score for role test: ${userScore.score.toNumber()}`);
    assert.isAbove(userScore.score.toNumber(), 100);
    
    // Get user role
    const userRole = await program.methods
      .getUserRole(target.publicKey)
      .accounts({
        programState: programStatePda,
        userScore: userScorePda,
      })
      .remainingAccounts([
        {
          pubkey: rolePda1,
          isWritable: false,
          isSigner: false,
        },
        {
          pubkey: rolePda2,
          isWritable: false,
          isSigner: false,
        },
      ])
      .view();
    
    assert.equal(userRole, "Curator");
  });

  it("Non-admin cannot reset scores or update config", async () => {
    try {
      await program.methods
        .resetScores()
        .accounts({
          programState: programStatePda,
          userScore: userScorePda,
          admin: voter1.publicKey,
        })
        .signers([voter1])
        .rpc();
      
      assert.fail("Should have thrown an error due to unauthorized access");
    } catch (error) {
      assert.include(error.message, "User is not authorized to perform this action");
    }
    
    try {
      await program.methods
        .updateProgramConfig(
          new anchor.BN(5),
          5,
          new anchor.BN(5),
          1
        )
        .accounts({
          programState: programStatePda,
          admin: voter1.publicKey,
        })
        .signers([voter1])
        .rpc();
      
      assert.fail("Should have thrown an error due to unauthorized access");
    } catch (error) {
      assert.include(error.message, "User is not authorized to perform this action");
    }
  });
});