// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import "./PinusVaultCore.sol";



//Aquitard extended with extra aliases for more interoperability with ERC 4626.
// It's still missing symmetric functions


contract PinusVault is PinusVaultCore {
    constructor(address owner, string memory newName, string memory newSymbol) PinusVaultCore(owner,newName,newSymbol) {}

    function maxMint(address) public view returns (uint) {
        return maxMint();
    }
    
    function convertToShares(uint assets) public view returns (uint) {
        return previewDeposit(assets);
    }
    
    function deposit() payable public returns (uint) {
        return deposit(msg.sender);
    }

    //asset is not used since it's native eth. just here for interoperability
    function deposit(uint,address receiver) payable public returns (uint) {
        return deposit(receiver);
    }
    
    function maxWithdraw(address) public view returns (uint) {
        return maxWithdraw();
    }
    
    function convertToAssets(uint shares) public view returns (uint) {
        return previewRedeem(shares);
    }

    function redeem(uint shares, address receiver) public returns (uint) {
        return redeem(shares, receiver, msg.sender);
    }

    function redeem(uint shares) public returns (uint) {
        return redeem(shares,msg.sender);
    }

    function maxDeposit(address) external pure returns (uint) {
        return 2 ** 256 - 1;
    }
    
    function maxRedeem(address) external pure returns (uint) {
        return 2 ** 256 - 1;
    }
}