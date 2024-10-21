//SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {UniswapV3Liquidity} from "../src/V3Liquidity.sol";

contract LiquidityTest is Test {
    UniswapV3Liquidity liqui;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        liqui = new UniswapV3Liquidity();
    }

    function testMintPosition() external {
        // liqui.mintNewPosition();
    }

    function testCollectAllFees() public {

    }

    function testincreaseLiquidityCurrentRange() public {

    }

    function testDecreaseLiquidityCurrentRange() public {}

    
}