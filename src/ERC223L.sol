// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "https://github.com/Vectorized/solady/blob/main/src/tokens/ERC20.sol";
import "https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/IERC223Recipient.sol";

abstract contract ERC223L is ERC20 {

    function transfer(address to, uint value, bytes calldata data) public returns (bool success)
    {
        transfer(to, value);

        IERC223Recipient(to).tokenReceived(msg.sender, value, data);

        return true;
    }
}