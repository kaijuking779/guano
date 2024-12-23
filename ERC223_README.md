
### FAQ

#### Why is ERC20s `transfer(address to, uint value)` not overwritten?
Although this function has cost significant losses for the community and it's clearly a flaw in
the design of the specification, it is nonetheless expected that transferring to a contract would be successful.
I still wish to implement ERC20 so the compromise is to only implement `transfer(address to, uint value, calldata data)`
since the parameters imply a different behavior due to the 3rd parameter.

#### Why did I remove checking if it's a contract?
I want the caller to figure out if they are calling a contract or not and call the correct function.
Any unintended behaviors should be handled at a layer above off-chain.

My implementation implies it will not call `tokenReceived()`.
If you call `transfer()` with the third parameter, I want the caller to explicitly understand what
they are doing.