// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;


/* Makes contracts within the Lindy Protocol */

//https://docs.soliditylang.org/en/latest/style-guide.html#naming-conventions

import "./PinusToken.sol";
import "./AquitardLP.0.0.1.sol";

contract LindyFactory {
    event NewToken(address indexed creator, PinusToken newToken);

    event NewLiquidityPool(
        ERC20 indexed asset, 
        AquitardLP liquidityPool,
        ExchangeConfig ec
        );

    function makeToken(string memory name, string memory symbol) external returns (PinusToken newToken) {
        newToken = new PinusToken(msg.sender,name,symbol);
        emit NewToken(msg.sender,newToken);
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
            ec
        );
    }

}