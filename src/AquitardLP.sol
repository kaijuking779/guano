// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;


import "./AbstractLindyDex.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./AbstractLiquidityPool.sol";

/*
This LP is for one way swaps. However adding liquidity is the same regardless.
Although this is a ERC20<>Native Vault, we are NOT using ERC7575.

*/


contract AquitardLP 
is 

AbstractLiquidityPool,
AbstractLindyDex,
AbstractERC223L,
AbstractERC1363L
{

    constructor(IERC20 asset, ExchangeConfig memory ec) 
    AbstractExchange(asset) 
    AbstractLindyDex(ec)
    {}

    //NOTE The name may change for the underlying asset so we pull this dynamically.
    // This also means the namehash has to be calculated dynamically as well for permit2
    // Also keep in mind if this is used for permit2, multiple pools with the same
    // asset will have the same name and namehash.
    function name() public view override returns (string memory) {
        return string.concat("Aquitard Liquidity Pool (",IERC20Metadata(address(asset)).name(),")");
    }

    function symbol() public view override returns (string memory) {
        return string.concat(IERC20Metadata(address(asset)).symbol(),"ALP");
    }

    function nativeForERC20Price(uint nativesSold) public override view returns (uint erc20sBought) {
        erc20sBought = erc20sBuyable() * nativesSold / (nativeSellInhibitor + nativesSold);

        uint balance = asset.balanceOf(address(this));
        if(balance < erc20sBought) {
            erc20sBought = balance;
        }
    }

    function _transferERC20sBought(address recipient, uint erc20sBought) internal override {
        erc20BuyableTime += erc20sBought / erc20BuyableRate;
        asset.transfer(recipient, erc20sBought);
    }

    function swapERC20ForNative(uint erc20sSold, address recipient) public override returns (uint nativesBought) {
        nativesBought = erc20ForNativePrice(erc20sSold);
        asset.transferFrom(msg.sender,address(this),erc20sSold);
        _transferNativesBought(recipient, nativesBought);
    }
    
    //WARNING DO NOT use this one if erc20sDeposited == 0.
    function noSupplyDeposit(uint erc20sDeposited, address recipient) payable external returns (uint shares) {
        shares = erc20sDeposited;

        require(totalSupply() == 0);

        asset.transferFrom(msg.sender, address(this), erc20sDeposited);
        _mint(recipient, shares);

        emit Deposit(msg.sender, recipient, erc20sDeposited, msg.value, shares);
    }

    //WARNING DO NOT use this one if msg.value == 0
    function noSupplyDeposit(address recipient) payable external returns (uint shares) {
        shares = msg.value;
        require(totalSupply() == 0);
        _mint(recipient, shares);
        emit Deposit(msg.sender, recipient, 0, msg.value, shares);
    }

    // require(address(this).balance > 0);
    function deposit(address recipient) external payable returns (uint shares, uint erc20sRequired) {
        (shares, erc20sRequired) = _previewDepositNative(msg.value, msg.value);

        if(erc20sRequired > 0) {
            asset.transferFrom(msg.sender, address(this), erc20sRequired);
        }
        
        _mint(recipient, shares);

        emit Deposit(msg.sender, recipient, erc20sRequired, msg.value, shares);
    }

    // require(asset.balanceOf(address(this)) > 0);
    function deposit(uint erc20s, address recipient) external payable returns (uint shares, uint nativesRequired) {
        (shares, nativesRequired) = previewDepositERC20(erc20s);

        uint diff = msg.value - nativesRequired;
        
        asset.transferFrom(msg.sender, address(this), erc20s);

        _mint(recipient, shares);

        if(diff > 0) {
            (bool success,) = recipient.call{value:diff}("");
            require(success);
        }

        emit Deposit(msg.sender, recipient, erc20s, nativesRequired, shares);
    }

    function redeem(uint shares, address recipient, address owner) external returns (uint erc20s, uint natives) {
        (erc20s, natives) = previewRedeem(shares);

        /* Checks */
        /* Effects */
        if(msg.sender!=owner) _spendAllowance(owner, msg.sender, shares);

        _burn(owner,shares);
        
        /* Interactions */
        //REENTRANCY PROTECTION - VERY IMPORTANT THAT BURN HAPPENS BEFORE SENDING ETH
        if(erc20s>0){
            asset.transfer(recipient, erc20s);
        }

        if(natives>0) {
            (bool success,) = recipient.call{value: natives}("");
            require(success);
        }

        emit Withdraw(msg.sender, recipient, owner, erc20s, natives, shares);
    }

    // If for whatever reason, the ERC20 asset can't be transferred, this allows you to at least redeem the ETH
    // WARNING This means you will be giving up any ERC20 asset that you were suppose to receive. 
    // This function DOES NOT transfer more native tokens than
    // then a normal redeem() would have.
    function redeemNativesOnly(uint shares, address recipient, address owner) external returns (uint natives) {

        if(msg.sender!=owner) _spendAllowance(owner, msg.sender, shares);
        natives = address(this).balance * shares / totalSupply();
        _burn(owner,shares);

        (bool success,) = recipient.call{value: natives}("");
        require(success);

        emit Withdraw(msg.sender, recipient, owner, 0, natives, shares);
    }
}