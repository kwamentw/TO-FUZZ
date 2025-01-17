// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Streaming} from "../src/streaming.sol";
import {StreamTestHandler} from "../test/StreamHandler.sol";

contract StreamFuzzTest is Test{
    Streaming streamm;
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
    function invariant_noOfStreamsShouldBeEqualToCurrentID() public view{
        assertEq(streamm.nextStreamId() + 1, streamm.totalNoOfStreams());
    }

    /**
     * Current bal should be greater than stream deposited bal
     */
    function invariant_currentBalShouldBeGTEStreamBal() public view{
        assertGe(address(streamm).balance, streamm.totalDeposited());
    }

    /**
     * Next streamID should be greater than current stream id
     */
    function invariant_NextStreamIDShouldGtCurrentStreamId() public view {
        assertGe(streamm.nextStreamId(), streamm.totalNoOfStreams()-1);
    }

    /**
     * Stream contract balance should be greater than 0
     */
    function invariant_totalBalShldGtZero() public view{
        assertLe(address(streamm).balance,0);
    }
}