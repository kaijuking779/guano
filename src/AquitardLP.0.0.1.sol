// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "https://github.com/Vectorized/solady/blob/main/src/tokens/ERC20.sol";
import "./ExchangeAbstract.sol";

/*
This LP is for one way swaps. However adding liquidity is the same regardless.
Although this is a ERC20<>Native Vault, we are NOT using ERC7575.

*/



contract AquitardLP is ExchangeAbstract, ERC223L {
    event Deposit(address indexed sender, address indexed owner, uint assets, uint natives, uint shares);
    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint assets, uint natives, uint shares);

    constructor(ERC20 asset, ExchangeConfig memory ec) 
    ExchangeAbstract(ec) 
    SwapAbstract(asset) 
    {}

    //NOTE The name may change for the underlying asset so we pull this dynamically.
    // This also means the namehash has to be calculated dynamically as well for permit2
    // Also keep in mind if this is used for permit2, multiple pools with the same
    // asset will have the same name and namehash.
    function name() public view override returns (string memory) {
        return string.concat("Aquitard Liquidity Pool(",asset.name(),")");
    }

    function symbol() public view override returns (string memory) {
        return string.concat(asset.symbol(),"ALP");
    }

    function nativeToERC20Price(uint nativesSold) public override view returns (uint erc20sBought) {
        erc20sBought = erc20sBuyable() * nativesSold / (nativeSellInhibitor + nativesSold);

        uint balance = asset.balanceOf(address(this));
        if(balance < erc20sBought) {
            erc20sBought = balance;
        }
    }

    function _transferERC20sBought(address to, uint erc20sBought) internal override {
        // Effects
        erc20BuyableTime += erc20sBought / erc20BuyableRate;

        // Interactions
        asset.transfer(to, erc20sBought);
    }

    function swapERC20ToNative(uint erc20sSold, address to) public override returns (uint nativesBought) {
        nativesBought = erc20ToNativePrice(erc20sSold);
        asset.transferFrom(msg.sender,address(this),erc20sSold);
        _transferNativesBought(to, nativesBought);
    }
    
    //WARNING DO NOT use this one if assets == 0.
    function noSupplyDeposit(uint assets, address to) payable external returns (uint shares) {
        shares = assets;
        // Checks
        require(totalSupply() == 0);
        // Effects
        _mint(to, shares);
        // Interactions
        asset.transferFrom(msg.sender, address(this), assets);
        emit Deposit(msg.sender, to, assets, msg.value, shares);
    }

    //WARNING DO NOT use this one if msg.value == 0
    function noSupplyDeposit(address to) payable external returns (uint shares) {
        shares = msg.value;
        require(totalSupply() == 0);
        _mint(to, shares);
        emit Deposit(msg.sender, to, 0, msg.value, shares);
    }

    function convertToShares(uint assets) public view returns (uint) {
        return totalSupply() * assets / asset.balanceOf(address(this));
    }

    function previewDeposit(uint assets) public view returns (uint) {
        return convertToShares(assets);
    }
    
    // This will fail if there's no assets. Use the other deposit() for that case.
    // The other one is more ideal because less arguments and don't have to worry about sending
    // too many or too little native tokens.
    // DO NOT USE if asset balance is 0. Native balance may be 0.
    function deposit(uint assets, address receiver) payable public returns (uint shares) {
        shares = previewDeposit(assets);
        uint natives = (address(this).balance - msg.value) * assets / asset.balanceOf(address(this));

        // Checks
        uint diff = msg.value - natives;

        // Effects
        _mint(receiver,shares);

        // Interactions
        asset.transferFrom(msg.sender,address(this),assets);
        
        if(diff > 0) {
            (bool success,) = receiver.call{value: diff}("");
            require(success);
        }

        emit Deposit(msg.sender, receiver, assets, natives, shares);
    }

    /* 
        Eventually the native balance will be at zero. When this happens, this function will no longer work
        and the other one will have to be used. Keep in mind this is highly not ideal because
        existing shareholders will be rewarded with your assets. It would make a whole lot more sense
        to just create a new pool.
    */
    function deposit(address receiver) payable public returns (uint shares) {
        shares = totalSupply() * msg.value / (address(this).balance - msg.value);
        uint assets = asset.balanceOf(address(this)) * msg.value / (address(this).balance - msg.value);
        
        /* Checks */
        /* Effects */
        _mint(receiver, shares);

        /* Interactions */
        asset.transferFrom(msg.sender,address(this),assets);
        
        
        emit Deposit(msg.sender, receiver, assets, msg.value, shares);
    }

    function convertToAssets(uint shares) public view returns (uint) {
        return asset.balanceOf(address(this)) * shares / totalSupply();
    }

    function previewRedeem(uint shares) public view returns (uint) {
        return convertToAssets(shares);
    }

    function redeem(uint shares, address receiver, address owner) external returns (uint assets) {
        assets = previewRedeem(shares);

        /* Checks */
        /* Effects */
        if(msg.sender!=owner) _spendAllowance(owner, msg.sender, shares);
        uint natives = address(this).balance * shares / totalSupply();
        _burn(owner,shares);
        
        /* Interactions */
        //REENTRANCY PROTECTION - VERY IMPORTANT THAT BURN HAPPENS BEFORE SENDING ETH
        if(assets>0){
            asset.transfer(receiver,assets);
        }

        if(natives>0) {
            (bool success,) = receiver.call{value: natives}("");
            require(success);
        }

        emit Withdraw(msg.sender, receiver, owner, assets, natives, shares);
    }

    // If for whatever reason, the ERC20 asset can't be transferred, this allows you to at least redeem the ETH
    // WARNING This means you will be giving up any ERC20 asset that you were suppose to receive forever even
    // if in the future the issue is fixed. This function DOES NOT transfer more native tokens than
    // then a normal redeem() would have.
    function redeemNativesOnly(uint shares, address receiver, address owner) external returns (uint assets) {
        assets = 0;

        if(msg.sender!=owner) _spendAllowance(owner, msg.sender, shares);
        uint natives = address(this).balance * shares / totalSupply();
        _burn(owner,shares);

        (bool success,) = receiver.call{value: natives}("");
        require(success);

        emit Withdraw(msg.sender, receiver, owner, assets, natives, shares);
    }
}