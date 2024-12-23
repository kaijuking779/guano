// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;


/* Makes contracts within the Lindy Protocol */

//https://docs.soliditylang.org/en/latest/style-guide.html#naming-conventions

import "./PinusVault.sol";
import "./AquitardLP.0.0.1.sol";

contract LindyFactory {
    event NewVault(address indexed creator, PinusVault newVault);

    event NewLiquidityPool(
        ERC20 indexed asset, 
        AquitardLP liquidityPool, 
        uint128 erc20SellInhibitor, 
        uint128 erc20BuyableRate,
        uint128 nativeSellInhibitor,
        uint128 nativeBuyableRate 
        );

    function makeVault(string memory name, string memory symbol) external returns (PinusVault newVault) {
        newVault = new PinusVault(msg.sender,name,symbol);
        emit NewVault(msg.sender,newVault);
    }

    /* Native Token LP */
    function makeLiquidityPool(
        ERC20 asset, 
        uint128 erc20SellInhibitor, 
        uint128 erc20BuyableRate,
        uint128 nativeSellInhibitor,
        uint128 nativeBuyableRate
    ) external payable returns (AquitardLP newLP) {
        newLP = new AquitardLP(
            asset,
            erc20SellInhibitor, 
            erc20BuyableRate,
            nativeSellInhibitor,
            nativeBuyableRate
        );

        newLP.noSupplyDeposit{value:msg.value}(msg.sender);

        emit NewLiquidityPool(
            asset,
            newLP,
            erc20SellInhibitor, 
            erc20BuyableRate,
            nativeSellInhibitor,
            nativeBuyableRate
        );
    }

    /* ERC20 LP */
    function makeLiquidityPool(
        ERC20 asset, 
        uint128 erc20SellInhibitor, 
        uint128 erc20BuyableRate,
        uint128 nativeSellInhibitor,
        uint128 nativeBuyableRate,
        uint assets
    ) external payable returns (AquitardLP newLP) {
        newLP = new AquitardLP(
            asset,
            erc20SellInhibitor, 
            erc20BuyableRate,
            nativeSellInhibitor,
            nativeBuyableRate
        );

        newLP.noSupplyDeposit{value:msg.value}(assets,msg.sender);

        emit NewLiquidityPool(
            asset,
            newLP,
            erc20SellInhibitor, 
            erc20BuyableRate,
            nativeSellInhibitor,
            nativeBuyableRate
        );
    }

/*
    function makeNativeToERC20LP(ERC20 asset, uint128 availableRate, uint128 inhibitor, uint assets) external returns (NativeToERC20LP newLP) {
        newLP = new NativeToERC20LP(asset, availableRate, inhibitor);
        newLP.noSupplyDeposit(assets, msg.sender);
        emit NewNativeToERC20LP(asset, newLP, availableRate, inhibitor);
    }

    function makeERC20ToNativeLP(ERC20 asset, uint128 availableRate, uint128 inhibitor) external payable returns (ERC20ToNativeLP newLP) {
        newLP = new ERC20ToNativeLP(asset, availableRate, inhibitor);
        newLP.noSupplyDeposit{value:msg.value}(msg.sender);
        emit NewERC20ToNativeLP(asset, newLP, availableRate, inhibitor);
    }
  */  
}