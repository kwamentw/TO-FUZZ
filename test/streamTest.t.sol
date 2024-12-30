// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Streaming} from "../src/streaming.sol";

contract StreamTest is Test{
    Streaming stream;

    function setUp() public {
        stream = new Streaming();
    }

    function createStreamm() internal returns(uint256){
        address receiver = address(0xabc);
        vm.warp(1 days);
        uint256 streamidd = stream.createStream{value: 20e6}(receiver, 20e6, 10 days, address(0));
    }

    function testCreateStreamm() public {
        uint256 streamidd = stream.createStream{value: 20e6}(address(0xabc), 20e6, 10 days, address(0));
        address receiver = stream.getStreamInfo(streamidd).receiver;
        assertEq(stream.getStreamInfo(streamidd).sender, address(this));
        assertEq(receiver, address(0xabc));
    }

    function testInvalidStreamDeposit() public {
        vm.expectRevert();
        // uint256 streamidd = stream.createStream{value: 0}(address(0xabc), 20e6, 10 days, address(0));        
        uint256 streamidd = stream.createStream{value: 20e7}(address(0xabc), 20e6, 10 days, address(0));
    }

    function testExtendStream() public {
        uint256 id = createStreamm();
        uint256 newStopTime = 20 days;
        
        uint256 oldRate = stream.getStreamInfo(id).ratePerSecond;
        stream.extendStream(id, newStopTime);   
        uint256 currentStopTime = stream.getStreamInfo(id).stopTime;
        uint256 newRate = stream.getStreamInfo(id).ratePerSecond;

        assertEq(currentStopTime, newStopTime);
        assertLt(newRate,oldRate);
    }

    function testWithdrawStream() public {
        uint256 id = createStreamm();
        uint256 oldDeposit = stream.getStreamInfo(id).deposit;
        vm.warp(5 days);
        vm.prank(address(0xabc));
        uint256 withdrawn = stream.withdrawStream(id, 10e6, address(0));
        uint256 expectedBal = oldDeposit - withdrawn;

        assertEq(expectedBal,stream.getStreamInfo(id).deposit);
        assertEq(withdrawn, 10e6);
        assertEq(expectedBal, address(stream).balance);
    }

    function testCloseStream() public {
        uint256 id = createStreamm();
        vm.warp(30 days);
        stream.closeStream(id);
        assertFalse(stream.getStreamInfo(id).isOpen);
        assertEq(address(stream).balance, 0);
    }

    function testUserNotAuthorisedToCloseStream() public {
        uint256 id = createStreamm();
        vm.warp(30 days);
        vm.expectRevert();
        // address 55 is not authorised to close stream so watch it revert
        vm.prank(address(55));
        stream.closeStream(id);
    }

    function testCannotCloseBecauseStreamHasNotEnded() public{
        uint256 id = createStreamm();
        vm.warp(3 days);
        vm.expectRevert();
        // stream will end after 10 days so watch it revert because the timestamp is currently at 3 days
        stream.closeStream(id);
    }

    function testPauseStream() public{
        uint256 id = createStreamm();
        stream.pauseStream(true);
        assertTrue(stream.paused());

        vm.expectRevert();
        createStreamm();
    }
}