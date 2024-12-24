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
        /*
        uint128 erc20BuyableRate,
        uint128 erc20SellInhibitor, 
        uint128 nativeBuyableRate,
        uint128 nativeSellInhibitor,
        */
        ExchangeConfig ec
        );

    function makeVault(string memory name, string memory symbol) external returns (PinusVault newVault) {
        newVault = new PinusVault(msg.sender,name,symbol);
        emit NewVault(msg.sender,newVault);
    }

    /* Native Token LP */
    function makeLiquidityPool(
        ERC20 asset, 
        ExchangeConfig memory ec
    ) external payable returns (AquitardLP newLP) {
        newLP = new AquitardLP(
            asset,
            ec
        );

        newLP.noSupplyDeposit{value:msg.value}(msg.sender);

        emit NewLiquidityPool(
            asset,
            newLP,
            /*
            ec.erc20BuyableRate,
            ec.erc20SellInhibitor, 
            ec.nativeBuyableRate,
            ec.nativeSellInhibitor,
            */
            ec
        );
    }

    /* ERC20 LP */
    function makeLiquidityPool(
        ERC20 asset, 
        ExchangeConfig memory ec,
        uint assets
    ) external payable returns (AquitardLP newLP) {
        newLP = new AquitardLP(
            asset,
            ec
        );

        newLP.noSupplyDeposit{value:msg.value}(assets,msg.sender);

        emit NewLiquidityPool(
            asset,
            newLP,
            /*
            ec.erc20BuyableRate,
            ec.erc20SellInhibitor, 
            ec.nativeBuyableRate,
            ec.nativeSellInhibitor,
            */
            ec
        );
    }

}