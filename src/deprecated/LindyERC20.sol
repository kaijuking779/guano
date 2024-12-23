// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "https://github.com/Vectorized/solady/blob/main/src/tokens/ERC20.sol";

contract LindyERC20 is ERC20 {
    //address _tokenURIContract;
    string _name;
    string _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view override returns (string memory){
        return _name;
    }
    
    function symbol() public view override returns (string memory){
        return _symbol;
    }

/*
    function tokenURI() external view returns (string memory) {
        return string.concat("https://",string(bytes20(address(this))));
    }


    function setTokenURI(string tokenURI_) isOwner {
        _tokenURI = tokenURI_;
    }
    */
}