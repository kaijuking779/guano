---

title: Capped-Flow Liquidity Pool

description: 

author: kaijuking779

created: 2024-12-11

requires: EIP-20, EIP-173

---

## Abstract
The main characteristic of this pool is that tokens cannot be sold beyond a rate set during creation. You can think of it like a valve.
The secondary characteristic is that the pool *always* has liquidity so long as it has liquidity providers.


## Motivation
Automated market makers (AMM) protocols currently are implemented very similar in that they are all centered around
one spot price for both buying and selling. This has resulted in problems such as sandwich attacks, impermanent loss,
and large liquidity requirements. Traditional order books don't have this problem because a spread naturally grows
and shrinks depending on the volume. However the conventional implementation would be too expensive to implement
on-chain. What we need is an AMM that has a spread built-in that can be adjusted periodically.

### Similarities
Continuous Dutch Auctions
https://www.paradigm.xyz/2022/04/gda

Time-weighted average price
https://en.wikipedia.org/wiki/Time-weighted_average_price

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

Naming conventions https://docs.soliditylang.org/en/latest/style-guide.html#naming-conventions

Liquidity provider (LP) MUST provide native ETH tokens to the pool in exchange for LP tokens pro rata.
The native ETH tokens will be sold over time in exchange for a token designated by the pool.
LP may redeem their LP tokens at anytime in exchange for a portion of the ETH and designated token pro rata.

The method in which the tokens are sold is up to the implementer but it's expected that the ratio of 
designated token MUST increase overtime. This means if tokens have already been exchanged, any future
LPs must contribute designated token to maintain the current ratio.
If this is not feasible, then a new pool should be created.

The rate at which ETH is sold is also customizable for maximum flexibility.
The actualy customization is defined by a hard cap and a soft cap.
Hard cap is the absolute maximum of flow that can happen over time.
Soft cap is a diminishing return where the number set is at 50% 

## Rationale

### FAQ
#### Why ERC20 instead of ERC1155?
Although ERC1155 would make it cheaper to create new pools, the cost of managing it increases because we have to 
record native ETH allocations for a pool during every swap.

#### Would the flexibility in pools cause liquidity fragmentation?
No. This is because this protocol was designed for increasing volume with *low* liquidity. This protocol WAS NOT
designed to compete with existing protocols such as uniswap or curve which specialize in stable coins.
It heavily relies on arbitrage bots to route between the different protocols.

#### Is this a dutch auction?
Dutch auctions are designed to empty out a supply as soon as possible. This pool has a max flow rate.

#### Why is the flow rate static and not dynamic to the liquidity provided?
Static flow rate discourages the price of the underlying token from fluctuating.
Increasing the flow can still be accomplished by creating a new pool. Since this is more costly, this will encourage planning ahead.
It is also cheaper to add/remove liquidity from a static flow since the flow doesn't need to be updated.

#### Why doesn't Aquitard keep tracking of tokens sold and bought similarly to how Pinus Vault works?
Pinus Vault swaps both ways where as Aquitard LPs only swap one way. Therefore the timestamp for Pinus Vault is used
for two completely different things and cannot be easily modified. Since Aquitard LPs are one way, we no longer need to keep track of
total swaps and just adjust the timestamp to control the flow when a swap occurs.

#### Why isn't ERC7575 used?
Although ERC7575 is for multiple assets for a vault, it requires a new contract for every asset.
It also removes ERC20 capabilities.

#### Why isn't ERC7535 used?
Even though it's for the native token, ERC7535 is designed for ONE asset. The `asset` variable can be used for ERC20 token
instead of the native token placeholder described under ERC7528. ERC7535 also cares more about interoperability with
ERC4626 than creating a standard that makes sense. This is equivalent to building standards to accomodate internet explorer.
Let the devs decide for themselves if they want to be interoperable. Let the standards be more standalone.

## Backwards Compatibility

## Reference implementation


## Security Considerations
Unlike existing AMMs, the ratio of tokens DOES NOT reflect the prices of the tokens!

Inflation attack is NOT handled. I feel it's up to the frontend to make sure there's
proper warning for low share count pools. Plus we typically operate at 18 decimal places.
The attack would have to target practically abandoned pools which in itself would not be worth anyones time to target.
Not to mention it has to frontrun a deposit on top of that.
https://docs.openzeppelin.com/contracts/5.x/erc4626