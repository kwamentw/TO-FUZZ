//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {StakingRewards} from  "../src/StakingRewards.sol";
import {IERC20} from "../src/StakingRewards.sol";

/**
 * @title Staking Rewards Test
 * @author 4B 
 * @notice Testing staking rewards contract
 */
contract StakingTest is Test{

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    StakingRewards staking;

    uint256 private mainnetFork;

    function setUp() public {
        staking = new  StakingRewards(DAI,USDC);
        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
    }

    /**
     * Testing Fork
     */
    function testSelectForkS() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(),mainnetFork);
    }

    /**
     * Testing whether owner can stake
     * @param topG owner address
     */
    function stakeOwner(address topG) public {
        deal(DAI,topG,5000e19,true);
        vm.startPrank(topG);
        IERC20(DAI).approve(address(staking), 5000e18);

        staking.setRewardsDuration(block.timestamp + 1 days);

        staking.stake(5000e18);
        vm.stopPrank();
    }

    // Helper functions to stake.
    function stake(address topG) public {
        deal(DAI,topG,5000e19,true);
        vm.startPrank(topG);
        IERC20(DAI).approve(address(staking), 5000e18);

        staking.stake(5000e18);
        vm.stopPrank();
    }

    /**
     * Testing whether other users than the owner can stake
     */
    function testStake() public {
        deal(DAI,address(this),5000e19,true);
        IERC20(DAI).approve(address(staking), 5000e18);

        staking.setRewardsDuration(block.timestamp + 1 days);

        staking.stake(5000e18);

        uint256 stakeBal = staking.balanceOf(address(this));

        console2.log("You have staked: ",stakeBal);
        assertEq(stakeBal,5000e18);
    }

    /**
     * Testing whether stakers can withdraw their stake
     */
    function testWithdraw() public {
        stake(address(this));
        
        uint256 daiBalBefore = IERC20(DAI).balanceOf(address(this));
        staking.withdraw(4500e18);

        uint256 stakeBal = staking.balanceOf(address(this));
        uint256 totalSupply = staking.totalSupply();
        assertEq(stakeBal,500e18);
        assertEq(totalSupply,500e18);
        assertEq(IERC20(DAI).balanceOf(address(this)), daiBalBefore + 4500e18);
        console2.log("Stake amount left: ", stakeBal);
        console2.log("Total supply: ", totalSupply);
    }

    /**
     * Confirms whether the withdrawal on zero actually reverts
     */
    function testWithdrawZero() public {
        stake(address(this));

        vm.expectRevert();
        staking.withdraw(0);
    }

    /**
     * This tests confirm whether user actually accrues rewards
     */
    function testRewards() public{
        vm.warp(2 days);
        stakeOwner(address(this));
        stake(address(0xabc));
        stake(address(4345));

        deal(USDC,address(staking),50e23);

        staking.notifyRewardAmount(500e18);
         vm.warp(block.timestamp + 8 days);
        uint256 reward = staking.rewardPerToken();

        console2.log("Staking reward rate: ",staking.rewardRate());
        assertGt(reward,0);

    }

    /**
     * Tests the whether stakers earn on their stake
     */
    function testEarned() public {
        vm.warp(2 days);
        stakeOwner(address(this));

        deal(USDC,address(staking),50e23);

        staking.notifyRewardAmount(500e18);
        vm.warp(block.timestamp + 4 days);
        uint256 amountEarned = staking.earned(address(this));

        console2.log("Amount earned: ",amountEarned);
        assertGt(amountEarned,0);
    }

    /**
     * Tests to confirm whether user can withdraw his accrued rewards
     */
    function testGetReward() public {
        testRewards();
        uint256 balBefore = IERC20(USDC).balanceOf(address(this));
        staking.getReward();
        uint256 balAfter = IERC20(USDC).balanceOf(address(this));
        assertGt(balAfter, balBefore);
       
    }

    /**
     * Tests whether owner can set rewardsDuration
     */
    function testSetRewardsDuration() public {
        staking.setRewardsDuration(4 days);
        assertEq(staking.duration(), 4 days);
    }

    /**
     * Test to confirm whether function will revert when owners try to set that param
     */
    function testSetRewardsDurationNotOwner() public{
        vm.expectRevert();
        vm.prank(address(0xabc));
        staking.setRewardsDuration(59 days);
    }

    /**
     * Test to check whether NotifyRewardAmount work as intended
     */
    function testNotifyRewardAmount() public {
        vm.warp(3 days);
        stakeOwner(address(this));
        stake(address(45));

        deal(USDC,address(staking),50e23,true);

        staking.notifyRewardAmount(500e18);
        console2.log("Staking will end at: ", staking.finishAt());
        assertEq(staking.updatedAt(), block.timestamp);
        assertGt(staking.finishAt(), staking.updatedAt());
    }

    /**
     * Test to confirm any user other than owner that calls this function reverts
     */
    function testNotOwnerNotifyReward() public {
        stakeOwner(address(this));
        vm.warp(3 days);
        
        vm.expectRevert();
        vm.prank(address(0xabc));
        staking.notifyRewardAmount(500e18);
    }



}