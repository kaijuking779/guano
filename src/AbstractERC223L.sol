// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;


import {ERC20 as AbstractERC20} from "https://github.com/kaijuking779/solady/blob/main/src/tokens/ERC20.sol";
import "./IERC223Recipient.sol";

abstract contract AbstractERC223L is AbstractERC20 {

    function transfer(IERC223Recipient to, uint value, bytes calldata data) public returns (bool success)
    {
        transfer(address(to), value);

        to.tokenReceived(msg.sender, value, data);

        return true;
    }
}