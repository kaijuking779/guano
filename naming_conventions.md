# Style Guide

This protocol will be using the [official style guide](https://docs.soliditylang.org/en/v0.8.28/style-guide.html#) 
from solidity as a base and anything additional will be added here.

## Using ERC

Often, implementing the entire ERC can be more of a headache than implementing it partially.

## Interfaces

Interfaces are a great way to group related functions.

## Functions

Do not overload functions just to set defaults. There should be more to the function such as hooks.

If there are more than 3 parameters of the same type in a row, use structs to group related parameters.
This will help the compiler find errors.

### Scope
Try to keep functions either external or internal whenever possible. This way public implies it actually
is being used within the contract.


### Get Functions

Do not prefix "get" for get functions. There are more than enough indicators that it's a get function
in solidity. You're already forced to use view or pure.