// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;


/* Makes contracts within the Lindy Protocol */

//https://docs.soliditylang.org/en/latest/style-guide.html#naming-conventions

import "./PinusVault.sol";
import "./NativeToERC20LP.sol";
import "./ERC20ToNativeLP.sol";

contract LindyFactory {
    event NewVault(address indexed creator, PinusVault newVault);
    event NewNativeToERC20LP(ERC20 indexed token, NativeToERC20LP liquidityPool, uint swapRate);
    event NewERC20ToNativeLP(ERC20 indexed token, ERC20ToNativeLP liquidityPool, uint swapRate);

    function makeVault(string memory name, string memory symbol) external returns (PinusVault newVault) {
        newVault = new PinusVault(msg.sender,name,symbol);
        emit NewVault(msg.sender,newVault);
    }

    function makeNativeToERC20LP(PinusVault token,uint swapRate) external returns (NativeToERC20LP newLP) {
        newLP = new NativeToERC20LP(token,swapRate);
        emit NewNativeToERC20LP(token,newLP,swapRate);
    }

    function makeERC20ToNativeLP(PinusVault token, uint swapRate) external payable returns (ERC20ToNativeLP newLP) {
        newLP = new ERC20ToNativeLP{value:msg.value}(token,swapRate);
        emit NewERC20ToNativeLP(token,newLP,swapRate);
    }
}