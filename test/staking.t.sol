//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {StakingRewards} from  "../src/StRewards.sol";
import {IERC20} from "../src/StRewards.sol";

contract StakingTest is Test{

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    StakingRewards staking;

    uint256 private mainnetFork;

    function setUp() public {
        staking = new  StakingRewards(DAI,USDC);
        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
    }

    function testSelectForkS() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(),mainnetFork);
    }

    function stakeOwner(address topG) public {
        deal(DAI,topG,5000e19,true);
        vm.startPrank(topG);
        IERC20(DAI).approve(address(staking), 5000e18);

        staking.setRewardsDuration(block.timestamp + 1 days);

        staking.stake(5000e18);
        vm.stopPrank();
    }

        function stake(address topG) public {
        deal(DAI,topG,5000e19,true);
        vm.startPrank(topG);
        IERC20(DAI).approve(address(staking), 5000e18);

        staking.stake(5000e18);
        vm.stopPrank();
    }

    function testStake() public {
        deal(DAI,address(this),5000e19,true);
        IERC20(DAI).approve(address(staking), 5000e18);

        staking.setRewardsDuration(block.timestamp + 1 days);

        staking.stake(5000e18);

        uint256 stakeBal = staking.balanceOf(address(this));

        console2.log("You have staked: ",stakeBal);
        assertEq(stakeBal,5000e18);
    }

    function testWithdraw() public {
        stake(address(this));

        staking.withdraw(4500e18);

        uint256 stakeBal = staking.balanceOf(address(this));
        uint256 totalSupply = staking.totalSupply();
        assertEq(stakeBal,500e18);
        assertEq(totalSupply,500e18);
        console2.log("Stake amount left: ", stakeBal);
        console2.log("Total supply: ", totalSupply);
    }

    function testRewards() public{
        vm.warp(2 days);
        stakeOwner(address(this));
        stake(address(0xabc));
        stake(address(4345));

        deal(USDC,address(staking),50e23);

        staking.notifyRewardAmount(500e18);
         vm.warp(block.timestamp + 8 days);
        uint256 reward = staking.rewardPerToken();

        console2.log(staking.rewardRate());
        assertGt(reward,0);

    }

}