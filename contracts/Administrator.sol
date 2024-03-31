// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract Administrator {
    constructor() {
        
    }
    function testCall(address contractAddress) external {
        bytes memory data = abi.encodeWithSignature("Approve()");
        (bool s,) = contractAddress.call(data);
        require(s);
    }
}