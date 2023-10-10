program aleostaking.aleo;

struct StakingInfo:
    user as address;
    daily_reward as u32;
    acc_token_per_share as u32;
    last_reward_block as u32;
    total_staked as u32;

record UserData:
    owner as address.private;
    staked_amount as u32.private;

struct UserStakeInfo:
    user as address;
    amount as u32;
    reward_debt as u32;


mapping stake_info:
	key as address.public;
	value as StakingInfo.public;


mapping user_info:
	key as address.public;
	value as UserStakeInfo.public;

function update_stake_data:
    input r0 as u32.public;
    input r1 as u32.public;
    assert.eq self.caller aleo1t7enuu9lzhg4caxgtmhl952qclapdp4ctxhh2gj52xj6zsdytggscphfxq;
    async update_stake_data self.caller r0 r1 into r2;    output r2 as aleostaking.aleo/update_stake_data.future;

finalize update_stake_data:
    input r0 as address.public;
    input r1 as u32.public;
    input r2 as u32.public;
    cast r0 r1 0u32 r2 0u32 into r3 as StakingInfo;
    set r3 into stake_info[r0];




function stake:
    input r0 as u32.private;
    gt r0 0u32 into r1;
    assert.eq r1 true;
    cast self.caller r0 into r2 as UserData.record;
    async stake self.caller r0 into r3;    output r2 as UserData.record;
    output r3 as aleostaking.aleo/stake.future;

finalize stake:
    input r0 as address.public;
    input r1 as u32.public;
    get stake_info[aleo1t7enuu9lzhg4caxgtmhl952qclapdp4ctxhh2gj52xj6zsdytggscphfxq] into r2;
    gt block.height r2.last_reward_block into r3;
    gt r2.total_staked 0u32 into r4;
    sub block.height r2.last_reward_block into r5;
    mul r5 1u32 into r6;
    add r2.acc_token_per_share r6 into r7;
    div r7 r2.total_staked into r8;
    add r2.total_staked r1 into r9;
    cast r0 r2.daily_reward r8 block.height r9 into r10 as StakingInfo;
    set r10 into stake_info[aleo1t7enuu9lzhg4caxgtmhl952qclapdp4ctxhh2gj52xj6zsdytggscphfxq];
    get stake_info[aleo1t7enuu9lzhg4caxgtmhl952qclapdp4ctxhh2gj52xj6zsdytggscphfxq] into r11;
    cast r0 0u32 0u32 into r12 as UserStakeInfo;
    get.or_use user_info[r0] r12 into r13;
    is.eq r13.amount 0u32 into r14;
    cast r0 r1 0u32 into r15 as UserStakeInfo;
    set r15 into user_info[r0];
    add r1 r13.amount into r16;
    mul r11.acc_token_per_share r16 into r17;
    cast r0 r16 r17 into r18 as UserStakeInfo;
    set r18 into user_info[r0];
