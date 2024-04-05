// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract Administrator is Ownable, AccessControl{

    event generatePass(string Email);

    constructor() Ownable(_msgSender()){
    }

    function callScript(string memory _email) external{
        emit generatePass(_email);
    }

    
}