// SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

contract FallbackExample {
    uint256 public result;

    // Don't need the 'function' declared before receivve, solidity knows its a special function
    // contract needs to not have any data(calldata) associated with it or receive will not trigger
    receive() external payable {
        result = 1;
    }
    fallback() external payable {
        result = 2;
    }
}