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

    function createStream(uint256 amount, uint256 days) public{
        amount = bound(amount,0,365);
        stream.createStream{value: amount}(receiver,amount,days,address(0));
    }

    function extendStream(uint256 newDate, uint256 ids) public{
        vm.assume(ids < type(uint96).max);
        stream.extendStream(ids, newDate);
    }

    function withdrawStream(uint256 amount) public {
        
    }


}