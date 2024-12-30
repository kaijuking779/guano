// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import "./IExchange.sol";
import "./AbstractERC223L.sol";
import "./AbstractERC1363L.sol";


abstract contract AbstractExchange is IExchange {
    IERC20 public immutable asset;

    constructor(IERC20 asset_){
        asset = asset_;
    }


    function erc20ForNativePrice(uint erc20sSold) public virtual view returns (uint nativesBought);
    function nativeForERC20Price(uint nativesSold) public virtual view returns (uint erc20sBought);

    // Use these to handle any effects and interactions
    function _transferNativesBought(address recipient, uint nativesBought) internal virtual;
    // The erc20 can be a transfer or a mint
    function _transferERC20sBought(address recipient, uint erc20sBought) internal virtual;

    // Sometimes the erc20 is a transferForm and sometimes it's a burn
    function swapERC20ForNative(uint erc20sSold, address recipient) public virtual returns (uint nativesBought);

    
    function swapNativeForERC20(address recipient) public payable returns (uint erc20sBought) {
        erc20sBought = nativeForERC20Price(msg.value);
        _transferERC20sBought(recipient, erc20sBought);
    }

    // ERC223 tokens can use this instead of erc20ForNativeSwap() recipient remove the need for approval
    // which is even better than permit which still requires approval variable

    // Perhaps the biggest danger of ERC223 is if tokenReceived is if the balance did not increase
    // due to a bad implementation. Even so, how much native tokens that can be extracted is
    // still capped by `nativesBuyable()`.

    function tokenReceived(address from, uint value, bytes calldata) public returns (bytes4) {
        require(msg.sender == address(asset));
        _transferNativesBought(from, erc20ForNativePrice(value));

        return 0x8943ec02;
    }

    // ERC1363Receiver
    function onTransferReceived(address, address from, uint256 value, bytes calldata data) external returns (bytes4) {
        tokenReceived(from, value, data);
        return 0x88a7ca5c;
    }

    // msg.sender Defaults
    function swapERC20ForNative(uint erc20sSold) public returns (uint nativesBought) {
        return swapERC20ForNative(erc20sSold, msg.sender);
    }

    function swapNativeForERC20() external payable returns (uint erc20sBought) {
        return swapNativeForERC20(msg.sender);
    }


    // Permit functions
    function swapERC20ForNative(uint erc20sSold, address recipient, PermitSig calldata sig) public returns (uint nativesBought) {
        IERC20Permit(address(asset)).permit(msg.sender, address(this), erc20sSold, sig.deadline, sig.v, sig.r, sig.s);
        return swapERC20ForNative(erc20sSold, recipient);
    }
    
    function swapERC20ForNative(uint erc20sSold, PermitSig calldata sig) external returns (uint nativesBought) {
        return swapERC20ForNative(erc20sSold,msg.sender,sig);
    }

    // Call functions
    function callSwapNativeForERC20(IExchange exchange, uint nativesSold, address earner) external returns (uint nativesEarned) {
        uint startBalance = asset.balanceOf(address(this));

        exchange.swapNativeForERC20{value:nativesSold}();

        nativesEarned = erc20ForNativePrice(asset.balanceOf(address(this)) - startBalance) - nativesSold;

        _transferNativesBought(earner, nativesEarned);
    }

    function callSwapERC20ForNative(IExchange exchange, uint erc20sSold, address earner) external returns (uint erc20sEarned) {
        uint startBalance = address(this).balance;

        if(address(exchange) != address(asset)) { //If the token is from the same contract, it shouldn't need approval
            asset.approve(address(exchange),erc20sSold);
        }

        exchange.swapERC20ForNative(erc20sSold);

        erc20sEarned = nativeForERC20Price(address(this).balance - startBalance) - erc20sSold;

        _transferERC20sBought(earner, erc20sEarned);
    }

    // If the token is the same as sa, do not use this because it'll prevent a burn. instead just use the
    // erc20 version. Name changed from ERC223L to ERC223 because the result should be the same for this function.
    function callSwapERC223ForNative(IERC223Recipient exchange, uint erc20sSold, address earner) external returns (uint erc20sEarned) {
        uint startBalance = address(this).balance;

        AbstractERC223L(address(asset)).transfer(exchange,erc20sSold,"");

        erc20sEarned = nativeForERC20Price(address(this).balance - startBalance) - erc20sSold;

        _transferERC20sBought(earner, erc20sEarned);
    }

    function callSwapERC1363ForNative(IERC1363Receiver exchange, uint erc20sSold, address earner) external returns (uint erc20sEarned) {
        uint startBalance = address(this).balance;

        AbstractERC1363L(address(asset)).transferAndCall(exchange,erc20sSold,"");

        erc20sEarned = nativeForERC20Price(address(this).balance - startBalance) - erc20sSold;

        _transferERC20sBought(earner, erc20sEarned);
    }
}