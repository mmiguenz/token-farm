// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./DappToken.sol";
import "./LPToken.sol";

/**
    A super simple token farm 
*/

contract TokenFarm {
    // State variables

    string public name = "Simple Token Farm";

    address public owner;
    IERC20 public dappToken; //mock platform reward token
    IERC20 public lpToken; // mock LP Token staked by users

    // rewards per block
    uint256 public constant REWARD_PER_BLOCK =1e18;
    uint256 public totalStaked = 0;
    // iterable list of staking users
    address[] public stakers;

    // mappings: users staking and rewards info
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public pendigRewards;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    // Events - add events as needed
    event Staked(address indexed _from, uint256 _value);
    event Withdrawn(address indexed _from, uint256 _value);
    event Reward(address indexed _to, uint256 _value);
    event RewardTransfered(address indexed _to, uint256 _value);

    /**
        constructor
     */
    constructor(address _dappToken, address _lpToken) {
        owner = msg.sender;
        dappToken = IERC20(_dappToken);
        lpToken = IERC20(_lpToken);
    }

    /**
     @notice Deposit
     Users deposits LP Tokens
     */
    function deposit(uint256 _amount) public {
        // Require amount greater than 0
        require(_amount > 0, "Deposit amount should be greater than 0");

        require(lpToken.balanceOf(msg.sender) >= _amount, "insuficient funds");

        distributeRewards(msg.sender);

        // Trasnfer Mock LP Tokens to this contract for staking
        bool succces = lpToken.transferFrom(msg.sender, address(this), _amount);

        if (!succces) {
            revert();
            return;
        }
        // Update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        totalStaked = totalStaked + _amount;
        // Add user to stakers array only if they haven't staked already

        // Update staking status
        if (!isStaking[msg.sender]) {
            stakers.push(msg.sender);
            isStaking[msg.sender] = true;
        }      
        // emit some event
        emit Staked(msg.sender, _amount);
    }  

    /**
     @notice Withdraw
     Unstaking LP Tokens (Withdraw all LP Tokens)
     */
    function withdraw() public {
        require(isStaking[msg.sender], "user is not currently staking");
        // Fetch staking balance
        uint256 balance = stakingBalance[msg.sender];

        // Require amount greater than 0
        require(balance > 0, "staker balance should be greater than 0");

        // calculate rewards before reseting staking balance

        distributeRewards(msg.sender);

        // Reset staking balance
        stakingBalance[msg.sender] = 0;
        totalStaked = totalStaked - balance;
        // Update staking status
        isStaking[msg.sender] = false;

        // Transfer LP Tokens to user
        lpToken.transfer(msg.sender, balance);       
      
        // emit some event
        emit Withdrawn(msg.sender, balance);
    }

    /**
     @notice Claim Rewards
     Users harvest pendig rewards
     Pendig rewards are minted to the user
     */
    function claimRewards() public {
        uint256 pendingReward = pendigRewards[msg.sender];
        require(pendingReward > 0, "User has not any pending reward to claim");

        // fetch pendig rewards
        // check if user has pending rewards
        // reset pendig rewards balance
        // mint rewards tokens to user
        // emit some event
        
        dappToken.transfer(msg.sender, pendingReward);
        emit RewardTransfered(msg.sender, pendingReward);

        pendigRewards[msg.sender] = 0;        
    }

    /**
     @notice Distribute rewards 
     Distribute rewards for all staking user
     Only owner can call this function
     */
    function distributeRewardsAll() external {
        for (
            uint256 staker_index = 0;
            staker_index < stakers.length;
            staker_index++
        ) {
          distributeRewards(stakers[staker_index]);
        }
    }

    /**
     @notice Distribute rewards
     calculates rewards for the indicated beneficiary 
     */
    function distributeRewards(address beneficiary) private {
        address staker_address = beneficiary;
        uint256 checkpoint = checkpoints[staker_address];

        if (
            isStaking[staker_address] &&
            checkpoint > 0 && 
            block.number > checkpoint
        ) {
            uint256 reward = (block.number - checkpoint) * REWARD_PER_BLOCK;

            if (reward > 0) {
                uint256 userReward = (reward / totalStaked) *
                    stakingBalance[staker_address];

                pendigRewards[staker_address] =
                    pendigRewards[staker_address] +
                    userReward;
                emit Reward(staker_address, userReward);
            }
        }
        
        checkpoints[staker_address] = block.number;
    }
}

// REWARD_PER_BLOCK = 1
// blocks-since-last-checkpoint: 50
// total rewards = 50
// total staked = 40

// user reward = (totalRewards/TotalStaked) * userStaked

// user 1: deposits 10 reward 12,5
// user 2: deposits 30 reward 37,5
