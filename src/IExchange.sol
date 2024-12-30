// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./IERC223Recipient.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

// Exchange interface between a chain's native token and an assigned erc20 token binded to the contract address.

interface IExchange is IERC223Recipient, IERC1363Receiver  {
    struct PermitSig {
        uint deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function erc20ForNativePrice(uint erc20sSold) external view returns (uint nativesBought);
    function nativeForERC20Price(uint nativesSold) external view returns (uint erc20sBought);

    function swapERC20ForNative(uint erc20sSold, address recipient) external returns (uint nativesBought);
    function swapERC20ForNative(uint erc20sSold) external returns (uint nativesBought);

    function swapNativeForERC20(address recipient) external payable returns (uint erc20sBought);
    function swapNativeForERC20() external payable returns (uint erc20sBought);

    // Permit functions https://eips.ethereum.org/EIPS/eip-2612
    function swapERC20ForNative(uint erc20sSold, address recipient, PermitSig calldata sig) external returns (uint nativesBought);
    function swapERC20ForNative(uint erc20sSold, PermitSig calldata sig) external returns (uint nativesBought);

    // Call functions. Behaves similar to address.call("")
    function callSwapNativeForERC20(IExchange exchange, uint nativesSold, address earner) external returns (uint nativesEarned);
    function callSwapERC20ForNative(IExchange exchange, uint erc20sSold, address earner) external returns (uint erc20sEarned);

    // More gas efficient call functions but do not use if the asset is the exchange. May prevent burning.
    function callSwapERC223ForNative(IERC223Recipient exchange, uint erc20sSold, address earner) external returns (uint erc20sEarned);
    function callSwapERC1363ForNative(IERC1363Receiver exchange, uint erc20sSold, address earner) external returns (uint erc20sEarned);
}