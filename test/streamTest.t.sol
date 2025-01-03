// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Streaming} from "../src/streaming.sol";

/**
 * @title Stream Test
 * @author 4B
 * @notice This a test unit test of all the functions in stream.sol
 */
contract StreamTest is Test{
    Streaming stream;
    address NATIVE_TOKEN = address(0);
    // address[] public receivers = [address(0xabc), address(0xcba), address(0xbca), address(0xacb)];
    // uint256[] public deposits = [12e6,23454333,34e12,3.3333e7];
    // uint256[] public durations = [5 days, 10 days, 7 days, 11 days];
    // address[] public tokens = [NATIVE_TOKEN, NATIVE_TOKEN, NATIVE_TOKEN, NATIVE_TOKEN];

    function setUp() public {
        stream = new Streaming();
    }

    function createStreamm() internal returns(uint256){
        address receiver = address(0xabc);
        vm.warp(1 days);
        stream.createStream{value: 20e6}(receiver, 20e6, 10 days, address(0));
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
       stream.createStream{value: 20e7}(address(0xabc), 20e6, 10 days, address(0));
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
        stream.pauseStream(true);
        assertTrue(stream.paused());

        vm.expectRevert();
        createStreamm();
    }

    function testRevertOnlyOwnerCanPauseStream() public{
        vm.prank(address(0xabc));
        vm.expectRevert();
        stream.pauseStream(true);
    }

    function testRevertOnSameValueSet() public{
        vm.expectRevert();
        stream.pauseStream(false);
    }

    function testChangeStreamReceipient() public {
        uint256 id = createStreamm();
        assertEq(stream.getStreamInfo(id).receiver, address(0xabc));

        stream.changeStreamReceipient(id, address(0xcba));
        assertEq(stream.getStreamInfo(id).receiver, address(0xcba));
    }

    function testRevertChangeStreamReceipientWhenStreamIsClosed() public{
        uint256 id= createStreamm();
        vm.warp(20 days);
        stream.closeStream(id);
        vm.expectRevert();
        stream.changeStreamReceipient(id, address(0xcba));
    }

    function testChangeStreamReceiverRevertWhenStopTimeisPassed() public{
        uint256 id = createStreamm();
        vm.warp(45 days);
        vm.expectRevert();
        stream.changeStreamReceipient(id, address(0xcba));
    }

    function batchCreateStreamm() private returns(uint256[4] memory ids) {
        // address[] memory receivers;
        // receivers[0] = address(0xabc);
        // receivers[1] = address(0xcba);
        // receivers[2] = address(0xbca);
        // receivers[3] = address(0xacb);

        // uint256[] memory deposits;
        // deposits[0] = 12e6;
        // deposits[1] = 23454333;
        // deposits[2] = 34e12;
        // deposits[3] = 3.3333e7;

        // uint256[] memory durations;
        // durations[0] = 5 days;
        // durations[1] = 10 days;
        // durations[2] = 7 days;
        // durations[3] = 11 days;

        // address[] memory tokens;
        // tokens[0]=NATIVE_TOKEN;
        // tokens[1]=NATIVE_TOKEN;
        // tokens[2]=NATIVE_TOKEN;
        // tokens[3]=NATIVE_TOKEN;

    address[4] memory receivers = [address(0xabc), address(0xcba), address(0xbca), address(0xacb)];
    uint256[4] memory deposits = [uint256(12e6),uint256(23454333),uint256(34e12),uint256(3.3333e7)];
    uint256[4] memory durations = [uint256(5 days), uint256(10 days), uint256(7 days), uint256(11 days)];
    address[4] memory tokens = [NATIVE_TOKEN, NATIVE_TOKEN, NATIVE_TOKEN, NATIVE_TOKEN];

    ids = stream.batchCreateStream{value: 34.41e13}(receivers, deposits, durations, tokens);
        
    }

    function testBatchCreateStream() public{
        uint256[4] memory ids = batchCreateStreamm();
        assertNotEq(ids.length, 0);
    }
}