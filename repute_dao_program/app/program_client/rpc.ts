import {
  AnchorProvider,
  BN,
  IdlAccounts,
  Program,
  web3,
} from "@coral-xyz/anchor";
import { MethodsBuilder } from "@coral-xyz/anchor/dist/cjs/program/namespace/methods";
import { ReputeDao } from "../../target/types/repute_dao";
import idl from "../../target/idl/repute_dao.json";
import * as pda from "./pda";



let _program: Program<ReputeDao>;


export const initializeClient = (
    programId: web3.PublicKey,
    anchorProvider = AnchorProvider.env(),
) => {
    _program = new Program<ReputeDao>(
        idl as never,
        programId,
        anchorProvider,
    );


};

export type InitializeArgs = {
  admin: web3.PublicKey;
  tokenMint: web3.PublicKey;
  cooldownPeriod: BN;
  decayRate: number;
  decayPeriod: BN;
  votePowerMultiplier: number;
};

/**
 * ### Returns a {@link MethodsBuilder}
 * Initialize the program with the admin, token mint, and cooldown period
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[writable]` program_state: {@link ProgramState} The program state account
 * 2. `[]` token_mint: {@link PublicKey} The SPL token mint used for voting rights
 * 3. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 */
export const initializeBuilder = (
	args: InitializeArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): MethodsBuilder<ReputeDao, never> => {
  const [programStatePubkey] = pda.deriveProgramStatePDA(_program.programId);

  return _program
    .methods
    .initialize(
      args.cooldownPeriod,
      args.decayRate,
      args.decayPeriod,
      args.votePowerMultiplier
    )
    .accountsStrict({
      admin: args.admin,
      programState: programStatePubkey,
      tokenMint: args.tokenMint,
      systemProgram: new web3.PublicKey("11111111111111111111111111111111"),
    })
    .remainingAccounts(remainingAccounts);
};

/**
 * ### Returns a {@link web3.TransactionInstruction}
 * Initialize the program with the admin, token mint, and cooldown period
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[writable]` program_state: {@link ProgramState} The program state account
 * 2. `[]` token_mint: {@link PublicKey} The SPL token mint used for voting rights
 * 3. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 */
