// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";


contract MyNFT is ERC721A {
    address private Owner;
    uint256 public tokenId = 0;
    bytes32 public root;

    using Strings for uint256;

    //白單mint價格變數
    uint256 public whitelistMintPrice;
    //最大供應量變數
    uint public _MaxNftNum;
    

    //公售荷蘭拍變數 
    uint256 startPrice;
    uint256 endPrice;
    uint256 StepOfPrice;
    uint256 startTime;
    uint256 StepOfTime;
    uint256 step;

    //合約擁有者只有部屬人
    constructor(string memory _name, string memory _symbol) ERC721A(_name, _symbol) {
        Owner = msg.sender;
    }

    //合約擁有人修飾詞
    modifier onlyOwner() {
        require( msg.sender == Owner ,"This function only owner can use.");
        _;
    }

    //設定總供應量只有x張
    modifier MaxNftNum() {
        require( tokenId <= _MaxNftNum ,"The NFT had sellout.");
        _;
    }

    //確認Proof正確的修飾詞
    modifier verifyProof(bytes32[] memory proof) {
        require(MerkleProof.verify(proof, root, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");
        _;
    }

    //設定荷蘭拍賣參數，只有合約部屬人可以輸入
    function setDutchAuction(
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _StepOfPrice,
        uint256 _startTime,
        uint256 _StepOfTime,
        uint256 _step
    ) public onlyOwner{
        startPrice = _startPrice;
        endPrice =_endPrice;
        StepOfPrice = _StepOfPrice;
        startTime = _startTime;
        StepOfTime = _StepOfTime;
        step = _step;
    }

    //取得目前價格
    function getNowPrice() public view returns(uint256) {
        uint256 Nowprice;
        uint Num = (block.timestamp - startTime) / StepOfTime;
        if(step >= Num){
        Nowprice = startPrice - Num * StepOfPrice;
        }
        else{
        Nowprice = endPrice;
        }

        return Nowprice;
    }

    //公售，使用荷蘭拍買法
    function mint(uint256 _amount) external payable MaxNftNum{
        require( msg.value >= (_amount * getNowPrice()), "Balance is not enough to mint." ); //確認是否夠錢
        uint256 mintExtraMoney = msg.value - (_amount * getNowPrice()); //多餘的錢
        _safeMint(msg.sender, _amount); //mint多少個NFT
        payable(msg.sender).transfer(mintExtraMoney); //將多餘的以太退款
    }

    //設定最大發行量(10張)
    function setMaxNftNum(uint MaxNftNum_) external onlyOwner{
        _MaxNftNum = MaxNftNum_;
    }

    //設定白單mint價格
    function setwhitelistMintPrice(uint _whitelistMintPrice) external onlyOwner{
        whitelistMintPrice = _whitelistMintPrice;
    }

    function getblocktime() public view returns(uint){
        return block.timestamp;
    }

    //計算剩餘NFT
    function leftNFTNum() public view returns(uint256){
        uint256 _leftNFTNum = _MaxNftNum - tokenId;
        return _leftNFTNum;
    }

    //NFT連結
    function _baseURI() internal pure override returns (string memory) {
        return "";
    }

    //NFT，json檔案連結
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (!_exists(_tokenId)) revert ("URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")) : "";
    }

    function Checkwhitelist(bytes32[] calldata _proof) external verifyProof(_proof) MaxNftNum {
        
    } 

    //白名單mint
    function whitelistMint(bytes32[] calldata _proof) external payable verifyProof(_proof) MaxNftNum {
        
        require(msg.value >= whitelistMintPrice, "the balance is not enough."); //判斷傳入的錢是否大於白單mint價格
        uint256 ExtraMoney = msg.value - whitelistMintPrice; //多餘的錢
        tokenId++;
        _safeMint(msg.sender, tokenId);
        payable(msg.sender).transfer(ExtraMoney); //將多餘的錢退款
    } 


    //傳入Proof
    function verify(bytes32[] memory proof) external view returns (bool) {
        return MerkleProof.verify(proof, root, keccak256(abi.encodePacked(msg.sender)));
    }

    //設定root
    function setRoot(bytes32 _root) external onlyOwner{
        root = _root;
    }
}