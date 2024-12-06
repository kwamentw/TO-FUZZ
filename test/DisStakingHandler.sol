// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "./ERC20Mock.sol";
import {DiscreteStakingRewards} from "../src/DiscreteStaking.sol";

contract DisStakingHandler is Test{
    DiscreteStakingRewards disStaking;
    ERC20 stakeToken;
    ERC20 rewardToken;

    constructor(DiscreteStakingRewards _disStaking){
        disStaking = _disStaking;
        stakeToken = new ERC20("STAKE_TOKEN","STKTKN",18,899999);
        rewardToken = new ERC20("REWARD_TOKEN","REWTKN",18,89999);
    }

    //////////// Handler Functions /////////////
    /**
     * Handler for staking
     * @param amount parameter to fuzz i.e amount to stake
     */
    function stake(uint256 amount) public {
        amount = bound(amount,1,100e18);

        stakeToken.mint(address(this),amount);
        stakeToken.approve(address(disStaking), amount);
        
        disStaking.stake(amount);
    }

    /**
     * Hand;er for unstaking
     * @param amount parameter to fuzz i.e amount to unstake
     */
    function unstake(uint256 amount) public {
        amount = bound(amount,1,100e18);
        // then we unstake

        disStaking.unstake(amount);
    }

}