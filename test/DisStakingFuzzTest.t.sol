// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {DiscreteStakingRewards} from "../src/DiscreteStaking.sol";
import {DisStakingHandler} from "./DisStakingHandler.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {ERC20} from "./ERC20Mock.sol";

contract FuzzDiscreteStaking is Test{
    DiscreteStakingRewards disStaking;
    DisStakingHandler handler;
    ERC20 stakeToken;
    ERC20 rewardToken;

    function setUp() public {
        rewardToken  = new ERC20("REWARD_TOKEN","REWTKN",18,90000);
        stakeToken  = new ERC20("STAKE_TOKEN","STKTKN",18,89000);
        disStaking = new DiscreteStakingRewards(address(stakeToken),address(rewardToken));
        handler = new DisStakingHandler(disStaking);
        targetContract(address(handler));

        stakeToken.mint(address(handler),900e18);
    }

    //// Stateless-fuzz tests //// 

    /**
     * Fuzzing the stake function
     * @param amount amount of stake to fuzz
     */
    function testFuzzDisStake(uint256 amount) public{
        amount = bound(amount,1,900e18);
        stakeToken.mint(address(this),amount);
        stakeToken.approve(address(disStaking), amount);

        disStaking.stake(amount);
    }

    /**
     * Fuzzing the unstake function
     * @param amount amount of unstake to fuzz within bound deposited
     */
    function testFuzzDisUnstake(uint256 amount) public {
        amount = bound(amount,1,100e18);
        stakeToken.mint(address(this), 100e18);
        stakeToken.approve(address(disStaking), 100e18);
        disStaking.stake(100e18);

        disStaking.unstake(amount);
    }
}