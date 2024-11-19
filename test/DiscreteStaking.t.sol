// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {DiscreteStakingRewards} from "../src/DiscreteStaking.sol";
import {IERC20} from "../src/DiscreteStaking.sol";

contract DisStakingTest is Test{
    DiscreteStakingRewards disStaking;

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    uint256 private mainnetFork;

    function setUp() public {
        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
        disStaking = new DiscreteStakingRewards(DAI,USDC);
    }

    function testMainnetFork() public {
        vm.selectFork(mainnetFork);
        assertEq(mainnetFork,vm.activeFork());
    }

    function testDiscreteStake() public {
        deal(DAI, address(this), 30e18, true);
        IERC20(DAI).approve(address(disStaking),25e18);

        uint256 balBefStake = IERC20(DAI).balanceOf(address(this));
        disStaking.stake(25e18);
        uint256 balAftStake = IERC20(DAI).balanceOf(address(this));

        console2.log("Amount staked: ",disStaking.balanceOf(address(this)));
        assertEq(25e18,disStaking.balanceOf(address(this)));
        assertEq(disStaking.totalSupply(),25e18);
        assertEq(balBefStake - balAftStake, 25e18);
    }

    function testDiscreteUnstake() public {
        deal(DAI, address(this), 25e18, true);
        IERC20(DAI).approve(address(disStaking), 25e18);
        
        disStaking.stake(25e18);
        console2.log("Amount staked: ", disStaking.balanceOf(address(this)));

        console2.log("--------------Unstaking-------------");

        uint256 balBefUnstake = IERC20(DAI).balanceOf(address(this));
        disStaking.unstake(25e18);
        uint256 balAftUnstake = IERC20(DAI).balanceOf(address(this));

        console2.log("Amount staked: ", disStaking.balanceOf(address(this)));

        assertEq(disStaking.balanceOf(address(this)),0);
        assertEq(disStaking.totalSupply(),0);
        assertEq(balAftUnstake-balBefUnstake,25e18);
    }

    function testUpdateRewardIndeX() public{
        deal(DAI, address(this), 30e18, true);
        IERC20(DAI).approve(address(disStaking),25e18);
        disStaking.stake(25e18);
        console2.log("Amount staked: ",disStaking.balanceOf(address(this)));

        deal(USDC, address(this), 30e18, true);
        IERC20(USDC).approve(address(disStaking),25e18);
        disStaking.updateRewardIndex(10e3);

        assertGt(disStaking.rewardIndex(),0);
    }

    function testClaim() public {
        deal(DAI, address(this), 30e18, true);
        IERC20(DAI).approve(address(disStaking),25e18);
        disStaking.stake(25e18);
        console2.log("-------------staked------------- ");

        deal(USDC, address(this), 30e18, true);
        IERC20(USDC).approve(address(disStaking),25e18);
        disStaking.updateRewardIndex(10e6);
        
        uint256 balanceBef = IERC20(USDC).balanceOf(address(this));
        uint256 reward = disStaking.claim();
        uint256 balanceAfter = IERC20(USDC).balanceOf(address(this));
        
        assertGt(reward,0);
        assertGt(balanceAfter,balanceBef);
        assertEq(balanceAfter - balanceBef, reward);

        console2.log("Reward is: ", reward);
        console2.log("Final Balance: ", balanceAfter);
    }

}