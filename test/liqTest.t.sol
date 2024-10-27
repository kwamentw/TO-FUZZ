//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {IWETH, IERC20} from "../src/V3Liquidity.sol";
import {UniswapV3Liquidity} from "../src/V3Liquidity.sol";

contract LiquidityTest is Test {
    UniswapV3Liquidity liqui;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);

    uint256 private mainnetFork;

    function setUp() public {
        liqui = new UniswapV3Liquidity();

        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
    }

    function testCanSelectForkE() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(),mainnetFork);
    }

    function testDepositDai() public {
        address figo = address(0xabc);
        uint256 balaBefore = dai.balanceOf(figo);
        deal(address(dai), figo, 10e18,true);
        uint256 balaAfter = dai.balanceOf(figo);
        assertEq(balaAfter,10e18);
    }

    function testMintNewPosition() public {
        weth.deposit{value: 10e18}();
        weth.approve(address(liqui),10e18);
        
        deal(address(dai), address(this), 100e18, true);
        dai.approve(address(liqui),100e18);

        (uint256 tokenId,uint128 liquidity, uint256 amount0, uint256 amount1)=liqui.mintNewPosition(1e18,1e18);

        vm.stopPrank();
    }

}