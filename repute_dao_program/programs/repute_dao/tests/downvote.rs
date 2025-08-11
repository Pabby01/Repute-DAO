pub mod common;

use std::str::FromStr;
use {
    common::{
		get_program_test,
		repute_dao_ix_interface,
	},
    solana_program_test::tokio,
    solana_sdk::{
        account::Account, pubkey::Pubkey, rent::Rent, signature::Keypair, signer::Signer, system_program,
    },
};


#[tokio::test]
async fn downvote_ix_success() {
	let mut program_test = get_program_test();

	// PROGRAMS
	program_test.prefer_bpf(true);

	program_test.add_program(
		"account_compression",
		Pubkey::from_str("cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK").unwrap(),
		None,
	);

	program_test.add_program(
		"noop",
		Pubkey::from_str("noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV").unwrap(),
		None,
	);

	// DATA
	let target: Pubkey = Pubkey::default();

	// KEYPAIR
	let voter_keypair = Keypair::new();

	// PUBKEY
	let voter_pubkey = voter_keypair.pubkey();
	let voter_token_account_pubkey = Pubkey::new_unique();
	let token_program_pubkey = csl_spl_token_ix_interface::ID;

	// EXECUTABLE PUBKEY
	let system_program_pubkey = Pubkey::from_str("11111111111111111111111111111111").unwrap();

	// PDA
	let (program_state_pda, _program_state_pda_bump) = Pubkey::find_program_address(
		&[
			b"state",
		],
		&repute_dao::ID,
	);

	let (user_score_pda, _user_score_pda_bump) = Pubkey::find_program_address(
		&[
			b"user-score",
			target.as_ref(),
		],
		&repute_dao::ID,
	);

	let (vote_record_pda, _vote_record_pda_bump) = Pubkey::find_program_address(
		&[
			b"vote-record",
			voter_pubkey.as_ref(),
			target.as_ref(),
		],
		&repute_dao::ID,
	);

	// ACCOUNT PROGRAM TEST SETUP
	program_test.add_account(
		voter_pubkey,
		Account {
			lamports: 0,
			data: vec![],
			owner: system_program::ID,
			executable: false,
			rent_epoch: 0,
		},
	);

	// INSTRUCTIONS
	let (mut banks_client, _, recent_blockhash) = program_test.start().await;

	let ix = repute_dao_ix_interface::downvote_ix_setup(
		&voter_keypair,
		program_state_pda,
		user_score_pda,
		vote_record_pda,
		voter_token_account_pubkey,
		token_program_pubkey,
		system_program_pubkey,
		target,
		recent_blockhash,
	);

	let result = banks_client.process_transaction(ix).await;

	// ASSERTIONS
	assert!(result.is_ok());

}
