#!/bin/bash

echo "Fixing all build issues with direct file modifications..."

# Create a completely new lib.rs file with all fixes applied
cat > programs/repute_dao/src/lib.rs << 'EOL'
use anchor_lang::prelude::*;
use anchor_spl::token::{Token, TokenAccount, Mint};

declare_id!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS");

#[program]
pub mod repute_dao {
    use super::*;

    pub fn initialize(
        ctx: Context<Initialize>,
        cooldown_period: u64,
        decay_rate: u8,
        decay_period: u64,
        vote_power_multiplier: u8,
    ) -> Result<()> {
        let program_state = &mut ctx.accounts.program_state;
        program_state.admin = ctx.accounts.admin.key();
        program_state.token_mint = ctx.accounts.token_mint.key();
        program_state.cooldown_period = cooldown_period;
        program_state.role_count = 0;
        
        // Initialize new fields
        program_state.decay_enabled = decay_rate > 0;
        program_state.decay_rate = decay_rate;
        program_state.decay_period = decay_period;
        program_state.last_decay_time = Clock::get()?.unix_timestamp;
        program_state.vote_power_multiplier = vote_power_multiplier;

        Ok(())
    }

    pub fn upvote(ctx: Context<Vote>, target: Pubkey) -> Result<()> {
        // Check if the voter has tokens
        let token_balance = ctx.accounts.voter_token_account.amount;
        if token_balance == 0 {
            return err!(ErrorCode::NoTokens);
        }

        // Check if the cooldown period has passed
        let current_time = Clock::get()?.unix_timestamp;
        let vote_record = &mut ctx.accounts.vote_record;
        
        if vote_record.last_vote_time != 0 {
            let time_since_last_vote = current_time - vote_record.last_vote_time;
            if time_since_last_vote < ctx.accounts.program_state.cooldown_period as i64 {
                return err!(ErrorCode::CooldownActive);
            }
        }

        // Initialize vote record if it's new
        if vote_record.last_vote_time == 0 {
            vote_record.voter = ctx.accounts.voter.key();
            vote_record.target = target;
        }

        // Update the vote record
        vote_record.last_vote_time = current_time;

        // Update the user's score
        let user_score = &mut ctx.accounts.user_score;
        if user_score.user == Pubkey::default() {
            user_score.user = target;
            user_score.score = 0;
            user_score.last_updated = current_time;
        }
        
        // Apply decay if enabled
        if ctx.accounts.program_state.decay_enabled {
            apply_decay(user_score, &ctx.accounts.program_state, current_time)?;
        }
        
        // Calculate vote power based on token balance
        let vote_power = calculate_vote_power(
            token_balance, 
            ctx.accounts.program_state.vote_power_multiplier
        );
        
        // Increment the score with weighted voting
        user_score.score = user_score.score.checked_add(vote_power).unwrap_or(i64::MAX);
        user_score.last_updated = current_time;

        Ok(())
    }

    pub fn downvote(ctx: Context<Vote>, target: Pubkey) -> Result<()> {
        // Check if the voter has tokens
        let token_balance = ctx.accounts.voter_token_account.amount;
        if token_balance == 0 {
            return err!(ErrorCode::NoTokens);
        }

        // Check if the cooldown period has passed
        let current_time = Clock::get()?.unix_timestamp;
        let vote_record = &mut ctx.accounts.vote_record;
        
        if vote_record.last_vote_time != 0 {
            let time_since_last_vote = current_time - vote_record.last_vote_time;
            if time_since_last_vote < ctx.accounts.program_state.cooldown_period as i64 {
                return err!(ErrorCode::CooldownActive);
            }
        }

        // Initialize vote record if it's new
        if vote_record.last_vote_time == 0 {
            vote_record.voter = ctx.accounts.voter.key();
            vote_record.target = target;
        }

        // Update the vote record
        vote_record.last_vote_time = current_time;

        // Update the user's score
        let user_score = &mut ctx.accounts.user_score;
        if user_score.user == Pubkey::default() {
            user_score.user = target;
            user_score.score = 0;
            user_score.last_updated = current_time;
        }
        
        // Apply decay if enabled
        if ctx.accounts.program_state.decay_enabled {
            apply_decay(user_score, &ctx.accounts.program_state, current_time)?;
        }
        
        // Calculate vote power based on token balance
        let vote_power = calculate_vote_power(
            token_balance, 
            ctx.accounts.program_state.vote_power_multiplier
        );
        
        // Decrement the score with weighted voting
        user_score.score = user_score.score.checked_sub(vote_power).unwrap_or(i64::MIN);
        user_score.last_updated = current_time;

        Ok(())
    }

