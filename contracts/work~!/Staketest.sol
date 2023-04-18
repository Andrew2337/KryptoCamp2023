// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingContract {
    using SafeMath for uint256;

    IERC20 public tokenA;
    IERC20 public tokenAreward;
    uint256 Maxreward = 10000000000; //總獎勵
    uint256 Nowreward; //目前已發放獎勵
    uint256 rewardRate = 100; // 假設回報比例為100，質押1個tokenA，每過100秒可以拿到100個tokenB
    mapping(address => uint256) private tokenAstakedAmounts; //tokenA質押數量
    mapping(address => uint256) private HowLong; //質押時間

    //設定質押合約
    constructor(address _tokenA) {
        tokenA = IERC20(_tokenA);
        tokenAreward = IERC20(_tokenA);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");  //確認質押數量>0
        require(tokenA.balanceOf(msg.sender) >= _amount, "Insufficient balance"); //確認tokenA貸幣數量夠

        tokenA.transferFrom(msg.sender, address(this), _amount); //轉移token代幣至此合約
        tokenAstakedAmounts[msg.sender] = tokenAstakedAmounts[msg.sender].add(_amount); //新增tokenA質押數量
        HowLong[msg.sender] = block.timestamp; //質押的鏈上時間

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero"); //確認取出數量>0
        require(tokenAstakedAmounts[msg.sender] >= _amount, "Insufficient staked balance"); //確認要取出的tokenA貸幣數量夠

        uint256 time = (block.timestamp - HowLong[msg.sender]) / 100; //計算時間單位
        uint256 reward = tokenAstakedAmounts[msg.sender] * rewardRate * time; //計算tokenB獎勵
        Nowreward = Nowreward + reward; //計算當前獎勵發放數量
        tokenA.transfer(msg.sender, _amount); //提幣
        tokenAstakedAmounts[msg.sender].sub(_amount); //清除tokenA質押數量
        HowLong[msg.sender] = 0;    //清除時間

        if (Maxreward >= Nowreward)
        tokenAreward.transfer(msg.sender, reward);  //提幣

        emit Unstaked(msg.sender, _amount, reward);
    }

    function calculateReward() public view returns (uint256) {
        uint256 time = (block.timestamp - HowLong[msg.sender]) / 100; //計算時間單位

        return tokenAstakedAmounts[msg.sender] * rewardRate * time; //計算獎勵
    }

    function Checkstake () public view returns (uint256) {
        return tokenAstakedAmounts[msg.sender];
    }

    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount, uint256 reward);
}