export const initialize = (
	args: InitializeArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionInstruction> =>
    initializeBuilder(args, remainingAccounts).instruction();

/**
 * ### Returns a {@link web3.TransactionSignature}
 * Initialize the program with the admin, token mint, and cooldown period
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[writable]` program_state: {@link ProgramState} The program state account
 * 2. `[]` token_mint: {@link PublicKey} The SPL token mint used for voting rights
 * 3. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 */
export const initializeSendAndConfirm = async (
  args: Omit<InitializeArgs, "admin"> & {
    signers: {
      admin: web3.Signer,
    },
  },
  remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionSignature> => {
  const preInstructions: Array<web3.TransactionInstruction> = [];


  return initializeBuilder({
      ...args,
      admin: args.signers.admin.publicKey,
    }, remainingAccounts)
    .preInstructions(preInstructions)
    .signers([args.signers.admin])
    .rpc();
}

export type UpvoteArgs = {
  voter: web3.PublicKey;
  voterTokenAccount: web3.PublicKey;
  tokenProgram: web3.PublicKey;
  target: web3.PublicKey;
};

/**
 * ### Returns a {@link MethodsBuilder}
 * Upvote a target wallet to increase their reputation score
 *
 * Accounts:
 * 0. `[signer]` voter: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The target user's score account
 * 3. `[writable]` vote_record: {@link VoteRecord} The vote record to track cooldowns
 * 4. `[]` voter_token_account: {@link PublicKey} The voter's token account to verify holdings
 * 5. `[]` token_program: {@link PublicKey} The SPL Token program
 * 6. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - target: {@link PublicKey} The target wallet address to upvote
 */
export const upvoteBuilder = (
	args: UpvoteArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): MethodsBuilder<ReputeDao, never> => {
  const [programStatePubkey] = pda.deriveProgramStatePDA(_program.programId);
    const [userScorePubkey] = pda.deriveUserScorePDA({
        user: args.target,
    }, _program.programId);
    const [voteRecordPubkey] = pda.deriveVoteRecordPDA({
        voter: args.voter,
        target: args.target,
    }, _program.programId);

  return _program
    .methods
    .upvote(
      args.target,
    )
    .accountsStrict({
      voter: args.voter,
      programState: programStatePubkey,
      userScore: userScorePubkey,
      voteRecord: voteRecordPubkey,
      voterTokenAccount: args.voterTokenAccount,
      tokenProgram: args.tokenProgram,
      systemProgram: new web3.PublicKey("11111111111111111111111111111111"),
    })
    .remainingAccounts(remainingAccounts);
};

/**
 * ### Returns a {@link web3.TransactionInstruction}
 * Upvote a target wallet to increase their reputation score
 *
 * Accounts:
 * 0. `[signer]` voter: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The target user's score account
 * 3. `[writable]` vote_record: {@link VoteRecord} The vote record to track cooldowns
 * 4. `[]` voter_token_account: {@link PublicKey} The voter's token account to verify holdings
 * 5. `[]` token_program: {@link PublicKey} The SPL Token program
 * 6. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - target: {@link PublicKey} The target wallet address to upvote
 */
export const upvote = (
	args: UpvoteArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionInstruction> =>
    upvoteBuilder(args, remainingAccounts).instruction();

/**
 * ### Returns a {@link web3.TransactionSignature}
 * Upvote a target wallet to increase their reputation score
 *
 * Accounts:
 * 0. `[signer]` voter: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The target user's score account
 * 3. `[writable]` vote_record: {@link VoteRecord} The vote record to track cooldowns
 * 4. `[]` voter_token_account: {@link PublicKey} The voter's token account to verify holdings
 * 5. `[]` token_program: {@link PublicKey} The SPL Token program
 * 6. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - target: {@link PublicKey} The target wallet address to upvote
 */
export const upvoteSendAndConfirm = async (
  args: Omit<UpvoteArgs, "voter"> & {
    signers: {
      voter: web3.Signer,
    },
  },
  remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionSignature> => {
  const preInstructions: Array<web3.TransactionInstruction> = [];


  return upvoteBuilder({
      ...args,
      voter: args.signers.voter.publicKey,
    }, remainingAccounts)
    .preInstructions(preInstructions)
    .signers([args.signers.voter])
    .rpc();
}

export type DownvoteArgs = {
  voter: web3.PublicKey;
  voterTokenAccount: web3.PublicKey;
  tokenProgram: web3.PublicKey;
  target: web3.PublicKey;
};

/**
 * ### Returns a {@link MethodsBuilder}
 * Downvote a target wallet to decrease their reputation score
 *
 * Accounts:
 * 0. `[signer]` voter: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The target user's score account
 * 3. `[writable]` vote_record: {@link VoteRecord} The vote record to track cooldowns
 * 4. `[]` voter_token_account: {@link PublicKey} The voter's token account to verify holdings
 * 5. `[]` token_program: {@link PublicKey} The SPL Token program
 * 6. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - target: {@link PublicKey} The target wallet address to downvote
 */
export const downvoteBuilder = (
	args: DownvoteArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): MethodsBuilder<ReputeDao, never> => {
  const [programStatePubkey] = pda.deriveProgramStatePDA(_program.programId);
    const [userScorePubkey] = pda.deriveUserScorePDA({
        user: args.target,
    }, _program.programId);
    const [voteRecordPubkey] = pda.deriveVoteRecordPDA({
        voter: args.voter,
        target: args.target,
    }, _program.programId);

  return _program
    .methods
    .downvote(
      args.target,
    )
    .accountsStrict({
      voter: args.voter,
      programState: programStatePubkey,
      userScore: userScorePubkey,
      voteRecord: voteRecordPubkey,
      voterTokenAccount: args.voterTokenAccount,
      tokenProgram: args.tokenProgram,
      systemProgram: new web3.PublicKey("11111111111111111111111111111111"),
    })
    .remainingAccounts(remainingAccounts);
};

/**
 * ### Returns a {@link web3.TransactionInstruction}
 * Downvote a target wallet to decrease their reputation score
 *
 * Accounts:
 * 0. `[signer]` voter: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The target user's score account
 * 3. `[writable]` vote_record: {@link VoteRecord} The vote record to track cooldowns
 * 4. `[]` voter_token_account: {@link PublicKey} The voter's token account to verify holdings
 * 5. `[]` token_program: {@link PublicKey} The SPL Token program
 * 6. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - target: {@link PublicKey} The target wallet address to downvote
 */
export const downvote = (
	args: DownvoteArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionInstruction> =>
    downvoteBuilder(args, remainingAccounts).instruction();

/**
 * ### Returns a {@link web3.TransactionSignature}
 * Downvote a target wallet to decrease their reputation score
 *
 * Accounts:
 * 0. `[signer]` voter: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The target user's score account
 * 3. `[writable]` vote_record: {@link VoteRecord} The vote record to track cooldowns
 * 4. `[]` voter_token_account: {@link PublicKey} The voter's token account to verify holdings
 * 5. `[]` token_program: {@link PublicKey} The SPL Token program
 * 6. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - target: {@link PublicKey} The target wallet address to downvote
 */
export const downvoteSendAndConfirm = async (
  args: Omit<DownvoteArgs, "voter"> & {
    signers: {
      voter: web3.Signer,
    },
  },
  remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionSignature> => {
  const preInstructions: Array<web3.TransactionInstruction> = [];


  return downvoteBuilder({
      ...args,
      voter: args.signers.voter.publicKey,
    }, remainingAccounts)
    .preInstructions(preInstructions)
    .signers([args.signers.voter])
    .rpc();
}

export type ResetScoresArgs = {
  admin: web3.PublicKey;
  userScore: web3.PublicKey;
};

/**
 * ### Returns a {@link MethodsBuilder}
 * Admin-only function to reset all scores to zero
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The user score account to reset
 */
export const resetScoresBuilder = (
	args: ResetScoresArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): MethodsBuilder<ReputeDao, never> => {
  const [programStatePubkey] = pda.deriveProgramStatePDA(_program.programId);

  return _program
    .methods
    .resetScores(

    )
    .accountsStrict({
      admin: args.admin,
      programState: programStatePubkey,
      userScore: args.userScore,
    })
    .remainingAccounts(remainingAccounts);
};

/**
 * ### Returns a {@link web3.TransactionInstruction}
 * Admin-only function to reset all scores to zero
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The user score account to reset
 */
export const resetScores = (
	args: ResetScoresArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionInstruction> =>
    resetScoresBuilder(args, remainingAccounts).instruction();

/**
 * ### Returns a {@link web3.TransactionSignature}
 * Admin-only function to reset all scores to zero
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` user_score: {@link UserScore} The user score account to reset
 */
export const resetScoresSendAndConfirm = async (
  args: Omit<ResetScoresArgs, "admin"> & {
    signers: {
      admin: web3.Signer,
    },
  },
  remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionSignature> => {
  const preInstructions: Array<web3.TransactionInstruction> = [];


  return resetScoresBuilder({
      ...args,
      admin: args.signers.admin.publicKey,
    }, remainingAccounts)
    .preInstructions(preInstructions)
    .signers([args.signers.admin])
    .rpc();
}

export type ConfigureRoleArgs = {
  admin: web3.PublicKey;
  name: string;
  threshold: bigint;
  index: number;
};

/**
 * ### Returns a {@link MethodsBuilder}
 * Admin-only function to configure a role with a name and threshold
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[writable]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` role: {@link Role} The role account to configure
 * 3. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - name: {@link string} Name of the role
 * - threshold: {@link BigInt} Score threshold required to unlock this role
 * - index: {@link number} Index of the role for ordering
 */
export const configureRoleBuilder = (
	args: ConfigureRoleArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): MethodsBuilder<ReputeDao, never> => {
  const [programStatePubkey] = pda.deriveProgramStatePDA(_program.programId);
    const [rolePubkey] = pda.deriveRolePDA({
        index: args.index,
    }, _program.programId);

  return _program
    .methods
    .configureRole(
      args.name,
      new BN(args.threshold.toString()),
      args.index,
    )
    .accountsStrict({
      admin: args.admin,
      programState: programStatePubkey,
      role: rolePubkey,
      systemProgram: new web3.PublicKey("11111111111111111111111111111111"),
    })
    .remainingAccounts(remainingAccounts);
};

/**
 * ### Returns a {@link web3.TransactionInstruction}
 * Admin-only function to configure a role with a name and threshold
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[writable]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` role: {@link Role} The role account to configure
 * 3. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - name: {@link string} Name of the role
 * - threshold: {@link BigInt} Score threshold required to unlock this role
 * - index: {@link number} Index of the role for ordering
 */
export const configureRole = (
	args: ConfigureRoleArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionInstruction> =>
    configureRoleBuilder(args, remainingAccounts).instruction();

/**
 * ### Returns a {@link web3.TransactionSignature}
 * Admin-only function to configure a role with a name and threshold
 *
 * Accounts:
 * 0. `[signer]` admin: {@link PublicKey} 
 * 1. `[writable]` program_state: {@link ProgramState} The program state account
 * 2. `[writable]` role: {@link Role} The role account to configure
 * 3. `[]` system_program: {@link PublicKey} Auto-generated, for account initialization
 *
 * Data:
 * - name: {@link string} Name of the role
 * - threshold: {@link BigInt} Score threshold required to unlock this role
 * - index: {@link number} Index of the role for ordering
 */
export const configureRoleSendAndConfirm = async (
  args: Omit<ConfigureRoleArgs, "admin"> & {
    signers: {
      admin: web3.Signer,
    },
  },
  remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionSignature> => {
  const preInstructions: Array<web3.TransactionInstruction> = [];


  return configureRoleBuilder({
      ...args,
      admin: args.signers.admin.publicKey,
    }, remainingAccounts)
    .preInstructions(preInstructions)
    .signers([args.signers.admin])
    .rpc();
}

export type GetUserRoleArgs = {
  user: web3.PublicKey;
};

/**
 * ### Returns a {@link MethodsBuilder}
 * View function to get a user's current role based on score
 *
 * Accounts:
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[]` user_score: {@link UserScore} The user's score account
 *
 * Data:
 * - user: {@link PublicKey} The user's wallet address
 */
export const getUserRoleBuilder = (
	args: GetUserRoleArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): MethodsBuilder<ReputeDao, never> => {
  const [programStatePubkey] = pda.deriveProgramStatePDA(_program.programId);
    const [userScorePubkey] = pda.deriveUserScorePDA({
        user: args.user,
    }, _program.programId);

  return _program
    .methods
    .getUserRole(
      args.user,
    )
    .accountsStrict({
      programState: programStatePubkey,
      userScore: userScorePubkey,
    })
    .remainingAccounts(remainingAccounts);
};

/**
 * ### Returns a {@link web3.TransactionInstruction}
 * View function to get a user's current role based on score
 *
 * Accounts:
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[]` user_score: {@link UserScore} The user's score account
 *
 * Data:
 * - user: {@link PublicKey} The user's wallet address
 */
export const getUserRole = (
	args: GetUserRoleArgs,
	remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionInstruction> =>
    getUserRoleBuilder(args, remainingAccounts).instruction();

/**
 * ### Returns a {@link web3.TransactionSignature}
 * View function to get a user's current role based on score
 *
 * Accounts:
 * 1. `[]` program_state: {@link ProgramState} The program state account
 * 2. `[]` user_score: {@link UserScore} The user's score account
 *
 * Data:
 * - user: {@link PublicKey} The user's wallet address
 */
export const getUserRoleSendAndConfirm = async (
  args: GetUserRoleArgs & {
    signers: {
      feePayer?: web3.Signer,
    },
  },
  remainingAccounts: Array<web3.AccountMeta> = [],
): Promise<web3.TransactionSignature> => {
  const preInstructions: Array<web3.TransactionInstruction> = [];

  const signers = args.signers.feePayer ? [args.signers.feePayer] : [];

  return getUserRoleBuilder(args, remainingAccounts)
    .preInstructions(preInstructions)
    .signers(signers)
    .rpc();
}

// Getters

export const getProgramState = (
    publicKey: web3.PublicKey,
    commitment?: web3.Commitment
): Promise<IdlAccounts<ReputeDao>["programState"]> => _program.account.programState.fetch(publicKey, commitment);

export const getUserScore = (
    publicKey: web3.PublicKey,
    commitment?: web3.Commitment
): Promise<IdlAccounts<ReputeDao>["userScore"]> => _program.account.userScore.fetch(publicKey, commitment);

export const getVoteRecord = (
    publicKey: web3.PublicKey,
    commitment?: web3.Commitment
): Promise<IdlAccounts<ReputeDao>["voteRecord"]> => _program.account.voteRecord.fetch(publicKey, commitment);

export const getRole = (
    publicKey: web3.PublicKey,
    commitment?: web3.Commitment
): Promise<IdlAccounts<ReputeDao>["role"]> => _program.account.role.fetch(publicKey, commitment);