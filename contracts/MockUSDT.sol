// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20 {
    constructor() ERC20("Mock USDT", "mUSDT") {
        _mint(msg.sender, 1000000 * 10**18); // Mint 1 million mock USDT to the deployer for testing
    }
}
