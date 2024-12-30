// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./AbstractExchange.sol";
import "./ILiquidityPool.sol";
import {ERC20 as AbstractERC20} from "https://github.com/kaijuking779/solady/blob/main/src/tokens/ERC20.sol";

abstract contract AbstractLiquidityPool is AbstractExchange, AbstractERC20, ILiquidityPool {

    function _previewDepositNative(uint nativesDeposited, uint nativesAlreadyDeposited) internal view returns (uint shares, uint erc20sRequired) {
        return (
            totalSupply() * nativesDeposited / (address(this).balance - nativesAlreadyDeposited),
            asset.balanceOf(address(this)) * nativesDeposited / (address(this).balance - nativesAlreadyDeposited)
        );
    }

    function previewDepositNative(uint natives) external view returns (uint shares, uint erc20sRequired) {
        return _previewDepositNative(natives,0);
    }
    
    function previewDepositERC20(uint erc20s) public view returns (uint shares, uint nativesRequired) {
        return (
            totalSupply() * erc20s / asset.balanceOf(address(this)),
            address(this).balance * erc20s / asset.balanceOf(address(this))
        );
    }

    function previewRedeem(uint shares) public view returns (uint erc20s, uint natives) {
        return (
            asset.balanceOf(address(this)) * shares / totalSupply(),
            address(this).balance * shares / totalSupply()
        );
    }
    
}