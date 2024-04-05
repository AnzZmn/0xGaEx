// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Context.sol";

contract ExProtocol is Context{
    

    address private immutable tokenContractAddress;

    address private immutable adminContarct;

    uint256 public immutable tokenId;

    string private associatedEmail;

    address public currentOwner;

    string private pass;

    bool isListed;

    struct Trade {

        address buyer;

        address  seller;

        uint256  amount;

        uint256  royaltyAmount;

        address royaltyReciever;

        bool isExecuted;

    }

    Trade private trade;

    // @params tokenId: TokenId of the GToken
    constructor(uint256 _tokenId, address contractAddress, address _adminContarct,string memory _emailAddress){
        adminContarct = _adminContarct;
        currentOwner = _msgSender();
        tokenContractAddress = contractAddress;
        tokenId = _tokenId;
        associatedEmail = _emailAddress;
        isListed = false;
    }

    function listToken() public {
        if(_msgSender() != currentOwner){
            revert();
        }
        isListed = true;
    }

    function initializeTrade(uint256 _amount) external payable{
        if(!isListed){
            revert();
        }
        if(msg.value < _amount){
            revert();
        }

        (address reciever, uint256 royalty) = _getInfo(_amount);
        trade.amount = _amount;
        trade.buyer = _msgSender();
        trade.seller = currentOwner;
        trade.royaltyAmount = royalty;
        trade.royaltyReciever = reciever;
        trade.isExecuted = false;
    }

    function _getInfo(uint256 _amount) internal returns(address,uint256){
        bytes memory data = abi.encodeWithSignature("royaltyInfo(uint256,uint256)",tokenId,_amount);
        (bool s, bytes memory returnData) = tokenContractAddress.call(data);
        if(!s){
            revert();
        }
        (address reciever, uint256 royalty) = abi.decode(returnData, (address,uint256));
        return (reciever,royalty);
    }

    function _executeTrade() internal {
        bytes memory data = abi.encodeWithSignature("transferFrom(address,address,uint256)",trade.seller,trade.buyer,trade.amount);
        (bool s,) = tokenContractAddress.call(data);
        if(!s){
            revert();
        }
        (bool se,) = payable(trade.seller).call{value: trade.amount }("");
        (bool  ro,) = payable(trade.royaltyReciever).call{value: trade.royaltyAmount }("");
        (bool ad,) = payable(adminContarct).call{value: address(this).balance}("");
        if(!se || !ro || !ad){
            revert();
        }
        
    }

    function _getPass() internal view returns(string memory){
        if(_msgSender()!= currentOwner){
            revert();
        }
        return pass;
    }

    function _setPass(string calldata _pass) internal{
        pass = _pass;
    }


}