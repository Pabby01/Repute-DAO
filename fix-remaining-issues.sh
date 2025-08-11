#!/bin/bash

echo "Fixing remaining build issues..."

# Add idl-build feature to Cargo.toml
if ! grep -q "idl-build" programs/repute_dao/Cargo.toml; then
  sed -i '/\[features\]/a idl-build = ["anchor-lang/idl-build", "anchor-spl/idl-build"]' programs/repute_dao/Cargo.toml
fi

# Optimize the code to reduce stack usage
# 1. Modify the apply_decay function to use fewer stack variables
sed -i 's/let decay_factor = (100 - program_state.decay_rate as i64).pow(decay_periods as u32);/let decay_rate = program_state.decay_rate as i64;\n        let decay_factor = (100 - decay_rate).pow(decay_periods as u32);/g' programs/repute_dao/src/lib.rs

# 2. Optimize the get_user_role function to use less stack space
sed -i 's/let mut current_role = String::from("Member");/let mut current_role = "Member".to_string();/g' programs/repute_dao/src/lib.rs

# 3. Add #[inline] to helper functions to encourage inlining
sed -i 's/fn calculate_vote_power/#[inline]\nfn calculate_vote_power/g' programs/repute_dao/src/lib.rs
sed -i 's/fn apply_decay/#[inline]\nfn apply_decay/g' programs/repute_dao/src/lib.rs

echo "All fixes applied. Now run 'anchor build' again."