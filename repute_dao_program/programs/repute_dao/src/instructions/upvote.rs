use crate::*;
use anchor_lang::prelude::*;
use std::str::FromStr;



	#[derive(Accounts)]
	#[instruction(
		target: Pubkey,
	)]
	pub struct Upvote<'info> {
		#[account(mut)]
		pub voter: Signer<'info>,

		#[account(
			seeds = [
				b"state",
			],
			bump,
		)]
		pub program_state: Account<'info, ProgramState>,

		#[account(
			init_if_needed,
			space=48,
			payer=voter,
			seeds = [
				b"user-score",
				target.as_ref(),
			],
			bump,
		)]
		pub user_score: Account<'info, UserScore>,

		#[account(
			init_if_needed,
			space=80,
			payer=voter,
			seeds = [
				b"vote-record",
				voter.key().as_ref(),
				target.as_ref(),
			],
			bump,
		)]
		pub vote_record: Account<'info, VoteRecord>,

		/// CHECK: implement manual checks if needed
		pub voter_token_account: UncheckedAccount<'info>,

		pub token_program: Program<'info, Token>,

		pub system_program: Program<'info, System>,
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
pub fn handler(
	ctx: Context<Upvote>,
	target: Pubkey,
) -> Result<()> {
    // Implement your business logic here...
	
	Ok(())
}