// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./IExchange.sol";

// Exchange interface between a chain's native token and an assigned erc20 token binded to the contract address.

interface ILiquidityPool {
    event Deposit(address indexed sender, address indexed owner, uint erc20sDeposited, uint nativesDeposited, uint shares);
    event Withdraw(address indexed sender, address indexed recipient, address indexed owner, uint erc20sWithdrawn, uint nativesWithdrawn, uint shares);

    function previewDepositNative(uint natives) external view returns (uint shares, uint erc20sRequired);
    function previewDepositERC20(uint erc20s) external view returns (uint shares, uint nativesRequired);

    function deposit(address recipient) external payable returns (uint shares, uint erc20sRequired);
    function deposit(uint erc20s, address recipient) external payable returns (uint shares, uint nativesRequired);

    function noSupplyDeposit(address recipient) external payable returns (uint shares);
    function noSupplyDeposit(uint erc20s, address recipient) external payable returns (uint shares);

    function previewRedeem(uint shares) external view returns (uint erc20s, uint natives);
    function redeem(uint shares, address recipient, address owner) external returns (uint erc20s, uint natives);

    function redeemNativesOnly(uint shares, address recipient, address owner) external returns (uint natives);
}