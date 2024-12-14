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

    /**
     * Trying Uniswap single hop swap
     */
    function testSingleHop() public {
        weth.deposit{value:1e18}();
        weth.approve(address(uni),1e18);

        uint256 amountOut = uni.swapExactInputSingleHop(WETH,DAI,3000,1e18);
        uint256 daiBalance = dai.balanceOf(address(this));
        console2.log("DAI is: ",daiBalance);
        assertGt(amountOut,1e18);
        assertEq(amountOut,daiBalance);
    }

    function testSingleHopSwapbackToEth() public {
        // depossit and approve the router
        weth.deposit{value:2e18}();
        weth.approve(address(uni),2e18);

        // swapping to DAI
        uint256 amountOut = uni.swapExactInputSingleHop(WETH,DAI,3000,1e18);
        uint256 daiBalance = dai.balanceOf(address(this));
        console2.log("DAI is: ",daiBalance/1e18); // we divide to get the actual amount in USD

        //swapping back to ETH to see whether we get same amount
        uint256 amountToswapBackinDai = amountOut;
        dai.approve(address(uni),amountToswapBackinDai);
        uint256 amountOut2 = uni.swapExactInputSingleHop(DAI,WETH,3000,amountToswapBackinDai);
        uint256 wethBalance = amountOut2;
        console2.log("return WETH is: ", amountOut2);

        //checking the validity of the swap
        assertGe(amountOut2,9.9e17); // we didnt get exactly 1 ether i'm sure its because of the fee on the swap 
        assertEq(daiBalance,amountOut);
        assertGt(wethBalance,0);
        assertGt(daiBalance,0);
    }

    function testSameTokenSwap() public {
        // deposit and approve router 
        weth.deposit{value: 1e18}();
        weth.approve(address(uni),1e18);

        //swapping to usdc
        uint256 amountOut = uni.swapExactInputSingleHop(WETH,USDC,3000,1e18);
        uint256 usdcBalance = usdc.balanceOf(address(this));
        console2.log("USDC is: ", usdcBalance);

        //swapping from usdc to usdc again | haha wanna see what happens!
        uint256 amountToSwapBack = amountOut;
        usdc.approve(address(uni),amountToSwapBack);
        uint256 amountOut2 = uni.swapExactInputSingleHop(USDC,USDC,3000,1e18);
        console2.log("Second swap USDC is: ", amountOut2);

        assertGt(usdcBalance,0);
        assertEq(amountOut,amountOut2);

        //it ran into an error: `FAIL. Reason: backend: failed while inspecting`
    }

    /**
     * Trying uniswap multi hop swap
     */
    function testMultiHop() public {
        weth.deposit{value: 1e18}();
        weth.approve(address(uni),1e18);

        bytes memory path = abi.encodePacked(WETH, uint24(3000),USDC,uint24(100), DAI);
        uint256 amountOut = uni.swapExactInputMultiHop(path,WETH,1e18);

        console2.log("DAI amount is: ",amountOut);
        assertGt(amountOut,1e18);
    }

    // have to test sqrtlimitpricex96 for jeiwan's appraent funds getting stuck when the limit is met

}