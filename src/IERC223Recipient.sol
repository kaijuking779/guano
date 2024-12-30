// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

interface IERC223Recipient {
    function tokenReceived(address from, uint value, bytes calldata data) external returns (bytes4);
}