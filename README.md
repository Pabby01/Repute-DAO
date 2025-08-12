# ReputeDAO - Reputation Scoreboard for DAOs

A Solana smart contract for managing reputation scores within DAOs, built with Anchor.

## Features

### Core Features
- **Token-gated voting**: Only users holding the specified token can upvote/downvote
- **Cooldown periods**: Enforces a cooldown window between votes from the same voter to the same target
- **Reputation tracking**: Maintains positive or negative scores for each wallet
- **Role unlocks**: Defines roles that are unlocked at specific score thresholds
- **Admin controls**: Reset scores and configure the system

### Advanced Features
- **Weighted voting**: Vote power scales with token holdings (logarithmic scale)
- **Score decay**: Automatic score reduction over time to ensure scores reflect recent activity
- **Batch operations**: Vote on or reset multiple accounts in a single transaction
- **Configurable parameters**: Adjust cooldown periods, decay rates, and voting power on the fly

## Getting Started

### Prerequisites

- [Solana Tool Suite](https://docs.solana.com/cli/install-solana-cli-tools)
- [Anchor](https://project-serum.github.io/anchor/getting-started/installation.html)
- [Node.js](https://nodejs.org/) (v14 or later)
- [Yarn](https://yarnpkg.com/)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/repute-dao.git
cd repute-dao
```

2. Install dependencies
```bash
yarn install
```

3. Build the program
```bash
anchor build
```

4. Run tests
```bash
anchor test
```

### Fixing TypeScript Issues

If you encounter TypeScript errors related to missing type definitions, run the provided fix script:

```bash
# Make the script executable
chmod +x fix-typescript-issues.sh

# Run the script
./fix-typescript-issues.sh
```

This script will:
1. Create necessary directories
2. Install required type definitions
3. Create placeholder files if needed

After running the script, restart your IDE/editor to ensure it recognizes the changes.

For more detailed information about TypeScript fixes, see [TYPESCRIPT-FIXES.md](TYPESCRIPT-FIXES.md).

## Usage

### Initialize the Program

Initialize the program with an admin address, token mint, and configuration parameters:

```typescript
await program.methods
  .initialize(
    new anchor.BN(cooldownPeriod),
    decayRate,
    new anchor.BN(decayPeriod),
    votePowerMultiplier
  )
  .accounts({
    programState: programStatePda,
    tokenMint: tokenMint,
    admin: admin.publicKey,
    systemProgram: anchor.web3.SystemProgram.programId,
  })
  .signers([admin])
  .rpc();
```

### Configure Roles

Define roles with names and score thresholds:

```typescript
await program.methods
  .configureRole("Curator", new anchor.BN(100), 0)
  .accounts({
    programState: programStatePda,
    role: rolePda,
    admin: admin.publicKey,
    systemProgram: anchor.web3.SystemProgram.programId,
  })
  .signers([admin])
  .rpc();
```

### Upvote a Wallet

Increase a target wallet's reputation score:

```typescript
await program.methods
  .upvote(targetPublicKey)
  .accounts({
    programState: programStatePda,
    userScore: userScorePda,
    voteRecord: voteRecordPda,
    voter: voter.publicKey,
    voterTokenAccount: voterTokenAccount,
    tokenProgram: TOKEN_PROGRAM_ID,
    systemProgram: anchor.web3.SystemProgram.programId,
  })
  .signers([voter])
  .rpc();
```

### Downvote a Wallet

Decrease a target wallet's reputation score:

```typescript
await program.methods
  .downvote(targetPublicKey)
  .accounts({
    programState: programStatePda,
    userScore: userScorePda,
    voteRecord: voteRecordPda,
    voter: voter.publicKey,
    voterTokenAccount: voterTokenAccount,
    tokenProgram: TOKEN_PROGRAM_ID,
    systemProgram: anchor.web3.SystemProgram.programId,
  })
  .signers([voter])
  .rpc();
```

### Batch Vote on Multiple Wallets

Vote on multiple targets in a single transaction:

```typescript
await program.methods
  .batchVote(
    targetPublicKeys,  // Array of target public keys
    isUpvote           // Boolean: true for upvote, false for downvote
  )
  .accounts({
    programState: programStatePda,
    voter: voter.publicKey,
    voterTokenAccount: voterTokenAccount,
    tokenProgram: TOKEN_PROGRAM_ID,
    systemProgram: anchor.web3.SystemProgram.programId,
  })
  .remainingAccounts(remainingAccounts)  // Array of user score and vote record accounts
  .signers([voter])
  .rpc();
```

### Get User Role

Retrieve a user's current role based on their score:

```typescript
const userRole = await program.methods
  .getUserRole(userPublicKey)
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
```

### Reset Scores

Admin-only function to reset a user's score to zero:

```typescript
await program.methods
  .resetScores()
  .accounts({
    programState: programStatePda,
    userScore: userScorePda,
    admin: admin.publicKey,
  })
  .signers([admin])
  .rpc();
```

### Batch Reset Scores

Admin-only function to reset multiple user scores in one transaction:

```typescript
await program.methods
  .batchResetScores()
  .accounts({
    programState: programStatePda,
    admin: admin.publicKey,
  })
  .remainingAccounts(userScoreAccounts)  // Array of user score accounts
  .signers([admin])
  .rpc();
```

### Update Program Configuration

Admin-only function to update program parameters:

```typescript
await program.methods
  .updateProgramConfig(
    new anchor.BN(cooldownPeriod),  // Optional
    decayRate,                      // Optional
    new anchor.BN(decayPeriod),     // Optional
    votePowerMultiplier             // Optional
  )
  .accounts({
    programState: programStatePda,
    admin: admin.publicKey,
  })
  .signers([admin])
  .rpc();
```

### Trigger Global Decay

Trigger score decay for multiple accounts:

```typescript
await program.methods
  .triggerGlobalDecay()
  .accounts({
    programState: programStatePda,
  })
  .remainingAccounts(userScoreAccounts)  // Array of user score accounts
  .rpc();
```

## Advanced Features Explained

### Weighted Voting

Votes are weighted based on the voter's token balance using a logarithmic scale:

```
vote_power = base_power + log10(token_balance) * multiplier
```

This ensures that users with more tokens have more influence, but prevents excessive power from large token holders.

### Score Decay

Scores automatically decay over time to ensure they reflect recent activity:

```
decay_factor = (100 - decay_rate)^(time_elapsed / decay_period)
new_score = old_score * decay_factor
```

The decay rate and period are configurable by the admin.

### Batch Operations

Batch operations allow for efficient processing of multiple accounts in a single transaction:

- **Batch voting**: Vote on up to 10 targets in one transaction
- **Batch score reset**: Reset scores for multiple users efficiently

## Security Considerations

- Only the admin can reset scores or configure the system
- Voting requires token ownership
- Cooldown periods prevent vote spamming
- Weighted voting uses logarithmic scaling to prevent excessive influence
- All user inputs are validated
- Score decay is applied consistently to all accounts

## Troubleshooting

If you encounter TypeScript errors or other issues, see the [TYPESCRIPT-FIXES.md](TYPESCRIPT-FIXES.md) file for detailed troubleshooting steps.

## License

This project is licensed under the MIT License - see the LICENSE file for details.#