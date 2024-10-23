// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {StdCheats} from "forge-std/StdCheats.sol";
import {console2} from "forge-std/console2.sol";
import {UniswapV3Swap, IERC20, IWETH} from "../src/v3swap.sol";
import {Test} from "forge-std/Test.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

/**
 * @title Uniswap swap test
 * @author inspired by __
 * @notice testing it in a mainnet fork
 */
contract UniV3SwapTest is StdCheats, Test{
    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);
    IERC20 private usdc = IERC20(USDC);

    //uniswap contract
    UniswapV3Swap private uni;

    //identifiers of the fork
    uint256 private mainnetFork;

    function setUp() public {
        //Get RPC_URL from environmental variables
        // Create and select fork
        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});

        // contract initialisation
        uni = new UniswapV3Swap();
    }

    /**
     * Testing whether fork works properly
     */
    function testCanSelectFork() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(),mainnetFork);
    }

}