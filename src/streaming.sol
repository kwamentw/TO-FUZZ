// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {IERC20} from "./interface/IERC20.sol";
import {IWETH} from "./interface/IWETH.sol";


contract Streaming {
    event StreamCreated(uint256 streamID, address creator, address receiver, uint256 duratioN );
    event StreamExtended(uint256 streamID, uint256 newStopTime);
    event StreamWithdrawnFrom(address receipient, uint256 amount, uint256 streamID);
    event StreamClosed(uint256 streamId, address sender);
    event StreamPaused(address, bool);
    event StreamReceipientChanged(address oldReceipient, address newReceipient);

    bool paused;
    address owner;
    
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
        address token;
        bool isOpen;
    }

    mapping(uint256 streamId => Stream stream) streamInfo;
    uint256 nextStreamId;

    constructor(address _weth) {
        weth = IWETH(_weth);
        owner = msg.sender;
    }

    modifier isNotPaused() {
        require(paused == false, "Stream is paused");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not-Authorised");
        _;
    }

    modifier onlyOwnerOrSender(address _sender) {
        require(msg.sender == owner || msg.sender == _sender, "NotAuthorised");
        _;
    }

    function createStream(address _receiver, uint256 _deposit, uint256 _duration, address _token) public payable isNotPaused returns(uint256 streaMID){
        streaMID = _createStream(_receiver, _deposit, _duration, _token);
    }

    function _createStream(address _receiver, uint256 _deposit, uint256 duration, address _token) internal returns(uint256){
        require(_receiver != address(0), "invalid address");
        require(_deposit > 0, "zero amount");
        require(duration > 0, "Invalid duration");
        uint256 _start = block.timestamp;
        
        streamInfo[nextStreamId] = Stream({
            sender:msg.sender,
            receiver:_receiver,
            deposit:_deposit,
            ratePerSecond: _deposit / duration,
            startTime: _start,
            stopTime: _start + duration,
            withdrawn:0,
            token: _token,
            isOpen: true
        });

        if (_token == NATIVE_TOKEN){
            require(msg.value==_deposit,"invalid deposit");
            weth.deposit{value: _deposit}();
        }else{
            IERC20(_token).transferFrom(msg.sender,address(this), _deposit);
        }

        emit StreamCreated(nextStreamId, msg.sender, _receiver, duration);
        nextStreamId++;

        return nextStreamId -1; // returns the current streamID
    }

    function extendStream( uint256 _streamId, uint256 newStopTime) public isNotPaused onlyOwnerOrSender(streamInfo[_streamId].sender) {
        require(streamInfo[_streamId].stopTime > block.timestamp, "stream has already ended");
        require(streamInfo[_streamId].stopTime < newStopTime, "This is no extension");
        // require(streamInfo[_streamId].sender == msg.sender,"Unauthorised");
        require(streamInfo[_streamId].isOpen, "Stream is closed");

        Stream memory extStream = streamInfo[_streamId];

        uint256 deposit = extStream.deposit;

        extStream.stopTime = newStopTime;
        extStream.ratePerSecond = deposit/newStopTime;

        streamInfo[_streamId] = extStream;

        emit StreamExtended(_streamId, newStopTime);
    }

    function withdrawStream(uint256 _streamId, uint256 amount, address token) public isNotPaused returns(uint256 amountWithdrawn){
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

        if(amount == streamTowith.deposit){
            streamTowith.isOpen = false;
        }

        streamInfo[_streamId] = streamTowith;

        emit StreamWithdrawnFrom(streamTowith.receiver, amount, _streamId);
        return amount;

    }

    function closeStream(uint256 _streamId) public onlyOwnerOrSender(streamInfo[_streamId].sender) returns(uint256){
        Stream memory streamToClose = streamInfo[_streamId];
        // require(msg.sender == streamToClose.sender); // use this -> onlyOwnerOrSender(streamInfo[_streamId].sender)
        require(block.timestamp >= streamToClose.stopTime, "Stream duration is not completed");
        require(streamToClose.isOpen, "Stream is already closed");

        uint256 amountToWithdraw;

        if(streamToClose.deposit != 0){
            amountToWithdraw = streamToClose.deposit;
            streamToClose.deposit = 0;
        }

        address receipient = streamToClose.receiver;

        if (streamToClose.token == NATIVE_TOKEN){
            (bool ok,) = payable(receipient).call{value: amountToWithdraw}("");
            require(ok);
        }else{
            bool ok = IERC20(streamToClose.token).transfer(receipient,amountToWithdraw);
            require(ok,"txn failed");
        }

        streamToClose.isOpen = false;
        streamInfo[_streamId] = streamToClose;

        emit StreamClosed(_streamId, msg.sender);
        return _streamId;
    }

    function pauseStream(bool _pause) public onlyOwner{
        // require(msg.sender == owner, "Not-Authorised"); // change this to a onlyOwner modifier
        require(_pause != paused, "The same value cannot be set twice");
        paused = _pause;
        emit StreamPaused(msg.sender, _pause);
    }

    function changeStreamReceipient(uint256 _streamId, address newReceiver) external onlyOwner returns(address){
        Stream memory streamDet = streamInfo[_streamId];
        require(streamDet.stopTime > block.timestamp, "Stream has ended");
        require(streamDet.isOpen, "Stream is closed");

        address oldReceiver = streamDet.receiver;
        streamDet.receiver = newReceiver;

        streamInfo[_streamId] = streamDet;

        emit StreamReceipientChanged(oldReceiver, newReceiver);
        return streamInfo[_streamId].receiver;
    }

    function batchCreateStream(address[] memory receiver, uint256[] memory deposit, uint256[] memory duration, address[] memory token) external onlyOwner returns(uint256[] memory streamIds){
        require(receiver.length == deposit.length, "input mismatch-1");
        require(receiver.length == duration.length, "input mismatch-2");
        require(duration.length == token.length,"input mismatch-3");

        uint256 length = receiver.length;
        for(uint256 i=0; i<length; i++){
            streamIds[i] = _createStream(receiver[i], deposit[i], duration[i], token[i]);
        }
    }

    function batchExtendStream(uint256[] memory streamId, uint256[] memory newStopTime) external onlyOwner{
        require(streamId.length == newStopTime.length,"invalid length");
        uint256 length = streamId.length;

        for(uint256 i=0; i<length; i++){
            extendStream(streamId[i], newStopTime[i]);
        }
    }


    function batchPauseStream(bool[] memory _pause) external onlyOwner{
        uint256 length = _pause.length

        for(uint256 i=0; i<length; i++){
            pauseStream(_pause[i]);
        }
    }
    // add batch for close
    // add batch for changing receipient too
}