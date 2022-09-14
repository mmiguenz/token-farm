// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    constructor() ERC20("LPToken", "LP") {
        _mint(msg.sender, 100e18);
    }
}