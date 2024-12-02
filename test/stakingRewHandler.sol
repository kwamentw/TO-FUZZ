// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {StakingRewards} from "../src/StakingRewards.sol";
import {ERC20} from "./ERC20Mock.sol";


contract StakingRewHandler is Test {
    StakingRewards staking;
    ERC20 stakeToken;
    ERC20 rewToken;

    constructor(StakingRewards _staking)  {
        stakeToken = new ERC20("Stake Token","STKTN",18,900);
        rewToken = new ERC20("Reward Token", "RewTkn", 18, 1000);
        staking = _staking;
    }

    ///////////////////////////////// handler functions ///////////////////////////////////

    function stake(uint256 amountToStake) public {
        amountToStake = bound(amountToStake,10,90e18);

        stakeToken.mint(address(this),amountToStake);
        stakeToken.approve(address(staking),amountToStake);

        staking.stake(amountToStake);
    }

    function withdraw(uint256 amountToWithdraw) public {
        amountToWithdraw = bound(amountToWithdraw,10,90e18);
        staking.withdraw(amountToWithdraw);
    }

    function setRewardsDuration(uint256 duration) public {
        staking.setRewardsDuration(duration);
    } 

}