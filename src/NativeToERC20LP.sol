// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./AquitardLP.0.0.1.sol";

contract NativeToERC20LP is AquitardLP {

    constructor(ERC20 asset, uint128 swapRate, uint128 inhibitor, uint assets, address receiver) AquitardLP(asset,swapRate,inhibitor) payable {
        noSupplyDeposit(assets, receiver);
    }

    function name() public returns () {
        return 
    }

    function noSupplyDeposit(uint assets, address receiver) public returns (uint shares) {
        shares = assets;

        /* Checks */
        require(totalSupply() == 0);
            
        /* Effects */
        _mint(receiver, shares);

        /* Interactions */
        asset.transferFrom(msg.sender, address(this), assets);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function getInputPrice(uint nativesSold) public view returns (uint256 erc20Bought) {
        erc20Bought = available() * nativesSold / inhibitor;

        if(erc20Bought > asset.balanceOf(address(this))) {
            erc20Bought = asset.balanceOf(address(this));
        }
    }

}