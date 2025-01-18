// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Streaming} from "../src/streaming.sol";
import {StreamTestHandler} from "../test/StreamHandler.sol";

/**
 * @title Stream Fuzz test
 * @author 4b
 * @notice fuzz test for streaming.sol
 */
contract StreamFuzzTest is Test{
    //contract to test
    Streaming streamm;
    //handler
    StreamTestHandler handler;

    function setUp() public{
        streamm = new Streaming();
        handler = new StreamTestHandler(streamm);

        targetContract(address(handler));

        deal(address(handler),20e25);
    }

    //////////////////////// Stateful fuzz test ///////////////////////////
    /**
     * Number of streams should be equal to current stream id
     */
    function invariant_NextIDShouldGreaterThannoOfStreams() public view{
        assertGt(streamm.nextStreamId() + 1, streamm.totalNoOfStreams());
    }

    /**
     * Current bal should be less than total stream deposited bal
     * It is less than because when tokens are being withdrawed from the stream total deposit does not reduce
     */
    function invariant_currentBalShouldBeLTEStreamBal() public view{
        assertLe(address(streamm).balance, streamm.totalDeposited());
    }

    /**
     * Next streamID should be greater than current stream id
     */
    function invariant_totalNoStreamsShouldEqCurrentStreamId() public view {
        assertEq(streamm.nextStreamId(), streamm.totalNoOfStreams());
    }

    /**
     * Stream contract balance should be greater than 0
     */
    function invariant_totalBalShldGtZero() public view{
        assertGe(address(streamm).balance,0);
    }

    //testing fuzz test handler
    function testHandlerCreateStream() public {
        handler.createStream(101e6, 4 days);
    }

    function testHandlerExtendStreamm() public {
        // vm.warp(1 days);
        uint256 id = handler.createStream(101e6, 4 days);
        handler.extendStream(id,10 days);
    }

    function testHandlerWithdrawStream() public {
        uint256 id = handler.createStream(101e6, 4 days);
        handler.withdrawStream(100e6);

    }
}
