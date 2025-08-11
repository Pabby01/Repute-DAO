#!/bin/bash

echo "Fixing stack size issues..."

# Create a modified version of the apply_decay function with optimized stack usage
cat > /tmp/apply_decay.rs << 'EOL'
// Helper function to apply score decay
#[inline]
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
        let decay_rate = program_state.decay_rate as i64;
        let decay_factor = (100 - decay_rate).pow(decay_periods as u32);
        let decay_divisor = 100_i64.pow(decay_periods as u32);
        
        // Apply decay
        user_score.score = user_score.score * decay_factor / decay_divisor;
    }
    
    Ok(())
}
EOL

# Replace the apply_decay function in lib.rs
sed -i '/\/\/ Helper function to apply score decay/,/^}$/c\\' programs/repute_dao/src/lib.rs
cat /tmp/apply_decay.rs >> programs/repute_dao/src/lib.rs

# Add #[inline] to calculate_vote_power function
sed -i 's/fn calculate_vote_power/#[inline]\nfn calculate_vote_power/g' programs/repute_dao/src/lib.rs

# Optimize string creation
sed -i 's/String::from("Member")/"Member".to_string()/g' programs/repute_dao/src/lib.rs

# Add idl-build feature to Cargo.toml if it doesn't exist
if ! grep -q "idl-build" programs/repute_dao/Cargo.toml; then
  sed -i '/\[features\]/a idl-build = ["anchor-lang/idl-build", "anchor-spl/idl-build"]' programs/repute_dao/Cargo.toml
fi

echo "All fixes applied. Now run 'anchor build' again."