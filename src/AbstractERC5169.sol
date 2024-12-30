// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC5169.sol";

abstract contract AbstractERC5169 is Ownable, IERC5169 {
    string[] public scriptURI;

    /// @notice Update the scriptURI 
    /// emits event ScriptUpdate(scriptURI memory newScriptURI);
    function setScriptURI(string[] calldata scriptURI_) external onlyOwner {
        scriptURI = scriptURI_;
        emit ScriptUpdate(scriptURI);
    }
}