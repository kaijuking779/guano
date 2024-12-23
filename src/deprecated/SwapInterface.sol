// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;



interface SwapInterface {
    //function erc20ToNativeSwapInput(uint128 erc20Sold) public returns (uint128 nativeBought);
    //function erc20ToNativeSwapInput(uint128 erc20Sold, address recipient) public returns (uint128 nativeBought);
    function erc20ToNativeSwapInput(uint128 erc20Sold, Permit2Sig calldata sig) external returns (uint128 nativeBought);
    //function erc20ToNativeSwapInput(uint128 erc20Sold, address recipient, Permit2Sig calldata sig) public returns (uint128 nativeBought);

    //function getERC20ToNativeInputPrice(uint128 erc20Sold) public view returns (uint128 nativeBought);
    //function getNativeToERC20InputPrice(uint128 nativeSold) public view returns (uint128 erc20Bought);

    function nativeToERC20SwapInput() external payable returns (uint128 erc20Bought);
    //function nativeToERC20SwapInput(address recipient) public payable returns (uint128 erc20Bought);
}