    pub fn batch_vote(
        ctx: Context<BatchVote>,
        targets: Vec<Pubkey>,
        is_upvote: bool,
    ) -> Result<()> {
        // Check if the voter has tokens
        let token_balance = ctx.accounts.voter_token_account.amount;
        if token_balance == 0 {
            return err!(ErrorCode::NoTokens);
        }
        
        // Check if targets list is valid
        if targets.is_empty() || targets.len() > 10 {
            return err!(ErrorCode::InvalidInput);
        }
        
        // Calculate vote power based on token balance
        let vote_power = calculate_vote_power(
            token_balance, 
            ctx.accounts.program_state.vote_power_multiplier
        );
        
        // Get current time
        let current_time = Clock::get()?.unix_timestamp;
        
        // Process each target
        for (i, target) in targets.iter().enumerate() {
            // Find the user score PDA for this target
            let user_score_seeds = &[b"user-score".as_ref(), target.as_ref()];
            let (user_score_address, _) = Pubkey::find_program_address(user_score_seeds, ctx.program_id);
            
            // Find the vote record PDA for this voter and target
            let voter_key = ctx.accounts.voter.key();
            let vote_record_seeds = &[
                b"vote-record".as_ref(), 
                voter_key.as_ref(), 
                target.as_ref()
            ];
            let (vote_record_address, _) = Pubkey::find_program_address(vote_record_seeds, ctx.program_id);
            
            // Check if we have the correct remaining accounts
            if i * 2 + 1 >= ctx.remaining_accounts.len() {
                return err!(ErrorCode::InvalidInput);
            }
            
            let user_score_account = &ctx.remaining_accounts[i * 2];
            let vote_record_account = &ctx.remaining_accounts[i * 2 + 1];
            
            // Verify the accounts match the expected PDAs
            if user_score_account.key() != user_score_address || 
               vote_record_account.key() != vote_record_address {
                return err!(ErrorCode::InvalidInput);
            }
            
            // Deserialize and process the accounts
            let mut user_score = UserScore::try_from_slice(&user_score_account.data.borrow())?;
            let mut vote_record = VoteRecord::try_from_slice(&vote_record_account.data.borrow())?;
            
            // Check cooldown
            if vote_record.last_vote_time != 0 {
                let time_since_last_vote = current_time - vote_record.last_vote_time;
                if time_since_last_vote < ctx.accounts.program_state.cooldown_period as i64 {
                    continue; // Skip this target if cooldown is active
                }
            }
            
            // Initialize vote record if it's new
            if vote_record.last_vote_time == 0 {
                vote_record.voter = ctx.accounts.voter.key();
                vote_record.target = *target;
            }
            
            // Update the vote record
            vote_record.last_vote_time = current_time;
            
            // Initialize user score if it's new
            if user_score.user == Pubkey::default() {
                user_score.user = *target;
                user_score.score = 0;
                user_score.last_updated = current_time;
            }
            
            // Apply decay if enabled
            if ctx.accounts.program_state.decay_enabled {
                apply_decay(&mut user_score, &ctx.accounts.program_state, current_time)?;
            }
            
            // Update the score based on vote type
            if is_upvote {
                user_score.score = user_score.score.checked_add(vote_power).unwrap_or(i64::MAX);
            } else {
                user_score.score = user_score.score.checked_sub(vote_power).unwrap_or(i64::MIN);
            }
            user_score.last_updated = current_time;
            
            // Save the updated accounts
            user_score.serialize(&mut *user_score_account.data.borrow_mut())?;
            vote_record.serialize(&mut *vote_record_account.data.borrow_mut())?;
        }

        Ok(())
    }

    pub fn reset_scores(ctx: Context<ResetScores>) -> Result<()> {
        // Check if the caller is the admin
        if ctx.accounts.admin.key() != ctx.accounts.program_state.admin {
            return err!(ErrorCode::Unauthorized);
        }

        // Reset the user's score to zero
        ctx.accounts.user_score.score = 0;
        ctx.accounts.user_score.last_updated = Clock::get()?.unix_timestamp;

        Ok(())
    }

