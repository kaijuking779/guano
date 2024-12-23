// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./AquitardLP.0.0.1.sol";

contract NativeToERC20LP is AquitardLP {
    constructor(ERC20 newAsset, uint128 newAvailableRate, uint128 newInhibitor) AquitardLPCore(newAsset,newAvailableRate,newInhibitor) {}

    /* 
        return as memory instead of calldata to remove the need for copying the data 
    */
    function name() public view override returns (string memory) {
        return string.concat("Native Token to ",asset.name()," Liquidity Pool");
    }

    function symbol() public view override returns (string memory) {
        return string.concat("N",asset.symbol(),"LP");
    }

    function noSupplyDeposit(uint assets, address receiver) public returns (uint shares) {
        shares = assets;

        /* Checks */
        require(totalSupply() == 0);
            
        /* Effects */
        _mint(receiver, shares);

        /* Interactions */
        asset.transferFrom(msg.sender, address(this), assets);
        
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function getInputPrice(uint nativesSold) public view returns (uint erc20Bought) {
        erc20Bought = available() * nativesSold / inhibitor;

        if(erc20Bought > asset.balanceOf(address(this))) {
            erc20Bought = asset.balanceOf(address(this));
        }
    }

    function transferInput(address recipient) public payable returns (uint erc20Bought) {
        erc20Bought = getInputPrice(msg.value);

        /* Checks */
        /* Effects */
        availableStartTime += erc20Bought / availableRate;

        /* Interactions */
        asset.transfer(recipient, erc20Bought);
    }

    function swapInput() public payable returns (uint erc20Bought) {
        return transferInput(msg.sender);
    }

}