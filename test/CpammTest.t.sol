// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {CPAMM} from "../src/CPAMM.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20, IWETH} from "../src/CPAMM.sol";

contract  CPAMMTest is Test {
    CPAMM public cpamm;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IWETH weth =  IWETH(WETH);
    IERC20 dai =  IERC20(DAI);

    uint256 private mainnetFork;

    function setUp() public {
        cpamm = new CPAMM(DAI,WETH);

        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
    }

    function testSelectFork() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(),mainnetFork);
    }

    function testSwapCPAMM() public{
        weth.deposit{value:20e18}();
        weth.approve(address(cpamm),20e18);

        deal(DAI, address(this), 20e18, true);
        dai.approve(address(cpamm), 20e18);

        uint256 amountOut = cpamm.swap(WETH,19e18);
        assertGt(amountOut,0);
        
    }// i think we have to add liquidity before 
}