    pub fn batch_reset_scores(ctx: Context<BatchResetScores>) -> Result<()> {
        // Check if the caller is the admin
        if ctx.accounts.admin.key() != ctx.accounts.program_state.admin {
            return err!(ErrorCode::Unauthorized);
        }
        
        // Get current time
        let current_time = Clock::get()?.unix_timestamp;
        
        // Process each user score account
        for account in ctx.remaining_accounts.iter() {
            // Verify this is a UserScore account owned by our program
            if account.owner != ctx.program_id {
                continue;
            }
            
            // Try to deserialize as UserScore
            if let Ok(mut user_score) = UserScore::try_from_slice(&account.data.borrow()) {
                // Reset the score
                user_score.score = 0;
                user_score.last_updated = current_time;
                
                // Save the updated account
                user_score.serialize(&mut *account.data.borrow_mut())?;
            }
        }

        Ok(())
    }

    pub fn configure_role(
        ctx: Context<ConfigureRole>,
        name: String,
        threshold: i64,
        index: u8,
    ) -> Result<()> {
        // Check if the caller is the admin
        if ctx.accounts.admin.key() != ctx.accounts.program_state.admin {
            return err!(ErrorCode::Unauthorized);
        }

        // Configure the role
        let role = &mut ctx.accounts.role;
        role.name = name.clone();
        role.threshold = threshold;
        role.index = index;

        // Update role count if needed
        let program_state = &mut ctx.accounts.program_state;
        if index >= program_state.role_count {
            program_state.role_count = index + 1;
        }

        Ok(())
    }

    pub fn update_program_config(
        ctx: Context<UpdateProgramConfig>,
        cooldown_period: Option<u64>,
        decay_rate: Option<u8>,
        decay_period: Option<u64>,
        vote_power_multiplier: Option<u8>,
    ) -> Result<()> {
        // Check if the caller is the admin
        if ctx.accounts.admin.key() != ctx.accounts.program_state.admin {
            return err!(ErrorCode::Unauthorized);
        }
        
        let program_state = &mut ctx.accounts.program_state;
        
        // Update cooldown period if provided
        if let Some(period) = cooldown_period {
            program_state.cooldown_period = period;
        }
        
        // Update decay settings if provided
        if let Some(rate) = decay_rate {
            program_state.decay_rate = rate;
            program_state.decay_enabled = rate > 0;
        }
        
        if let Some(period) = decay_period {
            program_state.decay_period = period;
        }
        
        // Update vote power multiplier if provided
        if let Some(multiplier) = vote_power_multiplier {
            program_state.vote_power_multiplier = multiplier;
        }
        
        Ok(())
    }

    pub fn trigger_global_decay(ctx: Context<TriggerGlobalDecay>) -> Result<()> {
        // Check if decay is enabled
        if !ctx.accounts.program_state.decay_enabled {
            return Ok(());
        }
        
        // Get current time
        let current_time = Clock::get()?.unix_timestamp;
        let program_state = &mut ctx.accounts.program_state;
        
        // Check if it's time for decay
        let time_since_last_decay = current_time - program_state.last_decay_time;
        if time_since_last_decay < program_state.decay_period as i64 {
            return err!(ErrorCode::DecayNotDue);
        }
        
        // Update the last decay time
        program_state.last_decay_time = current_time;
        
        // Process each user score account
        for account in ctx.remaining_accounts.iter() {
            // Verify this is a UserScore account owned by our program
            if account.owner != ctx.program_id {
                continue;
            }
            
            // Try to deserialize as UserScore
            if let Ok(mut user_score) = UserScore::try_from_slice(&account.data.borrow()) {
                // Apply decay
                apply_decay(&mut user_score, program_state, current_time)?;
                
                // Save the updated account
                user_score.serialize(&mut *account.data.borrow_mut())?;
            }
        }
        
        Ok(())
    }

