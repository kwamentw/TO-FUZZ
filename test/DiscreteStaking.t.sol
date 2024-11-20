// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//import statements

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {DiscreteStakingRewards} from "../src/DiscreteStaking.sol";
import {IERC20} from "../src/DiscreteStaking.sol";

/**
 * @title Discrete Staking Test 
 * @author 4b
 * @notice A test script for Discrete staking from solidity-by-example
 */
contract DisStakingTest is Test{
    // main contract to test
    DiscreteStakingRewards disStaking;

    // Reward and staking token respectively
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    uint256 private mainnetFork;

    function setUp() public {
        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
        disStaking = new DiscreteStakingRewards(DAI,USDC);
    }

    /**
     * Testing whether our fork works
     */
    function testMainnetFork() public {
        vm.selectFork(mainnetFork);
        assertEq(mainnetFork,vm.activeFork());
    }

    /**
     * Testing Discrete stake
     */
    function testDiscreteStake() public {
        // funding sender with some DAI(stake tokens)
        deal(DAI, address(this), 30e18, true);
        // approving discrete staking
        IERC20(DAI).approve(address(disStaking),25e18);

        uint256 balBefStake = IERC20(DAI).balanceOf(address(this));
        // staking
        disStaking.stake(25e18);
        uint256 balAftStake = IERC20(DAI).balanceOf(address(this));

        console2.log("Amount staked: ",disStaking.balanceOf(address(this)));
        // confirming whether we staked 25e18
        assertEq(25e18,disStaking.balanceOf(address(this)));
        assertEq(disStaking.totalSupply(),25e18);
        assertEq(balBefStake - balAftStake, 25e18);
    }

    /**
     * Testing whether user can unstake after staking
     */
    function testDiscreteUnstake() public {
        // Funding sender and approving staking contract DAI stake tokens
        deal(DAI, address(this), 25e18, true);
        IERC20(DAI).approve(address(disStaking), 25e18);
        
        // we can't unstake 0, so we have to stake something
        disStaking.stake(25e18);
        console2.log("Amount staked: ", disStaking.balanceOf(address(this)));

        console2.log("--------------Unstaking-------------");

        uint256 balBefUnstake = IERC20(DAI).balanceOf(address(this));
        // unstaking the amount we staked earlier
        disStaking.unstake(25e18);
        uint256 balAftUnstake = IERC20(DAI).balanceOf(address(this));

        console2.log("Amount staked: ", disStaking.balanceOf(address(this)));

        // Testing to see whether unstake executed well
        assertEq(disStaking.balanceOf(address(this)),0);
        assertEq(disStaking.totalSupply(),0);
        assertEq(balAftUnstake-balBefUnstake,25e18);
    }

    /**
     * Testing update Reward Index
     */
    function testUpdateRewardIndeX() public{
        deal(DAI, address(this), 25e18, true);
        IERC20(DAI).approve(address(disStaking),25e18);
        disStaking.stake(25e18);
        console2.log("Amount staked: ",disStaking.balanceOf(address(this)));

        deal(USDC, address(this), 30e18, true);
        IERC20(USDC).approve(address(disStaking),25e18);
        disStaking.updateRewardIndex(10e3);

        assertGt(disStaking.rewardIndex(),0);
    }

    /**
     * Testing claim rewards
     */
    function testClaim() public {
        // FUnd sender, approve staking contract so we can stake some tokens
        deal(DAI, address(this), 30e18, true);
        IERC20(DAI).approve(address(disStaking),25e18);
        disStaking.stake(25e18);
        console2.log("-------------staked------------- ");

        // update the reward index
        deal(USDC, address(this), 30e18, true);
        IERC20(USDC).approve(address(disStaking),25e18);
        disStaking.updateRewardIndex(10e6);
        
        uint256 balanceBef = IERC20(USDC).balanceOf(address(this));
        // claiming rewards
        uint256 reward = disStaking.claim();
        uint256 balanceAfter = IERC20(USDC).balanceOf(address(this));
        
        // COnfirming whether rewards were claimed
        assertGt(reward,0);
        assertGt(balanceAfter,balanceBef);
        assertEq(balanceAfter - balanceBef, reward);

        console2.log("Reward is: ", reward);
        console2.log("Final Balance: ", balanceAfter);
    }

}