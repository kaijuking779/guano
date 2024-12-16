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

// rates are constants intentionally to keep behavior predictable when comparing tokens with each other.
uint constant ASSET_CAP = .1 ether;
uint constant SHARE_CAP = 1 ether;
uint constant MINT_RATE =  SHARE_CAP / uint(24 hours); // SHARES PER DAY
uint constant WITHDRAW_RATE = ASSET_CAP / uint(24 hours); // ASSET PER DAY

contract PinusTokenCore is ERC20,Ownable {
    string _name;
    string _symbol;

    uint _mintStartTime = block.timestamp;
    uint _withdrawStartTime = block.timestamp;

    event Deposit(address indexed sender, address indexed owner, uint assets, uint shares);
    event Withdraw(address indexed sender,address indexed receiver,address indexed owner,uint assets,uint shares);
    
    constructor(address owner, string memory name, string memory symbol) Ownable(owner) {
        _name = name;
        _symbol = symbol;
    }

    function customCall(address to,uint value,bytes calldata data) public onlyOwner returns (bytes memory) {
        (, bytes memory returnData) = to.call{value:value}(data);
        return returnData;
    }

    function name() public view override returns (string memory){
        return _name;
    }
    
    function symbol() public view override returns (string memory){
        return _symbol;
    }

    /* Although there is no mint() to use this function, it's useful for calculating deposit shares */
    function maxMint() public view returns (uint) {
        return (block.timestamp - _mintStartTime) * MINT_RATE;
    }
    
    /* The difference in functions is really just to account for fees but this contract doesn't have txn fees so it's the same result */
    function previewDeposit(uint assets) public view returns (uint) {
        return maxMint() * assets / (ASSET_CAP + assets);
    }

    function deposit(address receiver) payable public returns (uint shares) {
        shares = previewDeposit(msg.value);

        /* Checks */

        /* Effects */
        _mintStartTime += shares / MINT_RATE;
        _mint(receiver, shares);

        /* Interactions */
        emit Deposit(msg.sender,receiver,msg.value,shares);
    }

    // There's no withdraw() but this is useful for calculating redeem()
    function maxWithdraw() public view returns (uint) {
        return (block.timestamp - _withdrawStartTime) * WITHDRAW_RATE;
    }

    function previewRedeem(uint shares) public view returns (uint assets) {
        assets = maxWithdraw() * shares / (SHARE_CAP + shares);
        
        if(address(this).balance < assets){
            assets = address(this).balance;
        }
    }

    function redeem(uint shares, address receiver, address owner) public returns (uint assets) {
        assets = previewRedeem(shares);
        /* Checks */
        if(msg.sender!=owner) _spendAllowance(owner, msg.sender, shares);

        /* Effects */
        _withdrawStartTime += assets / WITHDRAW_RATE;
        _burn(owner,shares);
        
        /* Interactions */
        //REENTRANCY PROTECTION - VERY IMPORTANT THAT BURN HAPPENS BEFORE SENDING ETH
        (bool success,) = receiver.call{value:assets}("");
        require(success);

        emit Withdraw(msg.sender,receiver,owner,assets,shares);
    }

}