    pub fn get_user_role<'info>(
        ctx: Context<'_, '_, '_, 'info, GetUserRole<'info>>,
        _user: Pubkey,
    ) -> Result<String> {
        let user_score = &ctx.accounts.user_score;
        
        // Default role if no roles are configured or score is too low
        let mut current_role = String::from("Member");
        let mut highest_threshold = i64::MIN;

        // Iterate through all roles to find the highest threshold that the user meets
        for i in 0..ctx.accounts.program_state.role_count {
            // Find the role account for this index
            let role_seeds = &[b"role".as_ref(), &[i, 0, 0, 0]];
            let (role_address, _) = Pubkey::find_program_address(role_seeds, ctx.program_id);
            
            // Try to find the role account in the remaining accounts
            for account in ctx.remaining_accounts {
                if account.key() == role_address {
                    // Deserialize the account data
                    let role = Role::try_from_slice(&account.data.borrow())?;
                    
                    // Check if the user meets the threshold and it's higher than current
                    if user_score.score >= role.threshold && role.threshold > highest_threshold {
                        current_role = role.name.clone();
                        highest_threshold = role.threshold;
                    }
                    
                    break;
                }
            }
        }

        Ok(current_role)
    }
}

// Helper function to calculate vote power based on token balance
fn calculate_vote_power(token_balance: u64, multiplier: u8) -> i64 {
    // Base vote power is 1
    let base_vote_power: i64 = 1;
    
    if multiplier == 0 {
        return base_vote_power;
    }
    
    // Calculate additional power based on token balance
    // We use log scale to prevent excessive power from large token holders
    // Formula: base_power + log10(token_balance) * multiplier
    let log_balance = if token_balance > 1 {
        (token_balance as f64).log10() as i64
    } else {
        0
    };
    
    base_vote_power + log_balance * multiplier as i64
}

// Helper function to apply score decay
fn apply_decay(
    user_score: &mut UserScore,
    program_state: &ProgramState,
    current_time: i64
) -> Result<()> {
    // Skip if decay is disabled or decay rate is 0
    if !program_state.decay_enabled || program_state.decay_rate == 0 {
        return Ok(());
    }
    
    // Calculate time since last update
    let time_since_update = current_time - user_score.last_updated;
    
    // Calculate number of decay periods that have passed
    let decay_periods = time_since_update / program_state.decay_period as i64;
    
    // Apply decay if at least one period has passed
    if decay_periods > 0 {
        // Calculate decay factor (percentage of score to keep)
        let decay_factor = (100 - program_state.decay_rate as i64).pow(decay_periods as u32);
        let decay_divisor = 100_i64.pow(decay_periods as u32);
        
        // Apply decay
        user_score.score = user_score.score * decay_factor / decay_divisor;
    }
    
    Ok(())
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = admin,
        space = 8 + ProgramState::INIT_SPACE,
        seeds = [b"state"],
        bump
    )]
    pub program_state: Account<'info, ProgramState>,
    
    pub token_mint: Account<'info, Mint>,
    
    #[account(mut)]
    pub admin: Signer<'info>,
    
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(target: Pubkey)]
pub struct Vote<'info> {
    #[account(seeds = [b"state"], bump)]
    pub program_state: Account<'info, ProgramState>,
    
    #[account(
        init_if_needed,
        payer = voter,
        space = 8 + UserScore::INIT_SPACE,
        seeds = [b"user-score", target.as_ref()],
        bump
    )]
    pub user_score: Account<'info, UserScore>,
    
    #[account(
        init_if_needed,
        payer = voter,
        space = 8 + VoteRecord::INIT_SPACE,
        seeds = [b"vote-record", voter.key().as_ref(), target.as_ref()],
        bump
    )]
    pub vote_record: Account<'info, VoteRecord>,
    
    #[account(mut)]
    pub voter: Signer<'info>,
    
    #[account(
        constraint = voter_token_account.mint == program_state.token_mint,
        constraint = voter_token_account.owner == voter.key()
    )]
    pub voter_token_account: Account<'info, TokenAccount>,
    
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct BatchVote<'info> {
    #[account(seeds = [b"state"], bump)]
    pub program_state: Account<'info, ProgramState>,
    
    #[account(mut)]
    pub voter: Signer<'info>,
    
    #[account(
        constraint = voter_token_account.mint == program_state.token_mint,
        constraint = voter_token_account.owner == voter.key()
    )]
    pub voter_token_account: Account<'info, TokenAccount>,
    
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct ResetScores<'info> {
    #[account(seeds = [b"state"], bump)]
    pub program_state: Account<'info, ProgramState>,
    
    #[account(mut)]
    pub user_score: Account<'info, UserScore>,
    
    pub admin: Signer<'info>,
}

