use crate::*;
use anchor_lang::prelude::*;
use std::str::FromStr;



	#[derive(Accounts)]
	pub struct Initialize<'info> {
		#[account(mut)]
		pub admin: Signer<'info>,

		#[account(
			init,
			space=81,
			payer=admin,
			seeds = [
				b"state",
			],
			bump,
		)]
		pub program_state: Account<'info, ProgramState>,

		/// CHECK: implement manual checks if needed
		pub token_mint: UncheckedAccount<'info>,

		pub system_program: Program<'info, System>,
	}

/// Initialize the program with the admin, token mint, and cooldown period
///
/// Accounts:
/// 0. `[signer]` admin: [AccountInfo] 
/// 1. `[writable]` program_state: [ProgramState] The program state account
/// 2. `[]` token_mint: [AccountInfo] The SPL token mint used for voting rights
/// 3. `[]` system_program: [AccountInfo] Auto-generated, for account initialization
pub fn handler(
	ctx: Context<Initialize>,
) -> Result<()> {
    // Implement your business logic here...
	
	Ok(())
}