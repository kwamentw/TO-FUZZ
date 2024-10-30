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

   //setup
    function setUp() public {
        liqui = new UniswapV3Liquidity();

        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
    }

   // test the fork environment to see if we up
    function testCanSelectForkE() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(),mainnetFork);
    }

    /**
     * Testing to see whether deposit Dai is working
     */
    function testDepositDai() public {
        address figo = address(0xabc);
        deal(address(dai), figo, 10e18,true);
        uint256 balaAfter = dai.balanceOf(figo);
        assertEq(balaAfter,10e18);
    }

    function mintNewPosition() public returns(uint256 tokenId){
         weth.deposit{value: 50e18}();
        weth.approve(address(liqui),50e18);

        deal(address(dai), address(this), 50e18, true);
        dai.approve(address(liqui),50e18);

        ( tokenId,,,)=liqui.mintNewPosition(50e18,50e18);
    }

    /**
     * Minting a new position(Test)
     */
    function testMintNewPosition() public {
        weth.deposit{value: 10e18}();
        weth.approve(address(liqui),10e18);

        deal(address(dai), address(this), 100e18, true);
        dai.approve(address(liqui),100e18);

        (uint256 tokenId,uint128 liquidity, uint256 amount0, uint256 amount1)=liqui.mintNewPosition(1e18,1e18);

        assertGt(amount0,0);
        assertGt(amount1,0);
        assertGt(liquidity,0);


        vm.stopPrank();
    }

    /**
     * Collect all fees from an existing position(Test)
     */
    function testCollectAllFees() public {
        uint256 tokenId = mintNewPosition();

        (uint256 amount0, uint256 amount1)=liqui.collectAllFees(tokenId);

        // it is a newly opened position, I dont't think there will be any fees to take

        assertEq(amount0,0);
        assertEq(amount1,0);
    }

    /**
     * Testing increase liquidity
     */
    function testIncreaseLiquidity() public {
        uint256 tokenId = mintNewPosition();

        weth.deposit{value: 30e18}();
        weth.approve(address(liqui),15e18);

        deal(address(dai), address(this), 30e18);
        bool okay = dai.approve(address(liqui),15e18);
        require(okay,"approve failed");

        (uint128 liquidity, uint256 amount0, uint256 amount1)=liqui.increaseLiquidityCurrentRange(tokenId,15e18,15e18);

        assertGt(liquidity,0);
        assertGt(amount0,0);
        assertGt(amount1,0);
    }

    /**
     * Testing decrease liquidity
     * we create, increase then decrease.
     */
    function testDecreaseLiquidity() public {
        // creating a position
        uint256 tokenId = mintNewPosition();

        // weth deposit & approval
        weth.deposit{value: 15e18}();
        weth.approve(address(liqui),15e18);

        //dai deposit & approval
        deal(address(dai),address(this),15e18);
        bool okay = dai.approve(address(liqui),15e18);
        require(okay);

        (,uint256 amountA,uint256 amountB)=liqui.increaseLiquidityCurrentRange(tokenId,15e18,15e18);
        (uint256 amount0, uint256 amount1)= liqui.decreaseLiquidityCurrentRange(tokenId,1.93e17);

        //assertions 
        assertLt(amount0,amountA);
        assertLt(amount1,amountB);

    }

}