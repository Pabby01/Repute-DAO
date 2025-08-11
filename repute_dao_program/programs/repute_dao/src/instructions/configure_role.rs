use crate::*;
use anchor_lang::prelude::*;
use std::str::FromStr;



	#[derive(Accounts)]
	#[instruction(
		name: String,
		threshold: i64,
		index: u8,
	)]
	pub struct ConfigureRole<'info> {
		#[account(mut)]
		pub admin: Signer<'info>,

		#[account(
			mut,
			seeds = [
				b"state",
			],
			bump,
		)]
		pub program_state: Account<'info, ProgramState>,

		#[account(
			init_if_needed,
			space=53,
			payer=admin,
			seeds = [
				b"role",
				index.to_le_bytes().as_ref(),
			],
			bump,
		)]
		pub role: Account<'info, Role>,

		pub system_program: Program<'info, System>,
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
pub fn handler(
	ctx: Context<ConfigureRole>,
	name: String,
	threshold: i64,
	index: u8,
) -> Result<()> {
    // Implement your business logic here...
	
	Ok(())
}