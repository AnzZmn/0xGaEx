// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Administrator is Ownable{

    constructor() Ownable(_msgSender()){
    }
}