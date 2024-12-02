// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {StakingRewards} from "../src/StakingRewards.sol";
import {ERC20} from "./ERC20Mock.sol";


contract StakingRewHandler is Test {
    StakingRewards staking;
    ERC20 staketoken;
    ERC20 rewToken;

    constructor(StakingRewards _staking)  {
        staketoken = new ERC20("Stake Token","STKTN",18,900);
        rewToken = new ERC20("Reward Token", "RewTkn", 18, 1000);
        staking = _staking;
    }

    ///////////////////////////////// funtions ///////////////////////////////////

}