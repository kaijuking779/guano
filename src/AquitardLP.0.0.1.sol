// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./AquitardLPCore.0.0.1.sol";

abstract contract AquitardLP is AquitardLPCore {
    constructor(ERC20 newAsset, uint128 newSwapRate, uint128 newInhibitor) AquitardLPCore(newAsset, newSwapRate, newInhibitor) {}



    function deposit() payable external returns (uint) {
        return deposit(msg.sender);
    }
}