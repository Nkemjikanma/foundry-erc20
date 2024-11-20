// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    // if an inherited contract has a constructor, we must use that in our contructor

    constructor(uint256 initialSupply) ERC20("Our Token", "OUR") {
        _mint(msg.sender, initialSupply);
    }
}
