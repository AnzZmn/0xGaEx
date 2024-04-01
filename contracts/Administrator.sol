// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface IExProtocol {
    function Approve() external;
    function disapprove() external;
}

contract Administrator {
    constructor() {
        
    }
    function testCall(address contractAddress) external {
        IExProtocol(contractAddress).Approve();
    }
}