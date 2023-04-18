pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNftMerkleTree is ERC721 {
    bytes32 public root;
    address public owner;
    uint256 public tokenId = 0;

    constructor() ERC721("NFT", "NFT") {
        owner = msg.sender;
    }

    modifier verifyProof(bytes32[] memory proof) {
        require(MerkleProof.verify(proof, root, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");
        _;
    }

    function whitelistMint(bytes32[] calldata _proof) external verifyProof(_proof) {
        tokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function verify(bytes32[] memory proof) external view returns (bool) {
        return MerkleProof.verify(proof, root, keccak256(abi.encodePacked(msg.sender)));
    }

    function setRoot(bytes32 _root) external {
        require(msg.sender == owner, "Only owner can set root");
        root = _root;
    }
}