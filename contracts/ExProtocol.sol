// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";



contract ExProtocol {
    address private immutable Administrator;

    IERC721 private immutable contract721;

    IERC2981 private immutable RoyaltyContarct;

    address private immutable approver;

    address private buyer;

    address private seller;

    uint256 private amount;

    uint256 private tokenId;

    uint256 private royaltyAmount;

    error InsufficientBalance(uint256);

    error NoTokenOwner(uint256);

    error UnauthorizedCall(address);

    error bothSenderAndApproverSame(address);

    event contractDeployed(address indexed buyer, address indexed seller,address indexed approver, uint256 tokenId, uint256 amount );

    event GTokenSale(address indexed buyer, address indexed seller, uint256 tokenId, uint256 amount, uint256 royalty, bool);

    // @params tokenId: TokenId of the GToken
    // @params _amount: Agreed Upon Exchange Value
    constructor(uint256 _tokenId, uint256 _amount, address contractAddress, address _approver) payable {
        
        if(msg.sender == _approver){
            revert bothSenderAndApproverSame(msg.sender);
        }
        if(msg.value < _amount){
            revert InsufficientBalance(msg.value);
        }

        contract721 =  IERC721(contractAddress);
        RoyaltyContarct = IERC2981(contractAddress);
        seller = contract721.ownerOf(_tokenId);
        if(seller == address(0)){
            revert NoTokenOwner(tokenId);
        }
        
        approver = _approver;
        tokenId = _tokenId;
        buyer = msg.sender;
        amount = _amount;

        emit contractDeployed(buyer, seller, approver, tokenId,  amount);
    }
    

    function Approve() external { 
        if(msg.sender != approver){
            revert UnauthorizedCall(msg.sender);
        }
        (address reciever,uint256 royalty) = RoyaltyContarct.royaltyInfo(tokenId, amount);
        uint256 commission = (  address(this).balance * 25 )   /   1000;
        uint256 transferableBalance = address(this).balance - commission - royalty;

        contract721.safeTransferFrom(seller, buyer, tokenId);

        (bool s,) = payable(reciever).call{ value: royalty }("");
        (bool y,) = payable(seller).call{value: transferableBalance}("");
        require(s && y);

        
        
        emit GTokenSale(buyer, seller, tokenId, amount, royalty, true);

        selfdestruct(payable(approver)); 

    }
    
    function disapprove() external {
        if(msg.sender != approver){
            revert UnauthorizedCall(msg.sender);
        }
        emit GTokenSale(buyer, seller, tokenId, amount, uint256(0) , false);
        selfdestruct(payable(buyer));
    }










}