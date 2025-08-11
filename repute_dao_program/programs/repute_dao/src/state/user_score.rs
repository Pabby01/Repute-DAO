
use anchor_lang::prelude::*;

#[account]
pub struct UserScore {
	pub user: Pubkey,
	pub score: i64,
}
