#!/bin/bash

# Fix Rust issues
echo "Fixing Rust issues..."

# Add mut to payers in Anchor account constraints
echo "Adding mut attribute to payers in Anchor account constraints..."

# Configure Role
sed -i 's/pub admin: Signer<'\''info>,/#[account(mut)]\n\t\tpub admin: Signer<'\''info>,/g' repute_dao_program/programs/repute_dao/src/instructions/configure_role.rs

# Downvote
sed -i 's/pub voter: Signer<'\''info>,/#[account(mut)]\n\t\tpub voter: Signer<'\''info>,/g' repute_dao_program/programs/repute_dao/src/instructions/downvote.rs

# Initialize
sed -i 's/pub admin: Signer<'\''info>,/#[account(mut)]\n\t\tpub admin: Signer<'\''info>,/g' repute_dao_program/programs/repute_dao/src/instructions/initialize.rs

# Upvote
sed -i 's/pub voter: Signer<'\''info>,/#[account(mut)]\n\t\tpub voter: Signer<'\''info>,/g' repute_dao_program/programs/repute_dao/src/instructions/upvote.rs

# Fix get_user_role.rs
echo "Fixing get_user_role.rs..."
cat > repute_dao_program/programs/repute_dao/src/instructions/get_user_role.rs << 'EOL'
use crate::*;
use anchor_lang::prelude::*;
use std::str::FromStr;



	#[derive(Accounts)]
	#[instruction(
		user: Pubkey,
	)]
	pub struct GetUserRole<'info> {
		#[account(
			seeds = [
				b"state",
			],
			bump,
		)]
		pub program_state: Account<'info, ProgramState>,

		#[account(
			seeds = [
				b"user-score",
				user.as_ref(),
			],
			bump,
		)]
		pub user_score: Account<'info, UserScore>,
	}

/// View function to get a user's current role based on score
///
/// Accounts:
/// 1. `[]` program_state: [ProgramState] The program state account
/// 2. `[]` user_score: [UserScore] The user's score account
///
/// Data:
/// - user: [Pubkey] The user's wallet address
pub fn handler(
	ctx: Context<GetUserRole>,
	user: Pubkey,
) -> Result<()> {
    // Implement your business logic here...
	
	Ok(())
}
EOL

echo "All Rust issues fixed!"