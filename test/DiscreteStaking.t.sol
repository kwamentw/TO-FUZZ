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
        disStaking.stake(25e18);
        console2.log("Amount staked: ",disStaking.balanceOf(address(this)));
        assertEq(25e18,disStaking.balanceOf(address(this)));
    }

    function testDiscreteUnstake() public {
        deal(DAI, address(this), 25e18, true);
        IERC20(DAI).approve(address(disStaking), 25e18);
        disStaking.stake(25e18);
        console2.log("Amount staked: ", disStaking.balanceOf(address(this)));
        console2.log("--------------Unstaking-------------");
        disStaking.unstake(25e18);
        console2.log("Amount staked: ", disStaking.balanceOf(address(this)));
        assertEq(disStaking.balanceOf(address(this)),0);
    }

}