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
    // mock token
    ERC20 token;
    // staking contract to test
    StakingRewards staking;
    // test Handler
    StakingRewHandler stHandler;

    function setUp() public {

    }

    ///////////////////////// stateless fuzz //////////////////////////
    /**
     * Fuzz amount To stake
     */
    function testFuzzStake() public {}
    /**
     * Fuzz amount To withdraw from staked balance 
     */
    function testFuzzWithdraw() public {}
    /**
     * FUzz duration in reward duration setter function
     */
    function testFuzzSetRewDuration() public {}
    /**
     * Fuzz notifyReward Amount
     */
    function testFuzzNotifyRewAmount() public {}


    ///////////////////////// stateful fuzz ///////////////////////////

}
