// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {IERC20} from "./interface/IERC20.sol";
import {IWETH} from "./interface/IWETH.sol";


contract Streaming {
    event StreamCreated(uint256 streamID, address creator, address receiver, uint256 duratioN );
    event StreamExtended(uint256 streamID, uint256 newStopTime);
    event StreamWithdrawnFrom(address receipient, uint256 amount, uint256 streamID);
    
    address NATIVE_TOKEN = address(0);

    IWETH immutable weth;

    struct Stream {
        address sender;
        address receiver;
        uint256 deposit;
        uint256 ratePerSecond;
        uint256 startTime;
        uint256 stopTime;
        uint256 withdrawn;
    }
    //TODO i think token address should be added to the stream struct too
    // TODO need to add a variable that tracks whether stream is open or close 

    mapping(uint256 streamId => Stream stream) streamInfo;
    uint256 nextStreamId;

    constructor(address _weth) {
        weth = IWETH(_weth);
    }

    function createStream(address _receiver, uint256 _deposit, uint256 _startTime, uint256 duration, address token) public payable returns(uint256 streaMID){
        require(_receiver != address(0), "invalid address");
        require(_deposit > 0, "zero amount");
        require(duration > 0, "Invalid duration");
        require(_startTime >= block.timestamp, "stream cannot start in the past");
        
        streamInfo[nextStreamId] = Stream({
            sender:msg.sender,
            receiver:_receiver,
            deposit:_deposit,
            ratePerSecond: _deposit / duration,
            startTime: _startTime,
            stopTime: _startTime + duration,
            withdrawn:0
        });

        if (token == NATIVE_TOKEN){
            require(msg.value==_deposit,"invalid deposit");
            weth.deposit{value: _deposit}();
        }else{
            IERC20(token).transferFrom(msg.sender,address(this), _deposit);
        }

        emit StreamCreated(nextStreamId, msg.sender, _receiver, duration);
        nextStreamId++;

        return nextStreamId -1; // returns the current streamID
    }

    function extendStream( uint256 _streamId, uint256 newStopTime) public {
        require(streamInfo[_streamId].stopTime > block.timestamp, "stream has already ended");
        require(streamInfo[_streamId].stopTime < newStopTime, "This is no extension");
        require(streamInfo[_streamId].sender == msg.sender,"Unauthorised");

        Stream memory extStream = streamInfo[_streamId];

        uint256 deposit = extStream.deposit;

        extStream.stopTime = newStopTime;
        extStream.ratePerSecond = deposit/newStopTime;

        streamInfo[_streamId] = extStream;

        emit StreamExtended(_streamId, newStopTime);
    }

    function withdrawStream(uint256 _streamId, uint256 amount, address token) public returns(uint256 amountWithdrawn){
        Stream memory streamTowith = streamInfo[_streamId];
        require(msg.sender == streamTowith.receiver, "You cannot withdraw from stream");
        require(streamTowith.stopTime < block.timestamp, "stream ended");
        require(amount <= streamTowith.deposit,"Not enough balance");

        //TODO i think we should add a fee mechanism to add some regulation on early withdrawal

        streamTowith.deposit -= amount;

        if(token == NATIVE_TOKEN){
            weth.withdraw(amount);
           (bool ok,) = payable(streamTowith.receiver).call{value: amount}("");
           require(ok);
        }else{
            IERC20(token).transfer(streamTowith.receiver,amount);
        }

        //TODO close stream whenever all the balance has been withdrawed from stream

        emit StreamWithdrawnFrom(streamTowith.receiver, amount, _streamId);
        return amount;

    }
}