// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;


/* Makes contracts within the Lindy Protocol */

//https://docs.soliditylang.org/en/latest/style-guide.html#naming-conventions

import "./PinusToken.sol";
import "./AquitardLP.sol";

//TODO set exchange config at the factory level for consistency instead of forcing it on every PinusToken
/*
uint128 constant ERC20_BUYABLE_RATE = 1 ether / uint128(24 hours);
uint128 constant ERC20_SELL_INHIBITOR = 1 ether;
uint128 constant NATIVE_BUYABLE_RATE = .1 ether / uint128(24 hours);
uint128 constant NATIVE_SELL_INHIBITOR = .1 ether;
*/

contract LindyFactory {
    uint128 public immutable erc20BuyableRate;
    uint128 public immutable erc20SellInhibitor;
    uint128 public immutable nativeBuyableRate;
    uint128 public immutable nativeSellInhibitor;

    constructor(
        AbstractLindyDex.ExchangeConfig memory ec
    ) {
        erc20BuyableRate = ec.erc20BuyableRate;
        erc20SellInhibitor = ec.erc20SellInhibitor;
        nativeBuyableRate = ec.nativeBuyableRate;
        nativeSellInhibitor = ec.nativeSellInhibitor;
    }

    event NewToken(address indexed creator, PinusToken newToken, string name, string symbol);

    event NewLiquidityPool(
        IERC20 indexed asset, 
        AquitardLP liquidityPool,
        AbstractLindyDex.ExchangeConfig ec
        );

    function makeToken(string memory name, string memory symbol) external returns (PinusToken newToken) {
        newToken = new PinusToken(
            msg.sender,
            name,
            symbol,
            AbstractLindyDex.ExchangeConfig({
                erc20BuyableRate : erc20BuyableRate,
                erc20SellInhibitor : erc20SellInhibitor,
                nativeBuyableRate : nativeBuyableRate,
                nativeSellInhibitor : nativeSellInhibitor
            })
            );
        emit NewToken(msg.sender, newToken, name, symbol);
    }

    /* Native Token LP */
    function makeLiquidityPool(
        IERC20 asset, 
        AbstractLindyDex.ExchangeConfig memory ec
    ) external payable returns (AquitardLP newLP) {
        newLP = new AquitardLP(
            asset,
            ec
        );

        newLP.noSupplyDeposit{value:msg.value}(msg.sender);

        emit NewLiquidityPool(
            asset,
            newLP,
            ec
        );
    }

    /* ERC20 LP */
    function makeLiquidityPool(
        IERC20 asset, 
        AbstractLindyDex.ExchangeConfig memory ec,
        uint erc20sDeposited
    ) external payable returns (AquitardLP newLP) {
        newLP = new AquitardLP(
            asset,
            ec
        );

        newLP.noSupplyDeposit{value:msg.value}(erc20sDeposited,msg.sender);

        emit NewLiquidityPool(
            asset,
            newLP,
            ec
        );
    }

}