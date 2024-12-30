// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

//import "https://github.com/Vectorized/solady/blob/main/src/auth/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/Vectorized/solady/blob/main/src/tokens/ERC20.sol";
import "./AbstractLindyDex.sol";
import "./AbstractERC1046.sol";

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


/*
uint128 constant ERC20_BUYABLE_RATE = 1 ether / uint128(24 hours);
uint128 constant ERC20_SELL_INHIBITOR = 1 ether;
uint128 constant NATIVE_BUYABLE_RATE = .1 ether / uint128(24 hours);
uint128 constant NATIVE_SELL_INHIBITOR = .1 ether;
*/
contract PinusToken 
    is 
    AbstractLindyDex, 
    AbstractERC1046,
    AbstractERC223L,
    AbstractERC1363L
{

    string _name;
    string _symbol;

    bytes32 public immutable nameHash;
    
    constructor(address owner, string memory name_, string memory symbol_, ExchangeConfig memory ec) 
        AbstractLindyDex(ec)
        Ownable(owner) 
        AbstractExchange(this) 
    {
        _name = name_;
        nameHash = keccak256(bytes(name_));

        _symbol = symbol_;
    }

    function _constantNameHash() internal view override returns (bytes32 result) {
        return nameHash;
    }

    function name() public view override returns (string memory){
        return _name;
    }
  
    function symbol() public view override returns (string memory){
        return _symbol;
    }

    function customCall(address to,uint value,bytes calldata data) external onlyOwner returns (bool success, bytes memory returnData) {
        return to.call{value:value}(data);
    }

    function nativeForERC20Price(uint nativesSold) public override view returns (uint erc20sBought) {
        return erc20sBuyable() * nativesSold / (nativeSellInhibitor + nativesSold);
    }

    function _transferERC20sBought(address recipient, uint erc20sBought) internal override {
        erc20BuyableTime += erc20sBought / erc20BuyableRate;
        _mint(recipient, erc20sBought);
    }

    function swapERC20ForNative(uint erc20sSold, address recipient) public override returns (uint nativesBought) {
        nativesBought = erc20ForNativePrice(erc20sSold);
        _burn(msg.sender,erc20sSold);
        _transferNativesBought(recipient,nativesBought);
    }


}