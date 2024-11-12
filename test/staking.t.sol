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

    function testStake() public {
        deal(DAI,address(this),5000e19,true);
        IERC20(DAI).approve(address(staking), 5000e18);

        staking.stake(5000e18);

        uint256 stakeBal = staking.balanceOf(address(this));

        console2.log("You have staked: ",stakeBal);
        assertEq(stakeBal,5000e18);
    }

}