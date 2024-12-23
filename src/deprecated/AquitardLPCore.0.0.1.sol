// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "https://github.com/Vectorized/solady/blob/main/src/tokens/ERC20.sol";

/*
This LP is for one way swaps. However adding liquidity is the same regardless.
Although this is a ERC20<>Native Vault, we are NOT using ERC7575.

*/

abstract contract AquitardLPCore is ERC20 {
    event Deposit(address indexed sender, address indexed owner, uint assets, uint shares);
    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint assets, uint shares);

    ERC20 public immutable asset;
    uint128 public immutable availableRate;
    uint128 public immutable inhibitor;
    
    uint public availableStartTime = block.timestamp; //this ts is used to calculate available asset for swapping. It is only updated for swaps.

    constructor(ERC20 newAsset, uint128 newAvailableRate, uint128 newInhibitor) {
        asset = newAsset;
        availableRate = newAvailableRate;
        inhibitor = newInhibitor;
    }

    function convertToShares(uint assets) public view returns (uint) {
        return totalSupply() * assets / asset.balanceOf(address(this));
    }

    function previewDeposit(uint assets) public view returns (uint) {
        return convertToShares(assets);
    }

    /*
        This will fail if there's no assets. Use the other deposit() for that case.
        The other one is more ideal because less arguments and don't have to worry about sending
        too many or too little native tokens.
    */
    function deposit(uint assets, address receiver) payable public returns (uint shares) {
        shares = previewDeposit(assets);
        uint natives = address(this).balance * assets / asset.balanceOf(address(this));
        /* Checks */
        require(msg.value >= natives);

        /* Effects */
        _mint(receiver,shares);

        /* Interactions */
        asset.transferFrom(msg.sender,address(this),assets);
        
        uint diff = msg.value - natives;
        if(diff > 0) {
            (bool success,) = receiver.call{value: diff}("");
            require(success);
        }

        emit Deposit(msg.sender,receiver,assets,shares);
    }

    /* 
        Eventually the native balance will be at zero. When this happens, this function will no longer work
        and the other one will have to be used. Keep in mind this is highly not ideal because
        existing shareholders will be rewarded with your assets. It would make a whole lot more sense
        to just create a new pool.
    */
    function deposit(address receiver) payable public returns (uint shares) {
        shares = totalSupply() * msg.value / address(this).balance;
        uint assets = asset.balanceOf(address(this)) * msg.value / address(this).balance;
        
        /* Checks */

        /* Effects */
        _mint(receiver,shares);

        /* Interactions */
        asset.transferFrom(msg.sender,address(this),assets);
        emit Deposit(msg.sender,receiver,assets,shares);
    }

    function convertToAssets(uint shares) public view returns (uint) {
        return asset.balanceOf(address(this)) * shares / totalSupply();
    }

    function previewRedeem(uint shares) public view returns (uint) {
        return convertToAssets(shares);
    }

    function redeem(uint shares, address receiver,address owner) external returns (uint assets) {
        assets = previewRedeem(shares);

        /* Checks */

        /* Effects */
        if(msg.sender!=owner) _spendAllowance(owner, msg.sender, shares);
        uint natives = address(this).balance * shares / totalSupply();
        _burn(owner,shares);
        
        /* Interactions */
        //REENTRANCY PROTECTION - VERY IMPORTANT THAT BURN HAPPENS BEFORE SENDING ETH
        asset.transfer(receiver,assets);

        (bool success,) = receiver.call{value: natives}("");
        require(success);

        emit Withdraw(msg.sender,receiver,owner,assets,shares);
    }

    // available ERC20 or Native Token to buy depending on the pool
    function available() public view returns (uint) {
        return (block.timestamp - availableStartTime) * availableRate;
    }

}