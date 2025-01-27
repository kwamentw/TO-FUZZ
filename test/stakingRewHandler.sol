// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {StakingRewards} from "../src/StakingRewards.sol";
import {ERC20} from "./ERC20Mock.sol";


/**
 * @title Staking rewards handler
 * @author 4B
 * @notice a  handler for fuzzing the staking contract
 */
contract StakingRewHandler is Test {
    // staking contract
    StakingRewards staking;
    // stake token
    ERC20 stakeToken;
    // reward token
    ERC20 rewToken;

    constructor(StakingRewards _staking)  {
        stakeToken = new ERC20("Stake Token","STKTN",18,900);
        rewToken = new ERC20("Reward Token", "RewTkn", 18, 1000);
        staking = _staking;
    }

    ///////////////////////////////// handler functions ///////////////////////////////////

    /**
     * Setting rewards duration
     * @param duration duration
     */
    function setRewardsDuration(uint256 duration) public {
        duration = bound(duration,1,type(uint256).max);
        staking.setRewardsDuration(duration);
    } 

    /**
     * Staking tokens
     * @param amountToStake amount of tokens
     */
    function stake(uint256 amountToStake) public {
        amountToStake = bound(amountToStake,10,90e18);

        stakeToken.mint(address(this),amountToStake);
        stakeToken.approve(address(staking),amountToStake);

        setRewardsDuration(1 days);

        staking.stake(amountToStake);
    }

    /**
     * withdrawing staked tokens
     * @param amountToWithdraw amount to withdraw
     */
    function withdraw(uint256 amountToWithdraw) public {
        amountToWithdraw = bound(amountToWithdraw,10,90e18);
        staking.withdraw(amountToWithdraw);
    }
}