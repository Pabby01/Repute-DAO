
pub mod constants;
pub mod error;
pub mod instructions;
pub mod state;

use anchor_lang::prelude::*;
use std::str::FromStr;

pub use constants::*;
pub use instructions::*;
pub use state::*;

declare_id!("8bBipPUPVkeaBH2ebzBPDMw88PVjYZfcQhK3ukBq5YB9");

#[program]
pub mod repute_dao {
    use super::*;

/// Initialize the program with the admin, token mint, and cooldown period
///
/// Accounts:
/// 0. `[signer]` admin: [AccountInfo] 
/// 1. `[writable]` program_state: [ProgramState] The program state account
/// 2. `[]` token_mint: [AccountInfo] The SPL token mint used for voting rights
/// 3. `[]` system_program: [AccountInfo] Auto-generated, for account initialization
	pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
		initialize::handler(ctx)
	}

/// Upvote a target wallet to increase their reputation score
///
/// Accounts:
/// 0. `[signer]` voter: [AccountInfo] 
/// 1. `[]` program_state: [ProgramState] The program state account
/// 2. `[writable]` user_score: [UserScore] The target user's score account
/// 3. `[writable]` vote_record: [VoteRecord] The vote record to track cooldowns
/// 4. `[]` voter_token_account: [AccountInfo] The voter's token account to verify holdings
/// 5. `[]` token_program: [AccountInfo] The SPL Token program
/// 6. `[]` system_program: [AccountInfo] Auto-generated, for account initialization
///
/// Data:
/// - target: [Pubkey] The target wallet address to upvote
	pub fn upvote(ctx: Context<Upvote>, target: Pubkey) -> Result<()> {
		upvote::handler(ctx, target)
	}

/// Downvote a target wallet to decrease their reputation score
///
/// Accounts:
/// 0. `[signer]` voter: [AccountInfo] 
/// 1. `[]` program_state: [ProgramState] The program state account
/// 2. `[writable]` user_score: [UserScore] The target user's score account
/// 3. `[writable]` vote_record: [VoteRecord] The vote record to track cooldowns
/// 4. `[]` voter_token_account: [AccountInfo] The voter's token account to verify holdings
/// 5. `[]` token_program: [AccountInfo] The SPL Token program
/// 6. `[]` system_program: [AccountInfo] Auto-generated, for account initialization
///
/// Data:
/// - target: [Pubkey] The target wallet address to downvote
	pub fn downvote(ctx: Context<Downvote>, target: Pubkey) -> Result<()> {
		downvote::handler(ctx, target)
	}

/// Admin-only function to reset all scores to zero
///
/// Accounts:
/// 0. `[signer]` admin: [AccountInfo] 
/// 1. `[]` program_state: [ProgramState] The program state account
/// 2. `[writable]` user_score: [UserScore] The user score account to reset
	pub fn reset_scores(ctx: Context<ResetScores>) -> Result<()> {
		reset_scores::handler(ctx)
	}

/// Admin-only function to configure a role with a name and threshold
///
/// Accounts:
/// 0. `[signer]` admin: [AccountInfo] 
/// 1. `[writable]` program_state: [ProgramState] The program state account
/// 2. `[writable]` role: [Role] The role account to configure
/// 3. `[]` system_program: [AccountInfo] Auto-generated, for account initialization
///
/// Data:
/// - name: [String] Name of the role
/// - threshold: [i64] Score threshold required to unlock this role
/// - index: [u8] Index of the role for ordering
	pub fn configure_role(ctx: Context<ConfigureRole>, name: String, threshold: i64, index: u8) -> Result<()> {
		configure_role::handler(ctx, name, threshold, index)
	}

/// View function to get a user's current role based on score
///
/// Accounts:
/// 0. `[writable, signer]` fee_payer: [AccountInfo] Auto-generated, default fee payer
/// 1. `[]` program_state: [ProgramState] The program state account
/// 2. `[]` user_score: [UserScore] The user's score account
///
/// Data:
/// - user: [Pubkey] The user's wallet address
	pub fn get_user_role(ctx: Context<GetUserRole>, user: Pubkey) -> Result<()> {
		get_user_role::handler(ctx, user)
	}



}
