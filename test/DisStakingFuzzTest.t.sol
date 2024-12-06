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
    }
}