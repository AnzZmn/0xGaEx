// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract GToken is ERC721, ERC721URIStorage, ERC721Royalty {
    address private immutable Administrator;

    string private BaseURI;

    error OnlyCallByEscrow(address);

    constructor(string memory name, string memory symbol, string memory baseUri, address _administrator) ERC721(name, symbol) {
        Administrator = _administrator;
        BaseURI = baseUri;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

        // Explicitly override the tokenURI function.
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721 , ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // Override this function to mint tokens and set their URIs
    function _mintToken(address to, uint256 tokenId, string memory _tokenURI, address royaltyRecipient, uint96 royaltyValue) internal {
        _mint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        // Set royalty information using ERC721Royalty's _setTokenRoyalty function
        _setTokenRoyalty(tokenId, royaltyRecipient, royaltyValue);
        approve(Administrator, tokenId);
    }

    // Example function to mint a new token with royalty
    function mint(address to, uint256 tokenId, string calldata _tokenURI, address royaltyRecipient, uint96 royaltyValue) external {
        _mintToken(to, tokenId, _tokenURI, royaltyRecipient, royaltyValue);
    }


    // Override the BaseURI
    function _baseURI() internal view virtual override returns(string memory){
        return BaseURI;
    } 


    function baseURI() external view returns(string memory){
        return _baseURI();
    }

    // function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721,IERC721) {
    //     revert OnlyCallByEscrow(msg.sender);
    // }

    function _feeDenominator() internal pure virtual override returns (uint96) {
        return 100;
    }
}


