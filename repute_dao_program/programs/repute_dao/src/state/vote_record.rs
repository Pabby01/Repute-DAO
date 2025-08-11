
use anchor_lang::prelude::*;

#[account]
pub struct VoteRecord {
	pub voter: Pubkey,
	pub target: Pubkey,
	pub last_vote_time: i64,
}
