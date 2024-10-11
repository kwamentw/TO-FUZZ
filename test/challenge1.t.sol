// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {Registry} from "../src/challenge1.sol";

contract challenge1test is Test{
    Registry reg;

    function setUp() public {
        reg = new Registry();
        deal(address(0xabc),type(uint256).max);
    }

    function testRegister() public {
        vm.prank(address(0xabc));
        reg.register{value: 1e18}();

        assertTrue(reg.isRegistered(address(0xabc)));
    }

    function testRevertRegister() public {
        vm.prank(address(0xabc));
        vm.expectRevert();
        reg.register{value:0.2e18}();

        assertFalse(reg.isRegistered(address(0xabc)));
    }

    function testFeeOverSent() public {
        vm.prank(address(0xabc));

        console2.log("Balance one: ",address(0xabc).balance);

        reg.register{value:12e18}();

        console2.log("Balance two: ",address(0xabc).balance);

        assertTrue(reg.isRegistered(address(0xabc)));
    }

    function testFuzzRegister(uint256 amount) public {
        vm.assume(amount > 1e18 && amount < type(uint128).max);

        uint256 bal1 = address(0xabc).balance;

        vm.prank(address(0xabc));
        reg.register{value: amount}();

        uint256 bal2 = address(0xabc).balance;

        assertTrue(reg.isRegistered(address(0xabc)));
        assertEq(bal1-bal2, 1 ether);
        assertEq(address(reg).balance, 1 ether);

    }
}