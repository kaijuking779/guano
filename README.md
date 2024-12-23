# Lindy Protocol


---

title: Loose Vaults

description: Tokenized Vaults with loosely valued shares.

author: kaijuking779

created: 2024-11-17

requires: EIP-20, EIP-173

---


## Abstract
WIP - Not even rough draft status - Currently the priority is to jot down all thoughts and then clean up later.

This is a tokenized vault where the price to mint or burn is *loosely* connected to the underlying asset allowing instrumental value to be factored in.

This contract is a tokenized vault where the supply of tokens is managed by a minting bonding curve and a burning bonding curve.
The supply of shares for minting is added to the minting bonding curve at a constant rate.
The supply of assets for withdrawing is added to the burning bonding curve at a *different* constant rate.

Single Token Liquidity AMM with spread! *insert leg spreading joke here*


### References
[Continuous GDA](https://www.paradigm.xyz/2022/04/gda)

## Motivation
Most vaults produce shares that only consider the intrinsic but not the *extrinsic* value.
This severely limits their flexibility and potential as it doesn't reflect reality.
In fact *all* things have intrinsic and extrinsic value we just don't talk about it because it's intuitive.
When we remove this limitation, we open a whole new world of possibilities.

### Bonding curve issues
All the problems with AMMs have not been solved.
The impermanent loss of uniswap's bonding curve has NOT been solved with custom liquidity pool ranges. 
Slippage protection does not solve sandwich attacks.
The need for large amounts of liquidity has not been solved with transaction fees.
Uniswap has given up and has decided to become a middle-man that only routes traffic.
What will eventually happen is uniswap will route centralized pools and become no different from existing centralized exchanges.
1inch has long been doing this already with private pools that connect to their routers.
Ultimately AMMs as it stands are inferior to the traditional orderbooks not because of centralization but
because of the spread. I believe the spread is important for giving liquidity providers incentive to participate.
Otherwise only the fees are preventing the provider from becoming always the "last one to buy or sell".
Liquid vault tokens do not rely on TVL to do trades yet it's also more flexible than setting an orderbook price.
In fact it cannot be replicated by any orderbook without a bot and is more similar to puts and calls for every interval.

### Underwater debt
Vaults in the traditional-sense are expected to keep assets stationary. However, just like banks, this is only figuratively. In actuality,
the underlying assets may increase (due to interest) or lost (due to unforeseen circumstances). However, just like banks, this could
result in a "bank run". In this situation, things could get messy. We could do first-come first-serve or we could distribute pro rata what's left.
The benefit of first-come first-server is no need to calculate the vault's total worth. However this punishes the late-comers which you should be rewarding.

Instead we can use a 3rd strategy which is to *always* provide assets for withdrawal at a constant rate and then set the price based on the provided supply 
and demand (withdraw rate). This means as a withdrawer, you can decide to withdraw a large amount for a small immediate return or withdraw small amounts
overtime for a larger return. The underlying asset might impact your decision but generally speaking if the underlying asset is stable, you will be 
rewarded for being consistent.

### Need for liquidity
When people think of liquidity problems, they think of houses where the price is unafforable for the population and the process is incredibly slow.
However even when price and speed is not an issue, liquidity can still be an issue when there's not enough makers vs takers in the market.
This is why all exchange fees are reduced for makers. This is why liquidity providers are rewarded with fees in AMMs.
Liquid vaults solve this not only by always providing a place to buy and sell but also to reward it by reducing and inversing the spread.

Non-liquid assets reduces the utility of an asset by limiting it's target audience to higher net individuals. At the same time, because high-net individuals
tend to want predictable security, an asset that has no liquidity could also may very be due to no demand. This ends up being a death-spiral.
An example is a multiplayer-game with no players. Therefore it's important that an asset always has volume and removes any barriers for producing volume.
Some key obstacles for volume is gas-fees, transaction fees, royalties, and taxes. Some not-so-obvious obstacles are high volatility, reputation, 
and non-fungibility.

### Left-overs
Another problem with vaults is the unavoidable fact that some shares will be lost. When this happens, the underlying assets will be locked
forever without intervention by the manager. This "always minting always burning" system is flexible enough to allow for all assets to be
*eventually* reached if the vault ever needs to be fully emptied.

### High volatility pump and dump vs stable coin
From a trader's pov, nobody wants to get dumped but it's also inconvenient for long-term investors because it can lead to a full on burn out
of the token. It in fact discourages long-term holding which can then lead to the token going to zero. Pump and dumps should be prevented at 
all cost if you care about it's future. This means utilizing every thing you can to keep it stable. Slow down marketing, exposure, reduce costs,
increase efficiency so that you can last as long as possible.

"Stable" in stable coins is misleading. We should really call them fiat-mapped coins. Liquid vaults have the potential be *real* stable coin primitive that
exists as a node within a tree-structure of tokens. This is due to the design having the property of being volatile but stable over time. A similar characteristic
can be seen with ampleforth but *without* algorithmic rebasing. Without DAI's liquidation system.

### Airdrops
Liquid vaults are a suitable replacement for airdrops. It discourages the formulation of cabals. It prevents any possibility of 
unknown allocations. It discourages actions that could cause fomo or buyer's remorse.

### Multi-token vault gas inefficiencies
Sushi was the first to offer transaction fees as rewards for holding it's governance token. The problem is all the fees are in the form of different tokens.
Therefore if you wanted to redeem your stake for it's underlying tokens, it would be incredibly expensive for utimately a very small piece of the pie.
This gas problem escalates the more *decentralized* a platform is. We can't allow this. We need a different system of distributing assets fairly that
does not rely on the actual value of it's assets. A seemingly ridiculous request yet worth pursuing.

### Accounting
Vault tokens make accounting much easier by encapsulating and isolating all transactions to a vault. However not being able to have more than one asset
per vault, offers no benefits. The existing multi-token approaches also hinder the viability unless you have a heavily centralized off-chain middleman.
Liquid vault allows unlimited assets to be stored while still allowing withdraws to happen.

### Bot-resistant
Bot's are not bad as long as they play on equal-footing with real people. Then they become a useful rival or tool for learning. We
often see this in games. One of the biggest complaint about the stock market is high-frequency trading. Many indicators point this
as the cause of the flash crash. Ultimately this is because we lost sight of actions, got emotional, and gave bots the power to act
upon it. Interactive Brokers decided to solve this by removing the ability to high-freq trade. We can take this even further by 
discouraging short-term trades all together but not how taxes cause bubbles.

### Anti-bubble


[EIP-7540](https://eips.ethereum.org/EIPS/eip-7540) effectively allow queueing of assets for deposits and withdraws. However in a crisis, we can quickly
see a share's value fluctuate.

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

MUST extend Solady ERC-20.

MUST extend OpenZeppelin ERC-173.

MUST partially implement [EIP-7535](https://eips.ethereum.org/EIPS/eip-7535)



## Rationale
This implementation is done with no budget, in my free time, and out of necessity. Priorities are set. Sacrifices are made.
Even though it's suppose to be practical, it is still designed to be a [hyperstructure](https://jacob.energy/hyperstructures.html).


Generally the goal is to only implement what's necessary for it's intended purpose.
Composability and Interoperability come SECOND to functionality.
The functionality of this contract is to produce efficient volume of it's token for as long as practically possible.

### FAQ
#### Why is it two bonding curves? Why not one bonding curve for both buying and selling?
Two bonding curves intentionally creates a spread and reverse-spread when liquidity is low.
Think of it like "happy hour" where the purpose is to encourage a consistent stream of volume.

#### Why was Solady's ERC-20 implementation chosen over SolMate or OpenZeppelin?
OpenZeppelin's priorities are to create incredibly safe contracts that protect from many different errors at the cost of gas efficiency.
SolMate is more gas optimized but any mistakes could be very costly. Solady is *even more* gas optimized because a lot of it 
is wrapped in assembly. I decided to use Solady because having volume is the number one priority of this contract. Thus the functionality
related to volume are *worth* optimizing to it's max potential. Everything else, such as ownership, can be handled with a more easily
auditable implementation.

#### Why is the full specification for ERC-4626 NOT implemented? Wouldn't this hinder interoperability?
ERC-4626 fails to have any OPTIONAL specs. Even under the ERC's *Rationale* section, they state `mint()` (hench also `withdraw()`) are only included for *symmetry*
and *completeness*. This is not worth the additional attack vectors.

#### Why was `asset()` not implemented?
[ERC-7528](https://eips.ethereum.org/EIPS/eip-7528) covers a lot of nuances that make it not worth implementing especially
when you start deploying it across other EVM chains. It's just one more thing that could go wrong for very little gain.
I rather the integrators figure out the asset off-chain. 
I think `asset()` should be OPTIONAL for native token assets and only necessary for ERC20 assets. Giving a native token an address feels very hackish.
Native tokens is part of the design. It's not going anywhere. We shouldn't try to pretend it's an ERC20 token. 
We're optimizing the wrong things. We should treat it special because it IS special AND we should put more effort in using it
instead of wrapping it. ERC20 is inferior to native tokens *not the other way around*.

#### Why not just modify an existing ERC-4626 implementation?
There's enough changes that it would require a full audit of the implementation *with* the modifications.
Just auditing a smaller set of features is less time-consuming.

#### If the owner can make custom calls, why not just make the contract upgradable?
Upgradable contracts sacrifice future composability for future interoperability.
It may seem similar in power but in fact, custom calls have a smaller scope compared to proxies. Custom calls cannot introduce new functionality or change existing behavior.
Upgrades SHOULD be audited and often require a FULL audit therefore cost just as much as the original audit.
Upgrades can also corrupt persistant data. It is a danger that can be more easily controlled with migrations instead.
Sure if I make it upgradable, then we can add modern interoperable features like UNIv4
in the future but we also can just wrap the vault with new features for those that *want* it. In fact upgrades make tokens less composable.
Immutable contracts also welcome the community to participate. No one can build on top of a shaky foundation.

#### Why was [ERC-7540](https://eips.ethereum.org/EIPS/eip-7540): Asynchronous Tokenized Vaults not implemented?
The two step process is only necessary if the value of a share must remain the same or if the assets cannot be gas-efficiently returned atomically.
Neither of the cases apply for this contract for such costly operations. It also leaves a lot of unanswered questions on how to deal with underwater debt

#### Why not just mint a bunch of tokens, add it to a liquidity pool, and then burn the LP tokens?

#### Why was `totalAssets()` not implemented?
There's too much uncertainty for what this function implies. 
Better to remove than to be misunderstood.
The erc states this SHOULD return assets plus any interest.
This implementation has no interest but it also allows the assets to be moved out of the contract.
Is this contract suppose to keep track of that? I think that is an expensive request with very little value.
It also defeats the purpose of much of this implementation.

## Backwards Compatibility
Will not be implementing `mint()` or `withdraw()`.

Will not be implementing `asset()`.

## Reference implementation
`GuanoCore.sol` holds the minimum features for the necessary functionality.

`GuanoExtra.sol` adds more features but is highly experimental and not tested what-so-ever. It's just a place to gather code.
It's equivalent to code on a piece of napkin.

Most people finalize their white papers before implementation but this will be the opposite. The implementation will be done FIRST
along with UX and auxilary functionality. This paper will be a work in progress for quite a long time after.

## Security Considerations
`assets` parameter is not used in `deposit()`. More details can be found in [ERC-7535](https://eips.ethereum.org/EIPS/eip-7535)

[ERC-5143](https://eips.ethereum.org/EIPS/eip-5143) slippage protection is NOT implemented. Prefer alternative approach stated in EIP.
