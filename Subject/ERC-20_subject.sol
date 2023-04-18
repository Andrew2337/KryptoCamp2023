// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract FirstToken is ERC20{

    bytes32 public root;
    address private Owner;
    uint8 private decimals_;
    uint256 private _totalSupply;
    uint256 private _TokentotalSupply;


    uint256 private WhitelistMaxNumberofToken;  //白名單最大mint數量
    uint256 private PublicMaxNumberofToken;     //公售最大mint數量
    uint256 private WhitelistMintPrice;         //白名單mint價格
    uint256 private PublicMintPrice;            //公售mint價格

    mapping (address => bool) private Whitelist; //紀錄是否為白名單
    constructor(
        string memory name,
        string memory symbol,
        uint8 _decimals,
        uint256 TokentotalSupply
        ) ERC20(name, symbol){
        decimals_ = _decimals;
        Owner = msg.sender;
        _TokentotalSupply = TokentotalSupply;
        
    }

    modifier onlyOwner() {
        require( msg.sender == Owner ,"This function only owner can use.");
        _;
    }


    //總量設定
    modifier TokenLimit() {
        require(_TokentotalSupply >= _totalSupply , "It's over Token limit!!");
        _;

    }
    
    //小數點設定
    function decimals() public view override returns (uint8) {
        return decimals_;
    }

    //公售mint Token
    function mint(uint256 AmountofPublicToken) external onlyOwner TokenLimit payable{
        require(msg.sender != address(0) , "Your address is not exist");  
        require(msg.value >= AmountofPublicToken * PublicMintPrice, "the balance is not enough."); //判斷傳入的錢是否大於代幣mint總價格
        uint256 ExtraMoney = msg.value - AmountofPublicToken * PublicMintPrice; //多餘的錢
        _mint(msg.sender , AmountofPublicToken);//發送代幣
        payable(msg.sender).transfer(ExtraMoney); //將多餘的錢退款
        
    }

    //燒毀代幣，只限合約擁有者
    function burn(address from, uint256 amount) external onlyOwner TokenLimit {
        _burn (from, amount);
    }

    //設定白名單最大mint份額
    function SetWhitelistMaxNumberofToken(uint256 _WhitelistMaxNumberofToken) external onlyOwner {
        WhitelistMaxNumberofToken = _WhitelistMaxNumberofToken;
    }

    //設定公售最大mint份額
    function SetPublicMaxNumberofToken(uint256 _PublicMaxNumberofToken) external onlyOwner {
        PublicMaxNumberofToken = _PublicMaxNumberofToken;
    }

    //設定白名單mint Token價格
    function SetWhitelistMintPrice(uint256 _WhitelistMintPrice) external onlyOwner {
        WhitelistMintPrice = _WhitelistMintPrice;
    }

    //設定公售mint Token價格
    function setPublicMintPrice(uint256 _PublicMintPrice) external onlyOwner {
        PublicMintPrice = _PublicMintPrice;
    }


    //白名單MerkleTree

    modifier verifyProof(bytes32[] memory proof) {
        require(MerkleProof.verify(proof, root, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");
        _;
    }

    //檢查是否為白名單地址(要先按才可以執行whitelistMint)
    function CheckwhitelistMint(bytes32[] calldata _proof) external verifyProof(_proof) {
      Whitelist[msg.sender] = true;
    }

    //白名單mint Token，輸入需mint的數量，不可大於最大白名單mint數量
    function whitelistMint(uint256 AmountofWhitelistToken) external payable TokenLimit{ 
        require(Whitelist[msg.sender] == true , "Your address is not in Whitelist~");   //確認是否在白名單內
        require(msg.value >= AmountofWhitelistToken * WhitelistMintPrice, "the balance is not enough."); //判斷傳入的錢是否大於代幣mint總價格
        uint256 ExtraMoney = msg.value - AmountofWhitelistToken * WhitelistMintPrice; //多餘的錢
        _mint(msg.sender , AmountofWhitelistToken);//發送代幣
        payable(msg.sender).transfer(ExtraMoney); //將多餘的錢退款
    }

    function verify(bytes32[] memory proof) external view returns (bool) {
        return MerkleProof.verify(proof, root, keccak256(abi.encodePacked(msg.sender)));
        
    }

    function setRoot(bytes32 _root) external {
        require(msg.sender == Owner, "Only owner can set root");
        root = _root;
    }
}

