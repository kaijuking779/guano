// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

/*
    Table for all the aquitards. Useful for discovery. 
    Should be created on a chain with cheap gas.

    Better 
*/

contract RankerFactory {
    event NewRanker(address indexed owner, Ranker ranker, string name);

    function make(string calldata name) external returns (Ranker r) {
        r = new Ranker(msg.sender);
        emit NewRanker(msg.sender,r,name);
    }
}

contract Ranker is Ownable {
    uint created = block.timestamp;

    event NewAddress(uint indexed chainId, address a);
    event RankChange(uint indexed chainId, address a);

    mapping(uint chainId => uint) public actionCounts;
    mapping(uint chainId => address[]) public addresses;

    constructor(address owner) Ownable(owner) {}

    function claim() public onlyOwner returns (bool success, bytes memory returnData){
        return msg.sender.call{value:address(this).balance}("");
    }
    
    function chainAddresses(uint chainId) public view returns (address[] memory) {
        return addresses[chainId];
    }
    
    function maxActions(uint chainId) public view returns (uint) {
        return (block.timestamp - created) / (60 seconds) - actionCounts[chainId];
    }

    function actionPrice(uint chainId) public view returns (uint) {
        return 1 ether / maxActions(chainId);
    }

    function push(uint chainId, address a) payable public {
        require(msg.value >= actionPrice(chainId));
        addresses[chainId].push(a);
        actionCounts[chainId]++;
    }

    function pop(uint chainId) payable public {
        require(msg.value >= actionPrice(chainId));
        addresses[chainId].pop();
        actionCounts[chainId]++;   
    }

    function promote(uint chainId, uint index) payable public {
        require(msg.value >= actionPrice(chainId));
        address higherRankAddress = addresses[chainId][index - 1];
        addresses[chainId][index - 1] = addresses[chainId][index];
        addresses[chainId][index] = higherRankAddress;
        actionCounts[chainId]++;
    }

    function demote(uint chainId, uint index) payable public {
        require(msg.value >= actionPrice(chainId));
        address lowerRankAddress = addresses[chainId][index + 1];
        addresses[chainId][index + 1] = addresses[chainId][index];
        addresses[chainId][index] = lowerRankAddress;
        actionCounts[chainId]++;
    }
}