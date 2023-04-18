// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721 {
    address private Owner;
    uint256 public tokenId = 0;
    uint8 public _MaxNftNum = 100;
    using Strings for uint256;

    constructor(
        string memory _name,
        string memory _symbol
        ) ERC721(
            _name,
            _symbol
            ) {
                Owner = msg.sender;
            }

    //設定總供應量只有100張
    modifier MaxNftNum() {
        require( tokenId <= _MaxNftNum ,"The NFT had sellout.");
        _;
    }

    //mint NFT
    function mint() external MaxNftNum{
        tokenId++;
        _safeMint(msg.sender, tokenId);
    }



    function _baseURI() internal pure override returns (string memory) {
        return "";
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")) : "";
    }
}