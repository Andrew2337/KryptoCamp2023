pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNftMapping is ERC721, Ownable {
    mapping(address => bool) public whitelist;
    uint256 public tokenId = 0;

    constructor() ERC721("NFT", "NFT") {}

    modifier verifyWhitelist() {
        require(whitelist[msg.sender], "Not whitelisted");
        _;
    }

    function whitelistMint() external verifyWhitelist {
        tokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function setWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = true;
        }
    }
}