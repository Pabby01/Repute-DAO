
use anchor_lang::prelude::*;

#[account]
pub struct Role {
	pub name: String,
	pub threshold: i64,
	pub index: u8,
}
