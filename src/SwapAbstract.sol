// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "https://github.com/Vectorized/solady/blob/main/src/tokens/ERC20.sol";
import "./ERC223.sol";

struct Permit2Sig {
    uint deadline;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

/* It's more of an interface just with public functions */
abstract contract SwapAbstract {
    ERC20 public immutable asset;

    constructor(ERC20 asset_){
        asset = asset_;
    }

    function erc20ToNativePrice(uint erc20sSold) public virtual view returns (uint nativesBought);
    function nativeToERC20Price(uint nativesSold) public virtual view returns (uint erc20sBought);

    // Use these to handle any effects and interactions
    function _transferNativesBought(address to, uint nativesBought) internal virtual;
    // The erc20 can be a transfer or a mint
    function _transferERC20sBought(address to, uint erc20sBought) internal virtual;

    // Sometimes the erc20 is a transferForm and sometimes it's a burn
    function swapERC20ToNative(uint erc20sSold, address to) public virtual returns (uint nativesBought);

    
    function swapNativeToERC20(address to) public payable returns (uint erc20sBought) {
        erc20sBought = nativeToERC20Price(msg.value);
        _transferERC20sBought(to, erc20sBought);
    }

    // ERC223 tokens can use this instead of erc20ToNativeSwap() to remove the need for approval
    // which is even better than permit2 which still requires approval variable

    // Perhaps the biggest danger of ERC223 is if tokenReceived is if the balance did not increase
    // due to a bad implementation. Even so, how much native tokens that can be extracted is
    // still capped by `nativesBuyable()`.
    function tokenReceived(address from, uint value, bytes calldata) external returns (bytes4) {
        // Checks
        require(msg.sender == address(asset));

        // Effects and Interactions
        _transferNativesBought(from, erc20ToNativePrice(value));

        return 0x8943ec02;
    }


    // msg.sender Defaults
    function swapERC20ToNative(uint erc20sSold) public returns (uint nativesBought) {
        return swapERC20ToNative(erc20sSold, msg.sender);
    }

    function swapNativeToERC20() external payable returns (uint erc20sBought) {
        return swapNativeToERC20(msg.sender);
    }


    /* Permit functions */
    function swapERC20ToNative(uint erc20sSold, address to, Permit2Sig calldata sig) public returns (uint nativesBought) {
        asset.permit(msg.sender, address(this), erc20sSold, sig.deadline, sig.v, sig.r, sig.s);
        return swapERC20ToNative(erc20sSold, to);
    }
    
    function swapERC20ToNative(uint erc20sSold, Permit2Sig calldata sig) external returns (uint nativesBought) {
        return swapERC20ToNative(erc20sSold,msg.sender,sig);
    }

    function swapNativeToERC20(SwapAbstract sa, uint nativesSold, address to) external returns (uint nativesEarned) {
        uint startBalance = asset.balanceOf(address(this));

        sa.swapNativeToERC20{value:nativesSold}();

        nativesEarned = erc20ToNativePrice(asset.balanceOf(address(this)) - startBalance) - nativesSold;

        _transferNativesBought(to, nativesEarned);
    }

    function swapERC20ToNative(SwapAbstract sa, uint erc20sSold, address to) external returns (uint erc20sEarned) {
        uint startBalance = address(this).balance;

        if(address(sa) != address(asset)) { //If the token is from the same contract, it doesn't need approval
            asset.approve(address(sa),erc20sSold);
        }

        sa.swapERC20ToNative(erc20sSold);

        erc20sEarned = nativeToERC20Price(address(this).balance - startBalance) - erc20sSold;

        _transferERC20sBought(to, erc20sEarned);
    }

    // If the token is the same as sa, do not use this because it'll prevent a burn. instead just use the
    // erc20 version.
    function swapERC223ToNative(SwapAbstract sa, uint erc20sSold, address to) external returns (uint erc20sEarned) {
        uint startBalance = address(this).balance;

        ERC223(address(asset)).transfer(address(sa),erc20sSold,"");

        erc20sEarned = nativeToERC20Price(address(this).balance - startBalance) - erc20sSold;

        _transferERC20sBought(to, erc20sEarned);
    }
}