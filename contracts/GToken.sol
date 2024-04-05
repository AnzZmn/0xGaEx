// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";

contract GToken is ERC721URIStorage, ERC721Royalty {

    address private immutable Administrator;

    string private BaseURI;

    mapping(address owner => uint256) private _balances;

    constructor(string memory name, string memory symbol, string memory baseUri, address _administrator) ERC721(name, symbol) {
        Administrator = _administrator;
        BaseURI = baseUri;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

        // Explicitly override the tokenURI function.
    function tokenURI(uint256 tokenID)
        public
        view
        virtual
        override(ERC721 , ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenID);
    }

    // Override this function to mint tokens and set their URIs
    function _mintToken(address to,uint256 tokenId,string memory _tokenURI, address royaltyRecipient, uint96 royaltyValue) internal {
        if(_balances[_msgSender()] == 0){
            setApprovalForAll(Administrator,true);
        }

        _mint(to, tokenId);

        _setTokenURI(tokenId, _tokenURI);

        // Set royalty information using ERC721Royalty's _setTokenRoyalty function
        _setTokenRoyalty(tokenId, royaltyRecipient, royaltyValue);
    }

    // Example function to mint a new token with royalty
    function mint(uint256 _tokenId,string calldata _tokenURI, uint96 royaltyValue) external {
        _mintToken(_msgSender(), _tokenId, _tokenURI, _msgSender(), royaltyValue);
    }


    // Override the BaseURI
    function _baseURI() internal view virtual override returns(string memory){
        return BaseURI;
    } 


    function baseURI() external view returns(string memory){
        return _baseURI();
    }

    function _feeDenominator() internal pure virtual override returns (uint96) {
        return 100;
    }

}


