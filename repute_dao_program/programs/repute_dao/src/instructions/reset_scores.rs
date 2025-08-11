use crate::*;
use anchor_lang::prelude::*;
use std::str::FromStr;



	#[derive(Accounts)]
	pub struct ResetScores<'info> {
		pub admin: Signer<'info>,

		#[account(
			seeds = [
				b"state",
			],
			bump,
		)]
		pub program_state: Account<'info, ProgramState>,

		#[account(
			mut,
		)]
		pub user_score: Account<'info, UserScore>,
	}

/// Admin-only function to reset all scores to zero
///
/// Accounts:
/// 0. `[signer]` admin: [AccountInfo] 
/// 1. `[]` program_state: [ProgramState] The program state account
/// 2. `[writable]` user_score: [UserScore] The user score account to reset
pub fn handler(
	ctx: Context<ResetScores>,
) -> Result<()> {
    // Implement your business logic here...
	
	Ok(())
}
