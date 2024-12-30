// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {ERC20 as AbstractERC20} from "https://github.com/kaijuking779/solady/blob/main/src/tokens/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

abstract contract AbstractERC1363L is AbstractERC20 {

    function transferAndCall(IERC1363Receiver to, uint value, bytes calldata data) external returns (bool)
    {
        transfer(address(to), value);

        to.onTransferReceived(msg.sender, msg.sender, value, data);

        return true;
    }
}