#[derive(Accounts)]
pub struct BatchResetScores<'info> {
    #[account(seeds = [b"state"], bump)]
    pub program_state: Account<'info, ProgramState>,
    
    pub admin: Signer<'info>,
}

#[derive(Accounts)]
#[instruction(name: String, threshold: i64, index: u8)]
pub struct ConfigureRole<'info> {
    #[account(mut, seeds = [b"state"], bump)]
    pub program_state: Account<'info, ProgramState>,
    
    #[account(
        init_if_needed,
        payer = admin,
        space = 8 + Role::INIT_SPACE,
        seeds = [b"role", &[index, 0, 0, 0]],
        bump
    )]
    pub role: Account<'info, Role>,
    
    #[account(mut)]
    pub admin: Signer<'info>,
    
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct UpdateProgramConfig<'info> {
    #[account(mut, seeds = [b"state"], bump)]
    pub program_state: Account<'info, ProgramState>,
    
    pub admin: Signer<'info>,
}

#[derive(Accounts)]
pub struct TriggerGlobalDecay<'info> {
    #[account(mut, seeds = [b"state"], bump)]
    pub program_state: Account<'info, ProgramState>,
}

#[derive(Accounts)]
#[instruction(user: Pubkey)]
pub struct GetUserRole<'info> {
    #[account(seeds = [b"state"], bump)]
    pub program_state: Account<'info, ProgramState>,
    
    #[account(seeds = [b"user-score", user.as_ref()], bump)]
    pub user_score: Account<'info, UserScore>,
}

#[account]
#[derive(InitSpace)]
pub struct ProgramState {
    pub admin: Pubkey,
    pub token_mint: Pubkey,
    pub cooldown_period: u64,
    pub role_count: u8,
    
    // New fields for advanced features
    pub decay_enabled: bool,
    pub decay_rate: u8,         // Percentage (0-100) of score to decay per period
    pub decay_period: u64,      // Time in seconds between decay calculations
    pub last_decay_time: i64,   // Last time global decay was triggered
    pub vote_power_multiplier: u8, // Multiplier for weighted voting (0 = disabled)
}

#[account]
#[derive(InitSpace)]
pub struct UserScore {
    pub user: Pubkey,
    pub score: i64,
    pub last_updated: i64,      // Timestamp of last score update for decay calculation
}

#[account]
#[derive(InitSpace)]
pub struct VoteRecord {
    pub voter: Pubkey,
    pub target: Pubkey,
    pub last_vote_time: i64,
}

#[account]
#[derive(InitSpace)]
pub struct Role {
    #[max_len(32)]
    pub name: String,
    pub threshold: i64,
    pub index: u8,
}

#[error_code]
pub enum ErrorCode {
    #[msg("User is not authorized to perform this action")]
    Unauthorized,
    
    #[msg("User must wait before voting again")]
    CooldownActive,
    
    #[msg("User doesn't hold the required tokens to vote")]
    NoTokens,
    
    #[msg("Invalid parameters provided")]
    InvalidInput,
    
    #[msg("Decay period has not elapsed yet")]
    DecayNotDue,
}
EOL

# Update Cargo.toml to ensure it has the correct dependencies and features
cat > programs/repute_dao/Cargo.toml << 'EOL'
[package]
name = "repute_dao"
version = "0.1.0"
description = "Reputation Scoreboard for DAOs"
edition = "2021"

[lib]
crate-type = ["cdylib", "lib"]
name = "repute_dao"

[features]
no-entrypoint = []
no-idl = []
no-log-ix-name = []
cpi = ["no-entrypoint"]
default = []
anchor-debug = []
custom-heap = []
custom-panic = []

[dependencies]
anchor-lang = { version = "0.31.1", features = ["init-if-needed"] }
anchor-spl = "0.31.1"
EOL

# Update Anchor.toml to ensure it has the correct toolchain version
if ! grep -q "\[toolchain\]" Anchor.toml; then
  echo -e "\n[toolchain]\nanchor_version = \"0.31.1\"" >> Anchor.toml
else
  sed -i 's/anchor_version = ".*"/anchor_version = "0.31.1"/g' Anchor.toml
fi

# Update package.json to ensure it has the correct dependencies
sed -i 's/"@coral-xyz\/anchor": "\^0.28.0"/"@coral-xyz\/anchor": "^0.31.1"/g' package.json

echo "All fixes applied. Now run:"
echo "1. yarn install"
echo "2. anchor build"