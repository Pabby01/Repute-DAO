// This file is auto-generated from the CIDL source.
// Editing this file directly is not recommended as it may be overwritten.
//
// Docs: https://docs.codigo.ai/c%C3%B3digo-interface-description-language/specification#errors

use anchor_lang::prelude::*;

#[error_code]
pub enum ReputeDaoError {
	#[msg("User is not authorized to perform this action")]
	Unauthorized,
	#[msg("User must wait before voting again")]
	CooldownActive,
	#[msg("User doesn't hold the required tokens to vote")]
	NoTokens,
	#[msg("Invalid parameters provided")]
	InvalidInput,
}
