// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./SwapAbstract.sol";

//NOTE struct is used to make it more explicit to reduce the parameters getting mixed up.
struct ExchangeConfig {
    uint128 erc20BuyableRate;
    uint128 erc20SellInhibitor;
    uint128 nativeBuyableRate;
    uint128 nativeSellInhibitor;
}

abstract contract ExchangeAbstract is SwapAbstract {
    
    uint128 public immutable erc20BuyableRate;
    uint128 public immutable erc20SellInhibitor;
    uint128 public immutable nativeBuyableRate;
    uint128 public immutable nativeSellInhibitor;
    
    uint public erc20BuyableTime = block.timestamp;
    uint private _nativeBuyableTime = block.timestamp;

    constructor(
        ExchangeConfig memory ec
    ) {
        erc20BuyableRate = ec.erc20BuyableRate;
        erc20SellInhibitor = ec.erc20SellInhibitor;
        nativeBuyableRate = ec.nativeBuyableRate;
        nativeSellInhibitor = ec.nativeSellInhibitor;
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