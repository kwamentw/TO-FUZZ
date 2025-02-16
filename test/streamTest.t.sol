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
    Streaming stream; //Streaimng contract
    address NATIVE_TOKEN = address(0); // Native ETH

    function setUp() public {
        stream = new Streaming();
    }

    /**
     * Helper function to create stream
     */
    function createStreamm() internal returns(uint256){
        address receiver = address(0xabc);
        vm.warp(1 days);
        stream.createStream{value: 200e6}(receiver, 200e6, 10 days, address(0));
    }

    /**
     * Testing create stream to see whether it works
     */
    function testCreateStreamm() public {
        uint256 streamidd = stream.createStream{value: 20e6}(address(0xabc), 20e6, 10 days, address(0));
        address receiver = stream.getStreamInfo(streamidd).receiver;
        assertEq(stream.getStreamInfo(streamidd).sender, address(this));
        assertEq(receiver, address(0xabc));
    }

    /**
     * Test to revert on invalid stream deposits
     */
    function testInvalidStreamDeposit() public {
        vm.expectRevert();
        // uint256 streamidd = stream.createStream{value: 0}(address(0xabc), 20e6, 10 days, address(0));        
       stream.createStream{value: 20e7}(address(0xabc), 20e6, 10 days, address(0));
    }

    /**
     * Test whether stream can be extended
     */
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

    /**
     * Test withdrawal of deposit from stream
     */
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

    /**
     * Test whether stream can be closed
     */
    function testCloseStream() public {
        uint256 id = createStreamm();
        vm.warp(30 days);
        stream.closeStream(id);
        assertFalse(stream.getStreamInfo(id).isOpen);
        assertEq(address(stream).balance, 0);
    }

    /**
     * Test revert on non-authorised user to close stream
     */
    function testUserNotAuthorisedToCloseStream() public {
        uint256 id = createStreamm();
        vm.warp(30 days);
        vm.expectRevert();
        // address 55 is not authorised to close stream so watch it revert
        vm.prank(address(55));
        stream.closeStream(id);
    }

    /**
     * TEst revert on trying to close unended stream
     */
    function testCannotCloseBecauseStreamHasNotEnded() public{
        uint256 id = createStreamm();
        vm.warp(3 days);
        vm.expectRevert();
        // stream will end after 10 days so watch it revert because the timestamp is currently at 3 days
        stream.closeStream(id);
    }

    /**
     * Test to check whether user can pause stream
     */
    function testPauseStream() public{
        stream.pauseStream(true);
        assertTrue(stream.paused());

        vm.expectRevert();
        createStreamm();
    }

    /**
     * Test to cofirm non-authorised user cannot pause stream
     */
    function testRevertOnlyOwnerCanPauseStream() public{
        vm.prank(address(0xabc));
        vm.expectRevert();
        stream.pauseStream(true);
    }

    /**
     * Test to revert when the same pause status is issued
     */
    function testRevertOnSameValueSet() public{
        vm.expectRevert();
        stream.pauseStream(false);
    }

   /**
    * Test to see whether admin can change stream recipient
    */
    function testChangeStreamReceipient() public {
        uint256 id = createStreamm();
        assertEq(stream.getStreamInfo(id).receiver, address(0xabc));

        stream.changeStreamReceipient(id, address(0xcba));
        assertEq(stream.getStreamInfo(id).receiver, address(0xcba));
    }

   /**
    * Test to revert upon trying to change recipient when stream is closed
    */
    function testRevertChangeStreamReceipientWhenStreamIsClosed() public{
        uint256 id= createStreamm();
        vm.warp(20 days);
        stream.closeStream(id);
        vm.expectRevert();
        stream.changeStreamReceipient(id, address(0xcba));
    }

    /**
     * Test to revert when trying to change recipient and stop time is passed
     */
    function testChangeStreamReceiverRevertWhenStopTimeisPassed() public{
        uint256 id = createStreamm();
        vm.warp(45 days);
        vm.expectRevert();
        stream.changeStreamReceipient(id, address(0xcba));
    }

    ////////////// stateless fuzz test //////////////////

    /**
     * Fuzzing amount and days when creating stream
     */
    function testFuzzCreateStream(uint256 amount, uint256 dayss) public {
        deal(address(this), amount);
        vm.assume(amount < 280563249498847729173030557215992282774575367577225170497693195048799241327);
        vm.assume(amount != 0);
        dayss = bound(dayss,1,365);
        uint256 streamidd = stream.createStream{value: amount}(address(0xabc), amount, dayss, address(0));
        address receiver = stream.getStreamInfo(streamidd).receiver;
        assertEq(stream.getStreamInfo(streamidd).sender, address(this));
        assertEq(receiver, address(0xabc));
    }

    /**
     * Fuzzing the new stop time when extending stream stop time
     */
    function testFuzzExtendStream(uint256 newStopTime) public{
        uint256 id = createStreamm();
        newStopTime = bound(newStopTime,1,365);
        newStopTime += stream.getStreamInfo(id).stopTime;
        uint256 oldTime = stream.getStreamInfo(id).stopTime;
        stream.extendStream(id,newStopTime);
        assertEq(stream.getStreamInfo(id).stopTime, newStopTime);
        assertLt(oldTime,stream.getStreamInfo(id).stopTime);
    }

    /**
     * Fuzzing the amount to withdraw from a stream 
     */
    function testFuzzWithdrawStream(uint256 amount) public {
        uint256 id = createStreamm();
        amount = bound(amount,1,200e6);
        vm.prank(address(0xabc));
        stream.withdrawStream(id,amount,address(0));
        uint256 bal = address(0xabc).balance;
        assertGt(bal, 0);
    }


    /**
     * helper function to create a bunch of streams at once
     */
    function batchCreateStreamm() private returns(uint256[4] memory ids) {
    address[4] memory receivers = [address(0xabc), address(0xcba), address(0xbca), address(0xacb)];
    uint256[4] memory deposits = [uint256(12e6),uint256(23454333),uint256(34e12),uint256(3.3333e7)];
    uint256[4] memory durations = [uint256(5 days), uint256(10 days), uint256(7 days), uint256(11 days)];
    address[4] memory tokens = [NATIVE_TOKEN, NATIVE_TOKEN, NATIVE_TOKEN, NATIVE_TOKEN];

    ids = stream.batchCreateStream{value: 34.41e13}(receivers, deposits, durations, tokens);
        
    }

    // /**
    //  * Test to see whether batch create stream works
    //  */
    function testBatchCreateStream() public{
        uint256[4] memory ids = batchCreateStreamm();
        assertNotEq(ids.length, 0);
    }

    /**
     * Test to see whether numerous streams can be extended at once 
     */
    function testBatchExtendStream() public{
        uint256[4] memory id = batchCreateStreamm();
        uint256[4] memory time;
        time[0]= uint256(70 days);
        time[1]=uint256(50 days);
        time[2]=uint256(80 days);
        time[3] = uint256(90 days);

        vm.warp(3);
        stream.batchExtendStream(id,time);
    }

    /**
     * For testing whether authorised users can close stream
     */
    function testBatchCloseStreamm() public{
        uint256[4] memory ids = batchCreateStreamm();
        vm.warp(365 days);
        stream.batchCloseStreamm(ids);

    }

    /**
     * For testing batch change recipient
     */
    function testBatchChangeRecipient() public{
        
         uint256[4] memory ids = batchCreateStreamm();
         address[4] memory receivers = [address(111),address(222),address(333),address(444)];
         stream.batchChangeReceipient(ids, receivers);
    }
}