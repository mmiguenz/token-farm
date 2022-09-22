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
    uint256 public constant REWARD_PER_BLOCK = 1e18;

    // iterable list of staking users
    address[] public stakers;

    // mappings: users staking and rewards info
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public pendigRewards;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    
    // Events - add events as needed
    


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
        require(_amount  > 0, "Deposit amount should be greater than 0");


        require(lpToken.balanceOf(msg.sender) >= _amount, "insuficient funds");

        // Trasnfer Mock LP Tokens to this contract for staking
        bool succces = lpToken.transferFrom(msg.sender, address(this), _amount);
       
        if(!succces) {
            revert();
        }

       
       // 

        // Update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        // Add user to stakers array only if they haven't staked already

        // Update staking status
        if(!isStaking[msg.sender]) {
            stakers.push(msg.sender);
            isStaking[msg.sender] = true;
        }

        // checkpoint block number
      
        // calculate rewards
       
       //  distributeRewards();

        // emit some event
    }

    /**
     @notice Withdraw
     Unstaking LP Tokens (Withdraw all LP Tokens)
     */
    function withdraw() public {
        // check is sender is staking

        // Fetch staking balance
        uint256 balance = 0;

        // Require amount greater than 0

        // calculate rewards before reseting staking balance
        
        // distributeRewards();

        // Reset staking balance

        // Update staking status

        // emit some event

        // Transfer LP Tokens to user

    }

    /**
     @notice Claim Rewards
     Users harvest pendig rewards
     Pendig rewards are minted to the user
     */
    function claimRewards() public {
        // fetch pendig rewards

        // check if user has pending rewards

        // reset pendig rewards balance

        // mint rewards tokens to user

        // emit some event
    }

    /**
     @notice Distribute rewards 
     Distribute rewards for all staking user
     Only owner can call this function
     */
    function distributeRewardsAll() external {

        // set rewards to all stakers
        // in this case the iterable list of staking users could be useful

        // emit some event
        
    }

    /**
     @notice Distribute rewards
     calculates rewards for the indicated beneficiary 
     */
    function distributeRewards(address beneficiary) private {
        // get las checkpoint block
        uint16 checkpoint = 0;
        // calculates rewards:
        if (block.number > checkpoint) {
            // reward = 
            // updates pendig rewards and block number checkpoint
            // ...
        }
    }
    
}

// REWARD_PER_BLOCK = 1
// blocks-since-last-checkpoint: 50
// total rewards = 50
// total staked = 40

// user reward = (totalRewards/TotalStaked) * userStaked

// user 1: deposits 10 reward 12,5
// user 2: deposits 30 reward 37,5
