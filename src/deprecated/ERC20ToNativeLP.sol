// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./AquitardLP.0.0.1.sol";
import "./PinusVault.sol";

contract ERC20ToNativeLP is AquitardLP {
    constructor(ERC20 newAsset, uint128 newAvailableRate, uint128 newInhibitor) AquitardLPCore(newAsset,newAvailableRate,newInhibitor) {}

    function name() public view override returns (string memory){
        return string.concat(asset.name()," to Native Liquidity Pool");
    }
    
    function symbol() public view override returns (string memory){
        return string.concat(asset.symbol(),"NLP");
    }
    
    /* Necessary if it's a new vault or all shares have been redeemed. */
    function noSupplyDeposit(address receiver) public payable returns (uint shares) {
        shares = msg.value;

        /* Checks */
        require(totalSupply() == 0);
        
        /* Effects */
        _mint(receiver, shares);

        /* Interactions */
        emit Deposit(msg.sender,receiver,msg.value,shares);
    }

    function getInputPrice(uint erc20Sold) public view returns (uint nativeBought) {
        nativeBought = available() * erc20Sold / (inhibitor + erc20Sold);
        
        if(address(this).balance < nativeBought){
            nativeBought = address(this).balance;
        }
    }

    function transferInput(uint128 erc20Sold, address recipient) public returns (uint nativeBought) {
        nativeBought = getInputPrice(erc20Sold);

        /* Checks */
        /* Effects */
        availableStartTime += nativeBought / availableRate;
        
        /* Interactions */
        asset.transferFrom(msg.sender,address(this),erc20Sold);
        
        (bool success,) = recipient.call{value:nativeBought}("");
        require(success);
    }

    /* 
    special transferInput() that takes in native token and returns native tokens.
    only works if the asset is a native token vault.
    allows for a complete skip of allowance checks.
    TODO: use one that borrows the pool's native token. essentially a flash loan
    */
    function transferInput(address recipient) external payable returns (uint nativeBought) {
        uint shares = PinusVault(address(asset)).deposit{value:msg.value}();

        nativeBought = getInputPrice(shares);
        
        availableStartTime += nativeBought / availableRate;
        
        (bool success,) = recipient.call{value:nativeBought}("");
        require(success);
    }

    /* deposits to asset using the native assets in this vault to get shares.
    Any profit is given to caller as a work fee.
     */ 
     
    function assetDeposit(uint128 natives,address recipient) external returns (uint workFee) {
        uint shares = PinusVault(address(asset)).deposit{value:natives}();
        uint nativeBought = getInputPrice(shares);
        workFee = nativeBought - natives;
        
        /* Checks */
        require(workFee > 0);

        /* Effects */
        availableStartTime += nativeBought / availableRate;

        /* Interactions */
        (bool success,) = recipient.call{value:workFee}("");
        require(success);
    }

    /* permit2 */
    function transferInput(uint128 erc20Sold, address recipient, uint deadline, uint8 v, bytes32 r, bytes32 s) public returns (uint nativeBought) {
        asset.permit(msg.sender,address(this),erc20Sold,deadline,v,r,s);
        return transferInput(erc20Sold,recipient);
    }

    function swapInput(uint128 erc20Sold) public returns (uint nativeBought) {
        return transferInput(erc20Sold,msg.sender);
    }

    /* permit2 */
    function swapInput(uint128 erc20Sold, uint deadline, uint8 v, bytes32 r, bytes32 s) external returns (uint nativeBought) {
        asset.permit(msg.sender,address(this),erc20Sold,deadline,v,r,s);
        return swapInput(erc20Sold);
    }

}
