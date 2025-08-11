use {
	repute_dao::{
			entry,
			ID as PROGRAM_ID,
	},
	solana_sdk::{
		entrypoint::{ProcessInstruction, ProgramResult},
		pubkey::Pubkey,
	},
	anchor_lang::prelude::AccountInfo,
	solana_program_test::*,
};

// Type alias for the entry function pointer used to convert the entry function into a ProcessInstruction function pointer.
pub type ProgramEntry = for<'info> fn(
	program_id: &Pubkey,
	accounts: &'info [AccountInfo<'info>],
	instruction_data: &[u8],
) -> ProgramResult;

// Macro to convert the entry function into a ProcessInstruction function pointer.
#[macro_export]
macro_rules! convert_entry {
	($entry:expr) => {
		// Use unsafe block to perform memory transmutation.
		unsafe { core::mem::transmute::<ProgramEntry, ProcessInstruction>($entry) }
	};
}

pub fn get_program_test() -> ProgramTest {
	let program_test = ProgramTest::new(
		"repute_dao",
		PROGRAM_ID,
		processor!(convert_entry!(entry)),
	);
	program_test
}
	
pub mod repute_dao_ix_interface {

	use {
		solana_sdk::{
			hash::Hash,
			signature::{Keypair, Signer},
			instruction::Instruction,
			pubkey::Pubkey,
			transaction::Transaction,
		},
		repute_dao::{
			ID as PROGRAM_ID,
			accounts as repute_dao_accounts,
			instruction as repute_dao_instruction,
		},
		anchor_lang::{
			prelude::*,
			InstructionData,
		}
	};

	pub fn initialize_ix_setup(
		admin: &Keypair,
		program_state: Pubkey,
		token_mint: Pubkey,
		system_program: Pubkey,
		recent_blockhash: Hash,
	) -> Transaction {
		let accounts = repute_dao_accounts::Initialize {
			admin: admin.pubkey(),
			program_state: program_state,
			token_mint: token_mint,
			system_program: system_program,
		};

		let data = repute_dao_instruction::Initialize;
		let instruction = Instruction::new_with_bytes(PROGRAM_ID, &data.data(), accounts.to_account_metas(None));
		let mut transaction = Transaction::new_with_payer(
			&[instruction], 
			Some(&admin.pubkey()),
		);

		transaction.sign(&[
			&admin,
		], recent_blockhash);

		return transaction;
	}

	pub fn upvote_ix_setup(
		voter: &Keypair,
		program_state: Pubkey,
		user_score: Pubkey,
		vote_record: Pubkey,
		voter_token_account: Pubkey,
		token_program: Pubkey,
		system_program: Pubkey,
		target: Pubkey,
		recent_blockhash: Hash,
	) -> Transaction {
		let accounts = repute_dao_accounts::Upvote {
			voter: voter.pubkey(),
			program_state: program_state,
			user_score: user_score,
			vote_record: vote_record,
			voter_token_account: voter_token_account,
			token_program: token_program,
			system_program: system_program,
		};

		let data = 	repute_dao_instruction::Upvote {
				target,
		};		let instruction = Instruction::new_with_bytes(PROGRAM_ID, &data.data(), accounts.to_account_metas(None));
		let mut transaction = Transaction::new_with_payer(
			&[instruction], 
			Some(&voter.pubkey()),
		);

		transaction.sign(&[
			&voter,
		], recent_blockhash);

		return transaction;
	}

	pub fn downvote_ix_setup(
		voter: &Keypair,
		program_state: Pubkey,
		user_score: Pubkey,
		vote_record: Pubkey,
		voter_token_account: Pubkey,
		token_program: Pubkey,
		system_program: Pubkey,
		target: Pubkey,
		recent_blockhash: Hash,
	) -> Transaction {
		let accounts = repute_dao_accounts::Downvote {
			voter: voter.pubkey(),
			program_state: program_state,
			user_score: user_score,
			vote_record: vote_record,
			voter_token_account: voter_token_account,
			token_program: token_program,
			system_program: system_program,
		};

		let data = 	repute_dao_instruction::Downvote {
				target,
		};		let instruction = Instruction::new_with_bytes(PROGRAM_ID, &data.data(), accounts.to_account_metas(None));
		let mut transaction = Transaction::new_with_payer(
			&[instruction], 
			Some(&voter.pubkey()),
		);

		transaction.sign(&[
			&voter,
		], recent_blockhash);

		return transaction;
	}

	pub fn reset_scores_ix_setup(
		admin: &Keypair,
		program_state: Pubkey,
		user_score: Pubkey,
		recent_blockhash: Hash,
	) -> Transaction {
		let accounts = repute_dao_accounts::ResetScores {
			admin: admin.pubkey(),
			program_state: program_state,
			user_score: user_score,
		};

		let data = repute_dao_instruction::ResetScores;
		let instruction = Instruction::new_with_bytes(PROGRAM_ID, &data.data(), accounts.to_account_metas(None));
		let mut transaction = Transaction::new_with_payer(
			&[instruction], 
			Some(&admin.pubkey()),
		);

		transaction.sign(&[
			&admin,
		], recent_blockhash);

		return transaction;
	}

	pub fn configure_role_ix_setup(
		admin: &Keypair,
		program_state: Pubkey,
		role: Pubkey,
		system_program: Pubkey,
		name: &String,
		threshold: i64,
		index: u8,
		recent_blockhash: Hash,
	) -> Transaction {
		let accounts = repute_dao_accounts::ConfigureRole {
			admin: admin.pubkey(),
			program_state: program_state,
			role: role,
			system_program: system_program,
		};

		let data = 	repute_dao_instruction::ConfigureRole {
				name: name.clone(),
				threshold,
				index,
		};		let instruction = Instruction::new_with_bytes(PROGRAM_ID, &data.data(), accounts.to_account_metas(None));
		let mut transaction = Transaction::new_with_payer(
			&[instruction], 
			Some(&admin.pubkey()),
		);

		transaction.sign(&[
			&admin,
		], recent_blockhash);

		return transaction;
	}

	pub fn get_user_role_ix_setup(
		fee_payer: &Keypair,
		program_state: Pubkey,
		user_score: Pubkey,
		user: Pubkey,
		recent_blockhash: Hash,
	) -> Transaction {
		let accounts = repute_dao_accounts::GetUserRole {
			fee_payer: fee_payer.pubkey(),
			program_state: program_state,
			user_score: user_score,
		};

		let data = 	repute_dao_instruction::GetUserRole {
				user,
		};		let instruction = Instruction::new_with_bytes(PROGRAM_ID, &data.data(), accounts.to_account_metas(None));
		let mut transaction = Transaction::new_with_payer(
			&[instruction], 
			Some(&fee_payer.pubkey()),
		);

		transaction.sign(&[
			&fee_payer,
		], recent_blockhash);

		return transaction;
	}

}
