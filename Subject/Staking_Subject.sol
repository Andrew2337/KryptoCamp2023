// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "./ERC-20_subject.sol";
import "./ERC-721A_subject.sol";


contract TokenStaking {
    mapping(address => uint256) public stakedBalances;
    ERC20 public token;
    uint256 public minStakeAmount;

    event Staked(address indexed from, uint256 amount);
    event Unstaked(address indexed from, uint256 amount);

    constructor(ERC20 _token, uint256 _minStakeAmount) {
        token = _token;
        minStakeAmount = _minStakeAmount;
    }

    //質押代幣
    function stake(uint256 amount) public payable {
        require(amount >= minStakeAmount, "Amount is below minimum stake amount");
        require(token.transfer(address(this), amount), "Token transfer failed");

        stakedBalances[msg.sender] += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) public payable{
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");

        require(token.transfer(msg.sender, amount), "Token transfer failed");

        stakedBalances[msg.sender] -= amount;

        emit Unstaked(msg.sender, amount);
    }

    function calculateReward() public view returns (uint256) {
        
    }
}




contract NFTStaking {

    IERC721 private NFTToken;
    address Owner;
    uint256 StakeRewardConstant; //質押獎勵常數
    uint256 StakeNumLimit; //質押數量限制

    constructor(IERC721 _NFTToken){
        NFTToken = _NFTToken;
        Owner = msg.sender;       
    }

    uint256 tokenID;

    //質押變數，以結構表示並以mapping查詢(質押地址、開始時間、質押時間、結束時間、質押數量、總收益、質押NFT編號)
    struct stakeinfo {
        address Staker;
        uint256 Starttime;
        uint256 Staketime;
        uint256 totalReward;
    }

    mapping (address => uint256[]) public StakeMap;
    mapping (uint256 => stakeinfo) public StakeInfo;

    event ChecktotalReward(uint256 Reward);

    //質押NFT
    function Stake (uint _tokenId) public {
        require(NFTToken.ownerOf(_tokenId) == msg.sender, "NFTStaking: caller is not NFT owner");
        
        uint256 tokenId = _tokenId;
        NFTToken.safeTransferFrom(msg.sender, address(this), tokenId);
        StakeMap[msg.sender].push(tokenId);
        StakeInfo[_tokenId].Staker = msg.sender;
        StakeInfo[_tokenId].Starttime = block.timestamp;
    }
    //查看賺取的收益
    function CheckReward (uint _tokenId) public returns(uint256) {
        require(NFTToken.ownerOf(_tokenId) == msg.sender, "NFTStaking: caller is not NFT owner");
        uint256 tokenId = _tokenId;
        
        StakeInfo[tokenId].Staketime = block.timestamp - StakeInfo[tokenId].Starttime;
        StakeInfo[tokenId].totalReward = StakeRewardConstant * StakeInfo[tokenId].Staketime;
        uint256 TotalReward = StakeInfo[tokenId].totalReward;
        return(TotalReward);

        emit ChecktotalReward(TotalReward);

    }
    //查看質押NFT項目
    function CheckStakeNFT() public view returns (uint256[] memory) {
        uint256[] memory StakeNFT = StakeMap[msg.sender];
        return StakeNFT;
    }
    //取回NFT
    function UnStake (uint _tokenId) public {
        require(NFTToken.ownerOf(_tokenId) == msg.sender, "NFTStaking: caller is not NFT owner");
        
        uint256 tokenId = _tokenId;
        NFTToken.safeTransfer(msg.sender, tokenId);
        StakeMap[msg.sender].push(tokenId);
        StakeInfo[_tokenId].Staker = msg.sender;
        StakeInfo[_tokenId].Starttime = block.timestamp;
    }
    //查看賺取的收益
    //設定質押獎勵常數




}





import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract NFTStaking11 is ERC721Holder {
    struct Stake {
        address staker;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 rewardPerSecond;
        uint256 totalReward;
        uint256 withdrawableReward;
        bool withdrawn;
    }

    mapping(address => Stake[]) public stakes;

    IERC721 public nftToken;
    uint256 public totalRewards;

    event Staked(address indexed staker, uint256 indexed tokenId, uint256 startTime, uint256 endTime);
    event Unstaked(address indexed staker, uint256 indexed tokenId, uint256 withdrawableReward);

    constructor(IERC721 _nftToken) {
        nftToken = _nftToken;
    }

    function stake(uint256 _tokenId, uint256 _durationInSeconds, uint256 _rewardPerSecond) public {
        require(nftToken.ownerOf(_tokenId) == msg.sender, "NFTStaking: caller is not NFT owner");
        require(_durationInSeconds > 0, "NFTStaking: duration must be greater than zero");

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _durationInSeconds;
        uint256 totalReward = _durationInSeconds * _rewardPerSecond;

        nftToken.safeTransferFrom(msg.sender, address(this), _tokenId);
        stakes[msg.sender].push(Stake(msg.sender, _tokenId, startTime, endTime, _rewardPerSecond, totalReward, 0, false));

        totalRewards += totalReward;

        emit Staked(msg.sender, _tokenId, startTime, endTime);
    }

    function unstake(uint256 _index) public {
        Stake storage stake = stakes[msg.sender][_index];

        require(!stake.withdrawn, "NFTStaking: reward already withdrawn");
        require(stake.endTime <= block.timestamp, "NFTStaking: stake not yet ended");

        uint256 withdrawableReward = stake.totalReward - stake.withdrawableReward;
        stake.withdrawableReward = stake.totalReward;
        stake.withdrawn = true;

        nftToken.safeTransferFrom(address(this), msg.sender, stake.tokenId);

        emit Unstaked(msg.sender, stake.tokenId, withdrawableReward);
    }

    function getStakeCount(address _staker) public view returns (uint256) {
        return stakes[_staker].length;
    }

    function getStake(address _staker, uint256 _index) public view returns (Stake memory) {
        return stakes[_staker][_index];
    }

    function getWithdrawableReward(address _staker, uint256 _index) public view returns (uint256) {
        Stake memory stake = stakes[_staker][_index];

        if (stake.withdrawn || stake.endTime > block.timestamp) {
            return 0;
        }

        uint256 elapsedSeconds = block.timestamp - stake.startTime;
        uint256 withdrawableReward = elapsedSeconds * stake.rewardPerSecond - stake.withdrawableReward;

        return withdrawableReward;
    }
}
