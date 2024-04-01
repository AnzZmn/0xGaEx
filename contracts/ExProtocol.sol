// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";



contract ExProtocol {
    address private immutable TokenContract;

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

    error ErrorCallingContract(address);

    event contractDeployed(address indexed buyer, address indexed seller,address indexed approver, uint256 tokenId, uint256 amount );

    event GTokenSale(address indexed buyer, address indexed seller, uint256 tokenId, uint256 amount, uint256 royalty, bool);

    // @params tokenId: TokenId of the GToken
    // @params _amount: Agreed Upon Exchange Value
    constructor(uint256 _tokenId, uint256 _amount, address contractAddress) payable {
        if(msg.value < _amount){
            revert InsufficientBalance(msg.value);
        }
        RoyaltyContarct = IERC2981(contractAddress);
        TokenContract = contractAddress;
        bytes memory _approverData = abi.encodeWithSignature("getApproved(uint256)",_tokenId);
        (bool r, bytes memory _ApproverAddress) = TokenContract.call(_approverData);
        if(!r){
            revert ErrorCallingContract(TokenContract);
        }
        address _returnedAppover = abi.decode(_ApproverAddress, (address));
        approver = _returnedAppover;
        if(msg.sender == approver){
            revert bothSenderAndApproverSame(msg.sender);
        }


        bytes memory data = abi.encodeWithSignature("ownerOf(uint256)",_tokenId);
        (bool s, bytes memory returnData) = TokenContract.call(data);
        if(!s){
            revert ErrorCallingContract(TokenContract);
        }

        address _returnAddress = abi.decode(returnData, (address));

        seller = _returnAddress;




        if(seller == address(0)){
            revert NoTokenOwner(_tokenId);
        }
        

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

        bytes memory data = abi.encodeWithSignature("safeTransferFrom(address,address,uint256)",seller,reciever,tokenId);
        (bool d,) = TokenContract.delegatecall(data);
        require(d,"Delegate Call Failed");
        
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