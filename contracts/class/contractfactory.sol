// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyToken is ERC20 {
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_
    ) ERC20(name, symbol) {
        _decimals = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract MyNFT is ERC721 {
    uint256 public tokenId = 0;
    address public owner;

    using Strings for uint256;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mint() external {
        tokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        // 填入 ipfs 網址
        return "";
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")) : "";
    }
}

contract ContractFactory {
    address[] public tokens;
    address[] public nfts;

    event TokenCreated(address token);
    event NFTCreated(address nft);

    function createToken(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) external returns (address) {
        MyToken token = new MyToken(name, symbol, decimals);
        tokens.push(address(token));
        emit TokenCreated(address(token));
        return address(token);
    }

    function createNFT(string memory name, string memory symbol) external returns (address) {
        MyNFT nft = new MyNFT(name, symbol);
        nfts.push(address(nft));
        emit NFTCreated(address(nft));
        return address(nft);
    }
}