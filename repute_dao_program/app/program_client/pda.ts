import {PublicKey} from "@solana/web3.js";
import {BN} from "@coral-xyz/anchor";

export const deriveProgramStatePDA = (programId: PublicKey): [PublicKey, number] => {
    return PublicKey.findProgramAddressSync(
        [
            Buffer.from("state"),
        ],
        programId,
    )
};

export type UserScoreSeeds = {
    user: PublicKey, 
};

export const deriveUserScorePDA = (
    seeds: UserScoreSeeds,
    programId: PublicKey
): [PublicKey, number] => {
    return PublicKey.findProgramAddressSync(
        [
            Buffer.from("user-score"),
            seeds.user.toBuffer(),
        ],
        programId,
    )
};

export type VoteRecordSeeds = {
    voter: PublicKey, 
    target: PublicKey, 
};

export const deriveVoteRecordPDA = (
    seeds: VoteRecordSeeds,
    programId: PublicKey
): [PublicKey, number] => {
    return PublicKey.findProgramAddressSync(
        [
            Buffer.from("vote-record"),
            seeds.voter.toBuffer(),
            seeds.target.toBuffer(),
        ],
        programId,
    )
};

export type RoleSeeds = {
    index: number, 
};

export const deriveRolePDA = (
    seeds: RoleSeeds,
    programId: PublicKey
): [PublicKey, number] => {
    return PublicKey.findProgramAddressSync(
        [
            Buffer.from("role"),
            Buffer.from([seeds.index]),
        ],
        programId,
    )
};

