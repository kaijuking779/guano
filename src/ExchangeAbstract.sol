// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./SwapAbstract.sol";

abstract contract ExchangeAbstract is SwapAbstract {
    
    uint128 public immutable erc20SellInhibitor;
    uint128 public immutable erc20BuyableRate;
    uint128 public immutable nativeSellInhibitor;
    uint128 public immutable nativeBuyableRate;
    
    uint public erc20BuyableTime = block.timestamp;
    uint private _nativeBuyableTime = block.timestamp;

    constructor(
        uint128 erc20SellInhibitor_, 
        uint128 erc20BuyableRate_,
        uint128 nativeSellInhibitor_,
        uint128 nativeBuyableRate_
    ) {
        erc20SellInhibitor = erc20SellInhibitor_;
        erc20BuyableRate = erc20BuyableRate_;
        nativeSellInhibitor = nativeSellInhibitor_;
        nativeBuyableRate = nativeBuyableRate_;
    }

    // nativesBuyable is better than buyableNatives because the later may be interpreted as an array
    function nativesBuyable() public view returns (uint) {
        return (block.timestamp - _nativeBuyableTime) * nativeBuyableRate;
    }

    function erc20sBuyable() public view returns (uint) {
        return (block.timestamp - erc20BuyableTime) * erc20BuyableRate;
    }

    function erc20ToNativePrice(uint erc20sSold) public override view returns (uint nativesBought) {
        nativesBought = nativesBuyable() * erc20sSold / (erc20SellInhibitor + erc20sSold);
        if(address(this).balance < nativesBought) {
            nativesBought = address(this).balance;
        }
    }

    function _transferNativesBought(address to, uint amount) internal override {
        // Effects
        _nativeBuyableTime += amount / nativeBuyableRate;
        
        // Interactions
        (bool success,) = to.call{value:amount}("");
        require(success);
    }

    
}