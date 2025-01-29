// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {IERC20} from "./interface/IERC20.sol";

/**
 * @title Mi Streaming contract
 * @author 4B
 * @notice A regular streaming contract
 */
contract Streaming {
    //// EVENTS
    event StreamCreated(uint256 streamID, address creator, address receiver, uint256 duratioN ); //emitted when a stream is created
    event StreamExtended(uint256 streamID, uint256 newStopTime); //emitted when a stream is invested
    event StreamWithdrawnFrom(address receipient, uint256 amount, uint256 streamID); // emitted when a stream is withdrawn from
    event StreamClosed(uint256 streamId, address sender); //emitted when a stream is closed
    event StreamPaused(address, bool); //emitted when owner pauses stream
    event StreamReceipientChanged(address oldReceipient, address newReceipient); //emitted when stream receipient is changed

    bool public paused; //recaord state of protocol whether paused or not 
    address owner; //owner of the streaming contract
    
    address NATIVE_TOKEN = address(0); //native eth

    /**
     * @dev Stream properties/details/params
     */
    struct Stream {
        address sender;  //sender of the stream
        address receiver;  //receiver of amount when stream ends
        uint256 deposit;  //amount deposited into the stream
        uint256 ratePerSecond;  //amount of tokens distributed per second
        uint256 startTime;  //time streaming starts
        uint256 stopTime;  //Time streaming stops
        uint256 withdrawn;  //amount of tokens wothdrawn from stream
        address token;  //address of token streamed
        bool isOpen;  //Is stream opened or closed?
    }

    mapping(uint256 streamId => Stream stream) streamInfo;  //stream details or info
    uint256 public nextStreamId;  //The ID of the next stream
    uint256 public totalNoOfStreams;  //total number of streams opened
    uint256 public totalDeposited;  //Total amount deposited in streams

    constructor() {
        owner = msg.sender;
        nextStreamId=0;
    }

    /**
     * A modifier to check whether stream is paused or not
     */
    modifier isNotPaused() {
        require(paused == false, "Stream is paused");
        _;
    }

    /**
     * A modifier to make sure only the owner can perform function calls 
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not-Authorised");
        _;
    }

    /**
     * A modifier to make sure only owner or sender can call a function
     */
    modifier onlyOwnerOrSender(address _sender) {
        require(msg.sender == owner || msg.sender == _sender, "NotAuthorised");
        _;
    }

    // receive() external payable{}

    /**
     * A funtion to create stream
     * @param _receiver Address to receive funds from stream
     * @param _deposit Amount deposited into stream
     * @param _duration How long the stream will last
     * @param _token Token deposited into stream
     */
    function createStream(address _receiver, uint256 _deposit, uint256 _duration, address _token) public payable isNotPaused returns(uint256 streaMID){
        streaMID = _createStream(_receiver, _deposit, _duration, _token);
    }

    /// an internal function that contains create stream logic
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
            require(msg.value>=_deposit,"invalid deposit");

        }else{
            IERC20(_token).transferFrom(msg.sender,address(this), _deposit);
        }
        uint256 currId = nextStreamId;

        emit StreamCreated(nextStreamId, msg.sender, _receiver, duration);
        nextStreamId++;
        totalNoOfStreams++;
        totalDeposited += _deposit;

        return currId; // returns the current streamID
    }

    /**
     * To extend stop time of existing stream
     * @param _streamId Id of the required stream to extend 
     * @param newStopTime The new stop time of stream
     */
    function extendStream( uint256 _streamId, uint256 newStopTime) public isNotPaused onlyOwnerOrSender(streamInfo[_streamId].sender) {
        require(streamInfo[_streamId].stopTime >= block.timestamp, "stream has already ended");
        require(streamInfo[_streamId].stopTime < newStopTime, "This is no extension");
        // require(streamInfo[_streamId].sender == msg.sender,"Unauthorised");
        // require(streamInfo[_streamId].isOpen, "Stream is closed");

        Stream memory extStream = streamInfo[_streamId];

        uint256 deposit = extStream.deposit;

        extStream.stopTime = newStopTime;
        extStream.ratePerSecond = deposit/newStopTime;

        streamInfo[_streamId] = extStream;

        emit StreamExtended(_streamId, newStopTime);
    }

    /**
     * To help withdraw tokes from an exiting stream to user
     * @param _streamId Id of the required stream to withdraw from
     * @param amount amount of tokens to withdraw from stream
     * @param token Token to withdraw from stream
     */
    function withdrawStream(uint256 _streamId, uint256 amount, address token) public isNotPaused returns(uint256 amountWithdrawn){
        Stream memory streamTowith = streamInfo[_streamId];
        require(msg.sender == streamTowith.receiver, "You cannot withdraw from stream");
        require(streamTowith.stopTime > block.timestamp, "stream ended");
        require(amount <= streamTowith.deposit,"Not enough balance");

        //TODO i think we should add a fee mechanism to add some regulation on early withdrawal

        streamTowith.deposit -= amount;

        if(token == NATIVE_TOKEN){
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

    /**
     * To close an existing stream
     * @param _streamId StreamId of stream to close
     */
    function closeStream(uint256 _streamId) public onlyOwnerOrSender(streamInfo[_streamId].sender) returns(uint256){
        Stream memory streamToClose = streamInfo[_streamId];
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

    /**
     * To pause a stream
     * @param _pause bool indicating whther stream is paused or not
     */
    function pauseStream(bool _pause) public onlyOwner{
        // require(msg.sender == owner, "Not-Authorised"); // change this to a onlyOwner modifier
        require(_pause != paused, "The same value cannot be set twice");
        paused = _pause;
        emit StreamPaused(msg.sender, _pause);
    }

    /**
     * To change the recipient of the stream
     * @param _streamId Id of the required stream
     * @param newReceiver Address of the new recipient
     */
    function changeStreamReceipient(uint256 _streamId, address newReceiver) public onlyOwner returns(address){
        Stream memory streamDet = streamInfo[_streamId];
        require(streamDet.stopTime > block.timestamp, "Stream has ended");
        require(streamDet.isOpen, "Stream is closed");

        address oldReceiver = streamDet.receiver;
        streamDet.receiver = newReceiver;

        streamInfo[_streamId] = streamDet;

        emit StreamReceipientChanged(oldReceiver, newReceiver);
        return streamInfo[_streamId].receiver;
    }

    /**
     * To create a batch of streams all at once
     * @param receiver list of recipients
     * @param deposit deposits of each recipient
     * @param duration duration of each stream listed respectively
     * @param token tokens deposited
     */
    function batchCreateStream(address[4] memory receiver, uint256[4] memory deposit, uint256[4] memory duration, address[4] memory token) external payable onlyOwner returns(uint256[4] memory streamIds){
        require(receiver.length == deposit.length, "input mismatch-1");
        require(receiver.length == duration.length, "input mismatch-2");
        require(duration.length == token.length,"input mismatch-3");

        uint256 length = receiver.length;
        for(uint256 i=0; i<length; i++){
            streamIds[i] = _createStream(receiver[i], deposit[i], duration[i], token[i]);
        }
    }

    /**
     * TO extend the stop time of multiple streams 
     * @param streamId list of required Ids to extend
     * @param newStopTime respective new stop times
     */
    function batchExtendStream(uint256[4] memory streamId, uint256[4] memory newStopTime) external onlyOwner{
        require(streamId.length == newStopTime.length,"invalid length");
        uint256 length = streamId.length;

        for(uint256 i=0; i<length; i++){
            extendStream(streamId[i], newStopTime[i]);
        }
    }

 
    /**
     * Closes an open stream
     * @param streamIds ids of required streams to close
     */
    function batchCloseStreamm(uint256[4] memory streamIds) external onlyOwner{
        require(streamIds.length != 0, "Invalid ids");
        uint256 length = streamIds.length;

        for(uint256 i=0; i<length; i++){
            closeStream(streamIds[i]);
        }
    }


    /**
     * To change recipients for already existing streams 
     * @param streamIds ids of required streams to shange recipient for
     * @param newReceipients list of new recipients to set into streams
     */
    function batchChangeReceipient(uint256[4] memory streamIds, address[4] memory newReceipients) external onlyOwner{
        require(streamIds.length != 0, "Invalid iDs");
        require(streamIds.length == newReceipients.length,"array length mismatch");

        uint256 length = streamIds.length;

        for(uint256 i=0; i<length; i++){
            changeStreamReceipient(streamIds[i], newReceipients[i]);
        }
    }

    /**
     * To get stream info of specified ID
     * @param streamId Id of stream
     */
    function getStreamInfo(uint256 streamId) external view returns(Stream memory streaam){
        streaam = streamInfo[streamId];
    }
}