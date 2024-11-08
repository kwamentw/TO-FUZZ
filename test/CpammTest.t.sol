// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {CPAMM} from "../src/CPAMM.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20, IWETH} from "../src/CPAMM.sol";

/**
 * @title CPAMM test
 * @author 4b
 * @notice Testing CPAMM the basic way
 */
contract  CPAMMTest is Test {
    CPAMM public cpamm;

    //tokens used 
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IWETH weth =  IWETH(WETH);
    IERC20 dai =  IERC20(DAI);

    uint256 private mainnetFork;

    /**
     * Test setup
     */
    function setUp() public {
        cpamm = new CPAMM(DAI,WETH);

        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
    }

    /**
     * Check whether our fork fires
     */
    function testSelectFork() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(),mainnetFork);
    }

    /**
     * Add liquidity Helper
     */
    function addLiquidityC() public {
        // depositing weth and approving cpamm
        weth.deposit{value: 100e18}();
        weth.approve(address(cpamm),100e18);

        // depositing DAI and approving cpamm to spend
        deal(DAI, address(this), 100e18,true);
        dai.approve(address(cpamm),100e18);

        cpamm.addLiquidity(100e18,100e18);
    }

    /**
     * testing Add liquidity to cpamm
     */
    function testAddLiquidityC() public {
        // depositing weth and approving cpamm
        weth.deposit{value: 20e18}();
        weth.approve(address(cpamm),20e18);

        // depositing DAI and approving cpamm to spend
        deal(DAI, address(this), 20e18, true);
        dai.approve(address(cpamm), 20e18);
        
        uint256 sharesAdded = cpamm.addLiquidity(20e18,20e18);

        assertGt(sharesAdded,0);
        console2.log("Liquidity added: ",sharesAdded);
    }

    //Testing swap in CPAMM
    function testSwapCPAMM() public{
        //add liquidity
        addLiquidityC();

        // Deposit weth and approve cpamm
        weth.deposit{value: 30e18}();
        weth.approve(address(cpamm),30e18);

        // deposit DAI and approve cpamm
        deal(DAI,address(this), 30e18);
        dai.approve(address(cpamm), 30e18);

        uint256 amountOut = cpamm.swap(WETH,19e18);
        assertGt(amountOut,0);
        console2.log("Amount out is : ", amountOut);
        
    }

    // Testing remove liquidity
    function testRemoveLiquidityC() public {
        // making sure there is liquidity to remove
        addLiquidityC();

        // removing liquidity
        (uint256 amount0, uint256 amount1)=cpamm.removeLiquidity(65e18);

        assertEq(amount0, 65e18);
        assertEq(amount1, 65e18);
    }
}