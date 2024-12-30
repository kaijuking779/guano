// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC1046.sol";

abstract contract AbstractERC1046 is Ownable, IERC1046 {
    event NewTokenURI(string tokenURI);

    string public tokenURI;
    
    function setTokenURI(string calldata tokenURI_) external onlyOwner {
        tokenURI = tokenURI_;
        emit NewTokenURI(tokenURI_);
    }
}