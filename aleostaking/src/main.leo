// The 'aleostaking' program.
program aleostaking.aleo {

    struct StakingInfo{
        user: address,
        daily_reward: u32,
        acc_token_per_share: u32,
        last_reward_block: u32,
        total_staked: u32
    }

    record UserData {
        owner: address,
        staked_amount: u32,
    }

    struct UserStakeInfo {
        user: address,
        amount: u32,
        reward_debt: u32
    }

    mapping stake_info: address => StakingInfo; 
    mapping user_info: address => UserStakeInfo; 

    transition update_stake_data(public daily_reward: u32, public last_reward_block: u32) {
        assert_eq(self.caller, aleo1t7enuu9lzhg4caxgtmhl952qclapdp4ctxhh2gj52xj6zsdytggscphfxq);

        return then finalize(self.caller, daily_reward, last_reward_block);
    }

    finalize update_stake_data (user: address, daily_reward: u32, last_reward_block: u32) {
        Mapping::set(stake_info,user, StakingInfo {
            user: user,
            daily_reward: daily_reward,
            acc_token_per_share: 0u32,
            last_reward_block: last_reward_block,
            total_staked: 0u32
        });
    }

    transition stake(private amount: u32) -> UserData {
        assert(amount > 0u32);

        return UserData {
            owner: self.caller,
            staked_amount: amount
        } then finalize(self.caller, amount);
    }

    finalize stake(user:address, amount: u32) {
        let manager: address = aleo1t7enuu9lzhg4caxgtmhl952qclapdp4ctxhh2gj52xj6zsdytggscphfxq;
        let stake_result: StakingInfo = Mapping::get(stake_info, manager);

        if block.height > stake_result.last_reward_block {
            if stake_result.total_staked > 0u32 {
                let blocksToReward: u32 = block.height.sub(stake_result.last_reward_block);

                let token_reward: u32 = blocksToReward.mul(get_reward_per_block());

                let acc_token_per_share: u32 = stake_result.acc_token_per_share.add(token_reward).div(stake_result.total_staked);

                Mapping::set(stake_info, manager, StakingInfo {
                    user: user,
                    daily_reward: stake_result.daily_reward,
                    acc_token_per_share: acc_token_per_share,
                    last_reward_block: block.height,
                    total_staked: stake_result.total_staked.add(amount)
                });
            }
        }

        let stake_result_after_update: StakingInfo = Mapping::get(stake_info, manager);

        let zero_data: UserStakeInfo = UserStakeInfo {
            user: user,
            amount: 0u32,
            reward_debt: 0u32 
        };

        let user_result: UserStakeInfo =  Mapping::get_or_use(user_info, user, zero_data);

        if user_result.amount == 0u32 {
            Mapping::set(user_info,user,UserStakeInfo {
                user: user,
                amount: amount,
                reward_debt: 0u32 
            });
        } else {
            let new_amount: u32 = amount + user_result.amount;

            Mapping::set(user_info,user,UserStakeInfo {
                user: user,
                amount: new_amount,
                reward_debt: stake_result_after_update.acc_token_per_share * new_amount 
            });
        }         
    }

    inline get_reward_per_block() -> u32 {
        return 1u32;
    }



    

    // function update_stake_pool(info:StakingInfo) {
    //     // assert(block.height <= StakingInfo.last_reward_block);
    // }

    // finalize update_stake_pool() {
    //      let u :u32 = 1u32;
    // }
}
