// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyCounter is Ownable {
    uint256 public number;

    event Incremented(uint256 newValue);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function increment() external onlyOwner {
        number += 1;
        emit Incremented(number);
    }
}
