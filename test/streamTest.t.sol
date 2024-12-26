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
}