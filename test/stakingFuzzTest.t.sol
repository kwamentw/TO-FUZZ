// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {StakingRewards} from "../src/StakingRewards.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {ERC20} from "./ERC20Mock.sol";
import {StakingRewHandler} from "./stakingRewHandler.sol";

/**
 * @title Staking Rewards Test
 * @author 4B
 * @notice Fuzz testing the staking contract
 */

contract TestStaking is Test{
    // mock reward token
    ERC20 rewToken;
    // mock staking token
    ERC20 stakeToken;
    // staking contract to test
    StakingRewards staking;
    // test Handler
    StakingRewHandler stHandler;

    function setUp() public {
        rewToken = new ERC20("reward token","RWDTKN",18,8000);
        stakeToken = new ERC20("staking token","STKTKN",18,8000);
        staking = new StakingRewards(address(stakeToken), address(rewToken));
        stHandler = new StakingRewHandler(staking);
        targetContract(address(stHandler));

        stakeToken.mint(address(stHandler),200e18);
        staking.setRewardsDuration(12);

    }

    ///////////////////////// stateless fuzz //////////////////////////
    /**
     * Fuzz amount To stake
     */
    function testFuzzStake(uint256 amountToStake) public {
        amountToStake = bound(amountToStake,1,9000e18);

        stakeToken.mint(address(this), amountToStake);
        stakeToken.approve(address(staking), amountToStake);

        staking.stake(amountToStake);
    }
    /**
     * Fuzz amount To withdraw from staked balance 
     */
    function testFuzzStWithdraw(uint256 amountToWithdraw) public {
        amountToWithdraw = bound(amountToWithdraw, 1, 5000e18);

        stakeToken.mint(address(this),5000e18);
        stakeToken.approve(address(staking), 5000e18);
        staking.stake(5000e18);

        staking.withdraw(amountToWithdraw);
    }
    /**
     * FUzz duration in reward duration setter function
     */
    function testFuzzSetRewDuration(uint256 duration) public {
        duration = bound(duration, 1, type(uint256).max);

        staking.setRewardsDuration(duration);
    }


    ///////////////////////// stateful fuzz ///////////////////////////

    /////// testing handler stake and withdraw functions before
    function testHanStake() public {
        stHandler.stake(20e18);
    }

    function testHanWithdraw() public {
        stHandler.stake(20e18);

        stHandler.withdraw(20e18);
    }
    //////////////////////////////////////////////////////////////

    ///////////////// invariants //////////////

    function invariant_BalStakedEqualsBalOfStakingContract() public view {
        assertEq(staking.totalSupply(),stakeToken.balanceOf(address(staking)));
    }

    function invariant_RewardsDurationCannotbeZero() public view{
        assertGt(staking.duration(),0);
    }

    function invariant_updateTimeShouldBeGtZero() public view{
        assertGt(staking.updatedAt(),0);
    }

}
