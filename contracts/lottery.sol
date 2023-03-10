// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./VRFv2DirectFundingConsumer.sol";
import "./AutomationCompatible.sol";
contract decentralizedLottery is VRFv2DirectFundingConsumer,AutomationCompatible{
    
    uint public lotteryAmount;    
    address[] lotteryDetails;
    uint public lotteryNo;
    uint public interval;
    
    uint public lastTimeStamp;
    mapping(uint => address) public winner;
    
    constructor(uint _lotteryAmount,uint updateInterval){
        lotteryAmount = _lotteryAmount;
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
    }

    function changeInterval(uint updateInterval) public onlyOwner{
        interval = updateInterval;

    }   
    //10 wei
    function playLottery() public payable{
        require(lotteryAmount >= msg.value,"less amount send");
        lotteryDetails.push(msg.sender);
    }

    function declareWinner() public {
        uint noOfPlayers = lotteryDetails.length;
       uint _randomNo = requestRandomWords();
       uint _winner = _randomNo % noOfPlayers;
       winner[lotteryNo] = lotteryDetails[_winner];
       payable(winner[lotteryNo]).transfer(address(this).balance);
       lotteryNo++;
    }

    function lotteryWinner(uint _lotteryNumber) public view returns(address){
        return winner[_lotteryNumber];
    }

    function checkUpkeep(bytes calldata /* checkData */)external view override returns(bool upkeepNeeded, bytes memory /* performData */){
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            declareWinner();
        }
        // We don't use the performData in this example. The performData is generated by the Automation Node's call to your checkUpkeep function
    }
}