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

    // List the Token for Sale
    function listToken() public {

        // Checking wheather the caller is owner or not
        if(_msgSender() != currentOwner){
            revert();
        }
        isListed = true;
    }

    function initializeTrade(uint256 _amount) external payable{
        //  Ensure the Token is Listed
        if(!isListed){
            revert();
        }
        // Ensure the message value is equal to the amount payable
        if(msg.value < _amount){
            revert();
        }

        // Getting Royalty Details
        (address reciever, uint256 royalty) = _getInfo(_amount);

        // Setting the Trade Struct with new variables
        trade.amount = _amount;
        trade.buyer = _msgSender();
        trade.seller = currentOwner;
        trade.royaltyAmount = royalty;
        trade.royaltyReciever = reciever;
        trade.isExecuted = false;
    }

    /**
     *  Calls the Token Contract and recieves the Royalty Information
     * @param _amount : The Sale Value that the Buyer and Seller Agreed Upon
     * @return  (reciever, royalty) : The Reciever Address And Royalty Amount
     * */
    function _getInfo(uint256 _amount) internal returns(address,uint256){
        bytes memory data = abi.encodeWithSignature("royaltyInfo(uint256,uint256)",tokenId,_amount);
        (bool s, bytes memory returnData) = tokenContractAddress.call(data);
        if(!s){
            revert();
        }
        (address reciever, uint256 royalty) = abi.decode(returnData, (address,uint256));
        return (reciever,royalty);
    }

    /**
     * Executes the Trade by Transferring the payables
     */
    function _executeTrade() internal {

        // call trasferFrom function from the tokenContract
        bytes memory data = abi.encodeWithSignature("transferFrom(address,address,uint256)",trade.seller,trade.buyer,trade.amount);
        (bool s,) = tokenContractAddress.call(data);
        if(!s){
            revert();
        }

        //  Calculate Admin Fee And Seller Amount
        (uint256 _adminFee, uint256 _forSeller) = _feeCalculation(trade.amount, trade.royaltyAmount);

        //  initiate payments for the recipients
        (bool se,) = payable(trade.seller).call{value: _forSeller }("");
        (bool  ro,) = payable(trade.royaltyReciever).call{value: trade.royaltyAmount }("");
        (bool ad,) = payable(adminContarct).call{value: _adminFee}("");
        if(!se || !ro || !ad){
            revert();
        }
        //TODO:
        //Invoke the  Admin Contract to generate new Pass for the corresponding Email
        
    }

    function _feeCalculation(uint256 _amount, uint256 _royalty) internal pure returns(uint256,uint256){
        uint256 _adminFee = (_amount * 25) /1000;
        uint256 _forSeller = _amount - _royalty - _adminFee;
        return (_adminFee,_forSeller);
    } 

    /**
     * For Retrieving the Password of the Email
     */
    function _getPass() internal view returns(string memory){
        if(_msgSender()!= currentOwner){
            revert();
        }
        return pass;
    }

    /**
     *  For Setting the Password Value
     * @param _pass : The Provided Password Value
     */
    function _setPass(string calldata _pass) internal{
        pass = _pass;
    }


}