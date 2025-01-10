// SPDX-License-Identifier:MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Streaming} from "../src/streaming.sol";

contract StreamTestHandler is Test{
    Streaming stream;
    address receiver = address(0xabc);

    constructor(Streaming _stream){
        stream = _stream;
    }

    function createStream(uint256 amount, uint256 duration) public{
        amount = bound(amount,0,365);
        stream.createStream{value: amount}(receiver,amount,duration,address(0));
    }

    function extendStream(uint256 newDate, uint256 ids) public{
        vm.assume(newDate < type(uint64).max);
        stream.extendStream(ids, newDate);
    }

    function withdrawStream(uint256 amount) public {
        uint256 ids;//trye to create streams and bound this test to them
        vm.assume(amount<type(uint64).max);
        stream.withdrawStream(ids, amount, address(0));
    }

    function closeStream(uint256 id) public{
        id = stream.closeStream(id);
    }


}