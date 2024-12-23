
### FAQ

#### Why doesn't `transfer()` burn tokens if it's transferred to the same contract?
ERC20 does not specify what should occur in this situation. There might be a case where we want
to track a balance of the token. Therefore if we do burn, it should be made explicit through
a separate function.