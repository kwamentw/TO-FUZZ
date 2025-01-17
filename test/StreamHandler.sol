// SPDX-License-Identifier:MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Streaming} from "../src/streaming.sol";
import {StreamTest} from "./streamTest.t.sol";

/**
 * @title Stream test handler
 * @author 4b
 * @notice This is a handler for the invariant tests
 */
contract StreamTestHandler is Test{
    Streaming stream; //stream contract
    StreamTest test;
    address receiver = address(0xabc); // address of stream receiver

    constructor(Streaming _stream){
        stream = _stream;
    }

    /**
     * create stream handler
     */
    function createStream(uint256 amount, uint256 duration) public returns(uint256 id_){
        duration = bound(duration,1,365);
        amount = bound(amount, 1, type(uint128).max);
        id_ = stream.createStream{value: amount}(receiver,amount,duration,address(0));
    }

    /**
     * extend stream handler
     */
    function extendStream(uint256 newDate, uint256 ids) public{
        // vm.assume(newDate < type(uint64).max);
        // vm.assume(newDate != 0);
        newDate = bound(newDate,4,type(uint64).max);
        vm.prank(address(test));
        stream.extendStream(ids, newDate);
    }

    /**
     * withdraw from stream handler
     */
    function withdrawStream(uint256 amount) public {
        uint256 ids = stream.nextStreamId();
        if(ids>0){
            ids = ids-1;
        }else{
            revert("No stream added");
        }
        vm.assume(amount<type(uint64).max);
        address receipient = stream.getStreamInfo(ids).receiver;
        vm.prank(receipient);
        stream.withdrawStream(ids, amount, address(0));
    }

}