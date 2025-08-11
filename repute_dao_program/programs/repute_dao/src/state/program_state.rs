
use anchor_lang::prelude::*;

#[account]
pub struct ProgramState {
	pub admin: Pubkey,
	pub token_mint: Pubkey,
	pub cooldown_period: u64,
	pub role_count: u8,
}
