// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

//import "https://github.com/Vectorized/solady/blob/main/src/auth/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/Vectorized/solady/blob/main/src/tokens/ERC20.sol";

/* 
Partially implements EIP-7535 which is a native token version of EIP-4626 where it makes sense.

mint() is not implemented because it's not necessary, requires more fringe-case handling, and doesn't even apply to current use cases.
withdraw() isn't implemented for the same reasons.

Generally the need to make auditing simpler is more important to me than adding features that may never even be used.

I decided to use solady for erc 20 because I want to remove any obstacles from producing volume.

However for ownable, I appreciate the extra protection from human-error in openzeppelin's implementation.

I was originally going to add a proxy for maximum flexibility but decided I just want something more simple yet flexible
so I decided on customCall() instead. Doesn't even have batching but should cover any situation. Doesn't even check if the call was successful.

https://eips.ethereum.org/EIPS/eip-5143
Was not going to add front-run protection because there's not as much incentive to sandwich when there's a spread.
I also think front-run protection should be implemented by the caller instead...

deposit() and redeem() are missing transfers to an address aside from the sender. 
*/

uint constant MINT_RATE = .2 ether / uint(24 hours); // GUANO PER DAY
uint constant WITHDRAW_RATE = .1 ether / uint(24 hours); // ETHER PER DAY

contract BatteryToken is ERC20,Ownable {
    string immutable _name;
    string immutable _symbol;

    uint immutable created = block.timestamp;
    uint totalMinted = 0; //shares minted
    uint totalDeposited = 0; //assets deposited
    uint totalRedeemed = 0; //shares redeemed
    uint totalWithdrawn = 0; //assets withdrawn

    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed sender,address indexed receiver,address indexed owner,uint256 assets,uint256 shares);

    constructor() Ownable(msg.sender) {}

    function customCall(address to,uint value,bytes calldata data) public onlyOwner returns (bytes memory) {
        (, bytes memory returnData) = to.call{value:value}(data);
        return returnData;
    }

    function name() public pure override returns (string memory){
        return "Kaiju Guano";
    }
    
    function symbol() public pure override returns (string memory){
        return "GUANO";
    }

    /* Although there is no mint() to use this function, it's useful for calculating deposit shares */
    function maxMint(address receiver) public view returns (uint) {
        return (block.timestamp - created) * MINT_RATE - totalMinted;
    }
    
    function convertToShares(uint assets) public view returns (uint) {
        return assets * maxMint(msg.sender) / (totalDeposited + assets);
    }
    
    /* The difference in functions is really just to account for fees but this contract doesn't have txn fees so it's the same result */
    function previewDeposit(uint assets) public view returns (uint) {
        return convertToShares(assets);
    }

    function deposit(uint assets,address receiver) payable public returns (uint) {
        uint shares = previewDeposit(msg.value);

        /* Checks */

        /* Effects */
        totalMinted+=shares;
        totalDeposited+=msg.value;
        _mint(receiver, shares);

        /* Interactions */

        emit Deposit(msg.sender,receiver,msg.value,shares);

        return shares;
    }

    // There's no withdraw() but this is useful for calculating redeem()
    function maxWithdraw(address owner) public view returns (uint) {
        return (block.timestamp - created) * WITHDRAW_RATE - totalWithdrawn;
    }


    function convertToAssets(uint shares) public view returns (uint) {
        uint assets = shares * maxWithdraw(msg.sender) / (totalRedeemed + shares);
        
        if(address(this).balance < assets){
            assets = address(this).balance;
        }

        return assets;
    }

    function previewRedeem(uint shares) public view returns (uint) {
        return convertToAssets(shares);
    }

    function redeem(uint shares, address receiver,address owner) public returns (uint) {
        uint assets = previewRedeem(shares);
        /* Checks */
        if(msg.sender!=owner) _spendAllowance(owner, msg.sender, shares);

        /* Effects */
        totalRedeemed+=shares;
        totalWithdrawn+=assets;
        _burn(owner,shares);
        
        /* Interactions */
        //REENTRANCY PROTECTION - VERY IMPORTANT THAT BURN HAPPENS BEFORE SENDING ETH
        (bool success,) = receiver.call{value:assets}("");
        require(success);

        emit Withdraw(msg.sender,receiver,owner,assets,shares);

        return assets;
    }
}