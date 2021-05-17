pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev   Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b,"Calculation error");
        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256){
        // Solidity only automatically asserts when dividing by 0
        require(b > 0,"Calculation error");
        uint256 c = a / b;
        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256){
        require(b <= a,"Calculation error");
        uint256 c = a - b;
        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256){
        uint256 c = a + b;
        require(c >= a,"Calculation error");
        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256){
        require(b != 0,"Calculation error");
        return a % b;
    }
}

/**
 * @title ICliq
 * @dev   Contract interface for token contract 
 */
contract ICliq {
    function name() public pure returns (string memory);
    function symbol() public pure returns (string memory);
    function decimals() public pure returns (uint8);
    function totalSupply() public pure returns (uint256);
    function balanceOf(address) public pure returns (uint256);
    function allowance(address, address) public pure returns (uint256);
    function transfer(address, uint256) public pure returns (bool);
    function transferFrom(address, address, uint256) public pure returns (bool);
    function approve(address , uint256) public pure returns (bool);
    function burn(uint256) public pure;
    function mint(uint256) public pure returns(bool);
    function getContractDEVBalance() public pure returns(uint256);
 }

/**
 * @title Staking
 * @dev   Staking Contract for token and DEV staking
 */
contract Staking {
    
  using SafeMath for uint256;
  address private _owner;                                           // variable for Owner of the Contract.
  uint256 private _withdrawTime;                                    // variable to manage withdraw time for DEV and Token
  uint256 constant public PERIOD_SILVER            = 30;            // variable constant for time period managemnt
  uint256 constant public PERIOD_GOLD              = 60;            // variable constant for time period managemnt
  uint256 constant public PERIOD_PLATINUM          = 90;            // variable constant for time period managemnt
  uint256 constant public WITHDRAW_TIME_SILVER     = 15 * 1 days;   // variable constant to manage withdraw time lock up 
  uint256 constant public WITHDRAW_TIME_GOLD       = 30 * 1 days;   // variable constant to manage withdraw time lock up
  uint256 constant public WITHDRAW_TIME_PLATINUM   = 45 * 1 days;   // variable constant to manage withdraw time lock up
  uint256 constant public DEV_REWARD_PERCENT_SILVER      = 1332;    // variable constant to manage DEV reward percentage for silver
  uint256 constant public DEV_REWARD_PERCENT_GOLD        = 3203;    // variable constant to manage DEV reward percentage for gold
  uint256 constant public DEV_REWARD_PERCENT_PLATINUM    = 5347;    // variable constant to manage DEV reward percentage for platinum
  uint256 constant public DEV_PENALTY_PERCENT_SILVER     = 821;     // variable constant to manage DEV penalty percentage for silver
  uint256 constant public DEV_PENALTY_PERCENT_GOLD       = 1980;    // variable constant to manage DEV penalty percentage for silver
  uint256 constant public DEV_PENALTY_PERCENT_PLATINUM   = 3307;    // variable constant to manage DEV penalty percentage for silver
  uint256 constant public TOKEN_REWARD_PERCENT_SILVER    = 10;      // variable constant to manage token reward percentage for silver
  uint256 constant public TOKEN_REWARD_PERCENT_GOLD      = 20;      // variable constant to manage token reward percentage for gold
  uint256 constant public TOKEN_REWARD_PERCENT_PLATINUM  = 30;      // variable constant to manage token reward percentage for platinum
  uint256 constant public TOKEN_PENALTY_PERCENT_SILVER   = 3;       // variable constant to manage token penalty percentage for silver
  uint256 constant public TOKEN_PENALTY_PERCENT_GOLD     = 6;       // variable constant to manage token penalty percentage for silver
  uint256 constant public TOKEN_PENALTY_PERCENT_PLATINUM = 9;       // variable constant to manage token penalty percentage for silver
  
  // events to handle staking pause or unpause for token and DEV
  event Paused();
  event Unpaused();
  
  /*
  * ---------------------------------------------------------------------------------------------------------------------------
  * Functions for owner.
  * ---------------------------------------------------------------------------------------------------------------------------
  */

   /**
   * @dev get address of smart contract owner
   * @return address of owner
   */
   function getowner() public view returns (address) {
     return _owner;
   }

   /**
   * @dev modifier to check if the message sender is owner
   */
   modifier onlyOwner() {
     require(isOwner(),"You are not authenticate to make this transfer");
     _;
   }

   /**
   * @dev Internal function for modifier
   */
   function isOwner() internal view returns (bool) {
      return msg.sender == _owner;
   }

   /**
   * @dev Transfer ownership of the smart contract. For owner only
   * @return request status
   */
   function transferOwnership(address newOwner) public onlyOwner returns (bool){
      _owner = newOwner;
      return true;
   }
   
  /*
  * ---------------------------------------------------------------------------------------------------------------------------
  * Functionality of Constructor and Interface  
  * ---------------------------------------------------------------------------------------------------------------------------
  */
  
  // constructor to declare owner of the contract during time of deploy  
  constructor(address owner) public {
     _owner = owner;
  }
  
  // Interface declaration for contract
  ICliq icliq;
    
  // function to set Contract Address for Token Transfer Functions
  function setContractAddress(address tokenContractAddress) external onlyOwner returns(bool){
    icliq = ICliq(tokenContractAddress);
    return true;
  }
  
   /*
  * ----------------------------------------------------------------------------------------------------------------------------
  * Owner functions of get value, set value and other Functionality
  * ----------------------------------------------------------------------------------------------------------------------------
  */
  
  // function to add token reward in contract
  function addTokenReward(uint256 token) external onlyOwner returns(bool){
    _ownerTokenAllowance = _ownerTokenAllowance.add(token);
    icliq.transferFrom(msg.sender, address(this), _ownerTokenAllowance);
    return true;
  }
  
  // function to withdraw added token reward in contract
  function withdrawAddedTokenReward(uint256 token) external onlyOwner returns(bool){
    require(token < _ownerTokenAllowance,"Value is not feasible, Please Try Again!!!");
    _ownerTokenAllowance = _ownerTokenAllowance.sub(token);
    icliq.transferFrom(address(this), msg.sender, _ownerTokenAllowance);
    return true;
  }
  
  // function to get token reward in contract
  function getTokenReward() public view returns(uint256){
    return _ownerTokenAllowance;
  }
  
  // function to add DEV reward in contract
  function addDEVReward() external payable onlyOwner returns(bool){
    _ownerDEVAllowance = _ownerDEVAllowance.add(msg.value);
    return true;
  }
  
  // function to withdraw added DEV reward in contract
  function withdrawAddedDEVReward(uint256 amount) external onlyOwner returns(bool){
    require(amount < _ownerDEVAllowance, "Value is not feasible, Please Try Again!!!");
    _ownerDEVAllowance = _ownerDEVAllowance.sub(amount);
    msg.sender.transfer(_ownerDEVAllowance);
    return true;
  }
  
  // function to get DEV reward in contract
  function getDEVReward() public view returns(uint256){
    return _ownerDEVAllowance;
  }
  
  // function to set DEV limit per user by owner
  function setDEVLimit(uint256 devAmount) external onlyOwner returns(bool){
    require(devAmount != 0, "Zero Amount not Supported, Please Try Again!!!");
    _devLimit = devAmount;
    return true;
  }
  
  // function to get DEV limit set by owner
  function getDEVLimit() public view returns(uint256){
    return _devLimit;
  }
  
  // function to pause Token Staking
  function pauseTokenStaking() public onlyOwner {
    tokenPaused = true;
    emit Paused();
  }

  // function to unpause Token Staking
  function unpauseTokenStaking() public onlyOwner {
    tokenPaused = false;
    emit Unpaused();
  }
  
  // function to pause DEV Staking
  function pauseDEVStaking() public onlyOwner {
    devPaused = true;
    emit Paused();
  }

  // function to unpause DEV Staking
  function unpauseDEVStaking() public onlyOwner {
    devPaused = false;
    emit Unpaused();
  }
  
  /*
  * ----------------------------------------------------------------------------------------------------------------------------
  * Variable, Mapping for Token Staking Functionality
  * ----------------------------------------------------------------------------------------------------------------------------
  */
  
  // mapping for users with id => address Staking Address
  mapping (uint256 => address) private _tokenStakingAddress;
  
  // mapping for users with address => id staking id
  mapping (address => uint256[]) private _tokenStakingId;

  // mapping for users with id => Staking Time
  mapping (uint256 => uint256) private _tokenStakingStartTime;
  
  // mapping for users with id => End Time
  mapping (uint256 => uint256) private _tokenStakingEndTime;

  // mapping for users with id => Tokens 
  mapping (uint256 => uint256) private _usersTokens;
  
  // mapping for users with id => Status
  mapping (uint256 => bool) private _TokenTransactionstatus;    
  
  // mapping to keep track of final withdraw value of staked token
  mapping(uint256=>uint256) private _finalTokenStakeWithdraw;
  
  // mapping to keep track total number of staking days
  mapping(uint256=>uint256) private _tokenTotalDays;
  
  // variable to keep count of Token Staking
  uint256 private _tokenStakingCount = 0;
  
  // variable to keep track on reward added by owner
  uint256 private _ownerTokenAllowance = 0;

  // variable for token time management
  uint256 private _tokentime;
  
  // variable for token staking pause and unpause mechanism
  bool public tokenPaused = false;
  
  // variable for total Token staked by user
  uint256 public totalStakedToken = 0;
  
  // variable for total stake token in contract
  uint256 public totalTokenStakesInContract = 0;
  
  // modifier to check the user for staking || Re-enterance Guard
  modifier tokenStakeCheck(uint256 tokens, uint256 timePeriod){
    require(tokens > 0, "Invalid Token Amount, Please Try Again!!! ");
    require(timePeriod == PERIOD_SILVER || timePeriod == PERIOD_GOLD || timePeriod == PERIOD_PLATINUM, "Enter the Valid Time Period and Try Again !!!");
    _;
  }
  
  /*
  * ----------------------------------------------------------------------------------------------------------------------------
  * Variable, Mapping for DEV Staking Functionality
  * ----------------------------------------------------------------------------------------------------------------------------
  */
  
  // mapping for users with id => address Staking Address
  mapping (uint256 => address) private _devStakingAddress;
  
  // mapping for user with address => id staking id
  mapping (address => uint256[]) private _devStakingId;
  
  // mapping for users with id => Staking Time
  mapping (uint256 => uint256) private _devStakingStartTime;

  // mapping for users with id => End Time
  mapping (uint256 => uint256) private _devStakingEndTime;

  // mapping for users with id => DEV
  mapping (uint256 => uint256) private _usersDEV;
  
  // mapping for users with id => Status
  mapping (uint256 => bool) private _devTransactionstatus; 
  
  // mapping to keep track of final withdraw value of staked DEV
  mapping(uint256=>uint256) private _finalDEVStakeWithdraw;
  
  // mapping to keep track total number of staking days
  mapping(uint256=>uint256) private _devTotalDays;

  // mapping for DEV deposited by user 
  mapping(address=>uint256) private _devStakedByUser;
  
  // variable to keep count of DEV Staking
  uint256 private _devStakingCount = 0;
  
  // variable to keep track on DEV reward added by owner
  uint256 private _ownerDEVAllowance = 0;
  
  // variable to set DEV limit by owner
  uint256 private _devLimit = 0;

  // variable for DEV time management
  uint256 private _devTime;

  // variable for DEV staking pause and unpause mechanism
  bool public devPaused = false;
  
  // variable for total DEV staked by user
  uint256 public totalStakedDEV = 0;
  
  // variable for total stake DEV in contract
  uint256 public totalDEVStakesInContract = 0;
  
  // modifier to check time and input value for DEV Staking 
  modifier DEVStakeCheck(uint256 timePeriod){
    require(msg.value > 0, "Invalid Amount, Please Try Again!!! ");
    require(timePeriod == PERIOD_SILVER || timePeriod == PERIOD_GOLD || timePeriod == PERIOD_PLATINUM, "Enter the Valid Time Period and Try Again !!!");
    _;
  }
    
  /*
  * ------------------------------------------------------------------------------------------------------------------------------
  * Functions for Token Staking Functionality
  * ------------------------------------------------------------------------------------------------------------------------------
  */

  // function to performs staking for user tokens for a specific period of time
  function stakeToken(uint256 tokens, uint256 time) public tokenStakeCheck(tokens, time) returns(bool){
    require(tokenPaused == false, "Staking is Paused, Please try after staking get unpaused!!!");
    _tokentime = now + (time * 1 days);
    _tokenStakingCount = _tokenStakingCount +1;
    _tokenTotalDays[_tokenStakingCount] = time;
    _tokenStakingAddress[_tokenStakingCount] = msg.sender;
    _tokenStakingId[msg.sender].push(_tokenStakingCount);
    _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
    _tokenStakingStartTime[_tokenStakingCount] = now;
    _usersTokens[_tokenStakingCount] = tokens;
    _TokenTransactionstatus[_tokenStakingCount] = false;
    _tokenStakingCount = _tokenStakingCount +1;
    totalStakedToken = totalStakedToken.add(tokens);
    totalTokenStakesInContract = totalTokenStakesInContract.add(tokens);
    icliq.transferFrom(msg.sender, address(this), tokens);
    return true;
  }

  // function to get staking count for token
  function getTokenStakingCount() public view returns(uint256){
    return _tokenStakingCount;
  }
  
  // function to get total Staked tokens
  function getTotalStakedToken() public view returns(uint256){
    return totalStakedToken;
  }
  
  // function to calculate reward for the message sender for token
  function getTokenRewardDetailsByStakingId(uint256 id) public view returns(uint256){
    if(_tokenTotalDays[id] == PERIOD_SILVER) {
        return (_usersTokens[id]*TOKEN_REWARD_PERCENT_SILVER/100);
    } else if(_tokenTotalDays[id] == PERIOD_GOLD) {
               return (_usersTokens[id]*TOKEN_REWARD_PERCENT_GOLD/100);
      } else if(_tokenTotalDays[id] == PERIOD_PLATINUM) { 
                 return (_usersTokens[id]*TOKEN_REWARD_PERCENT_PLATINUM/100);
        } else{
              return 0;
          }
  }

  // function to calculate penalty for the message sender for token
  function getTokenPenaltyDetailByStakingId(uint256 id) public view returns(uint256){
    if(_tokenStakingEndTime[id] > now){
        if(_tokenTotalDays[id]==PERIOD_SILVER){
            return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_SILVER/100);
        } else if(_tokenTotalDays[id] == PERIOD_GOLD) {
              return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_GOLD/100);
          } else if(_tokenTotalDays[id] == PERIOD_PLATINUM) { 
                return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_PLATINUM/100);
            } else {
                return 0;
              }
    } else{
       return 0;
     }
  }
 
  // function for withdrawing staked tokens
  function withdrawStakedTokens(uint256 stakingId) public returns(bool) {
    require(_tokenStakingAddress[stakingId] == msg.sender,"No staked token found on this address and ID");
    require(_TokenTransactionstatus[stakingId] != true,"Either tokens are already withdrawn or blocked by admin");
    if(_tokenTotalDays[stakingId] == PERIOD_SILVER){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_SILVER, "Unable to Withdraw Staked token before 15 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              icliq.transferFrom(address(this), msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              icliq.transferFrom(address(this), msg.sender,_usersTokens[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
            }
    } else if(_tokenTotalDays[stakingId] == PERIOD_GOLD){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_GOLD, "Unable to Withdraw Staked token before 30 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              icliq.transferFrom(address(this), msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              icliq.transferFrom(address(this), msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
            }
    } else if(_tokenTotalDays[stakingId] == PERIOD_PLATINUM){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_PLATINUM, "Unable to Withdraw Staked token before 45 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              icliq.transferFrom(address(this), msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              icliq.transferFrom(address(this), msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
            }
    } else {
        return false;
      }
    return true;
  }
  
  // function to get Final Withdraw Staked value for token
  function getFinalTokenStakeWithdraw(uint256 id) public view returns(uint256){
    return _finalTokenStakeWithdraw[id];
  }
  
  // function to get total token stake in contract
  function getTotalTokenStakesInContract() public view returns(uint256){
      return totalTokenStakesInContract;
  }

   /*
  * -----------------------------------------------------------------------------------------------------------------------------------
  * Functions for DEV Staking Functionality
  * -----------------------------------------------------------------------------------------------------------------------------------
  */
 
  // function to performs staking for user DEV for a specific period of time
  function stakeDEV(uint256 time) external payable DEVStakeCheck(time) returns(bool){
    require(devPaused == false, "DEV Staking is Paused, Please try after staking get unpaused!!!");
    require(_devStakedByUser[msg.sender].add(msg.value) <= _devLimit, "DEV Stake Limit per user is completed, Use different address and try again!!!");
    _devTime = now + (time * 1 days);
    _devStakingCount = _devStakingCount + 1 ;
    _devTotalDays[_devStakingCount] = time;
    _devStakingAddress[_devStakingCount] = msg.sender;
    _devStakingId[msg.sender].push(_devStakingCount);
    _devStakingEndTime[_devStakingCount] = _devTime;
    _devStakingStartTime[_devStakingCount] = now;
    _usersDEV[_devStakingCount] = msg.value;
    _devStakedByUser[msg.sender] = _devStakedByUser[msg.sender].add(msg.value);
    _devTransactionstatus[_devStakingCount] = false;
    totalDEVStakesInContract = totalDEVStakesInContract.add(msg.value);
    totalStakedDEV = totalStakedDEV.add(msg.value);
    return true;
  }

  // function to get staking count for DEV
  function getDEVStakingCount() public view returns(uint256){
    return _devStakingCount;
  }
  
  // function to get total Staked DEV
  function getTotalStakedDEV() public view returns(uint256){
    return totalStakedDEV;
  }
  
  // function to calculate reward for the message sender for DEV stake
  function getDEVRewardDetailsByStakingId(uint256 id) public view returns(uint256){
    if(_devTotalDays[id] == PERIOD_SILVER) {
        return (_usersDEV[id]*DEV_REWARD_PERCENT_SILVER/100000);
    } else if(_devTotalDays[id] == PERIOD_GOLD) {
               return (_usersDEV[id]*DEV_REWARD_PERCENT_GOLD/100000);
      } else if(_devTotalDays[id] == PERIOD_PLATINUM) { 
                 return (_usersDEV[id]*DEV_REWARD_PERCENT_PLATINUM/100000);
        } else{
              return 0;
          }
  }

  // function to calculate penalty for the message sender for DEV stake
  function getDEVPenaltyDetailByStakingId(uint256 id) public view returns(uint256){
    if(_devStakingEndTime[id] > now){
        if(_devTotalDays[id] == PERIOD_SILVER){
            return (_usersDEV[id]*DEV_PENALTY_PERCENT_SILVER/100000);
        } else if(_devTotalDays[id] == PERIOD_GOLD) {
              return (_usersDEV[id]*DEV_PENALTY_PERCENT_GOLD/100000);
          } else if(_devTotalDays[id] == PERIOD_PLATINUM) { 
                return (_usersDEV[id]*DEV_PENALTY_PERCENT_PLATINUM/100000);
            } else {
                return 0;
              }
    } else{
       return 0;
     }
  }
  
  // function for withdrawing staked DEV
  function withdrawStakedDEV(uint256 stakingId) public returns(bool){
    require(_devStakingAddress[stakingId] == msg.sender,"No staked token found on this address and ID");
    require(_devTransactionstatus[stakingId] != true,"Either tokens are already withdrawn or blocked by admin");
      if(_devTotalDays[stakingId] == PERIOD_SILVER){
            require(now >= _devStakingStartTime[stakingId] + WITHDRAW_TIME_SILVER, "Unable to Withdraw Stake DEV before 15 days of staking start time, Please Try Again Later!!!");
            _devTransactionstatus[stakingId] = true;
            if(now >= _devStakingEndTime[stakingId]){
                _finalDEVStakeWithdraw[stakingId] = _usersDEV[stakingId].add(getDEVRewardDetailsByStakingId(stakingId));
                _devStakingAddress[stakingId].transfer(_finalDEVStakeWithdraw[stakingId]);
                totalDEVStakesInContract = totalDEVStakesInContract.sub(_usersDEV[stakingId]);
            } else {
                _finalDEVStakeWithdraw[stakingId] = _usersDEV[stakingId].add(getDEVPenaltyDetailByStakingId(stakingId));
                _devStakingAddress[stakingId].transfer(_finalDEVStakeWithdraw[stakingId]);
                totalDEVStakesInContract = totalDEVStakesInContract.sub(_usersDEV[stakingId]);
              }
      } else if(_devTotalDays[stakingId] == PERIOD_GOLD){
           require(now >= _devStakingStartTime[stakingId] + WITHDRAW_TIME_GOLD, "Unable to Withdraw Stake DEV before 30 days of staking start time, Please Try Again Later!!!");
           _devTransactionstatus[stakingId] = true;
            if(now >= _devStakingEndTime[stakingId]){
                _finalDEVStakeWithdraw[stakingId] = _usersDEV[stakingId].add(getDEVRewardDetailsByStakingId(stakingId));
                _devStakingAddress[stakingId].transfer(_finalDEVStakeWithdraw[stakingId]);
                totalDEVStakesInContract = totalDEVStakesInContract.sub(_usersDEV[stakingId]);
            } else {
                _finalDEVStakeWithdraw[stakingId] = _usersDEV[stakingId].add(getDEVPenaltyDetailByStakingId(stakingId));
                _devStakingAddress[stakingId].transfer(_finalDEVStakeWithdraw[stakingId]);
                totalDEVStakesInContract = totalDEVStakesInContract.sub(_usersDEV[stakingId]);
              }
      } else if(_devTotalDays[stakingId] == PERIOD_PLATINUM){
           require(now >= _devStakingStartTime[stakingId] + WITHDRAW_TIME_PLATINUM, "Unable to Withdraw Stake DEV before 45 days of staking start time, Please Try Again Later!!!");
           _devTransactionstatus[stakingId] = true;
           if(now >= _devStakingEndTime[stakingId]){
               _finalDEVStakeWithdraw[stakingId] = _usersDEV[stakingId].add(getDEVRewardDetailsByStakingId(stakingId));
               _devStakingAddress[stakingId].transfer(_finalDEVStakeWithdraw[stakingId]);
               totalDEVStakesInContract = totalDEVStakesInContract.sub(_usersDEV[stakingId]);
           } else {
               _finalDEVStakeWithdraw[stakingId] = _usersDEV[stakingId].add(getDEVPenaltyDetailByStakingId(stakingId));
               _devStakingAddress[stakingId].transfer(_finalDEVStakeWithdraw[stakingId]);
               totalDEVStakesInContract = totalDEVStakesInContract.sub(_usersDEV[stakingId]);
            }
      } else {
          return false;
        }
    return true;
  }
  
  // function to get Final Withdraw Staked value for DEV
  function getFinalDEVStakeWithdraw(uint256 id) public view returns(uint256){
    return _finalDEVStakeWithdraw[id];
  }
  
  // function to get total DEV stake in contract
  function getTotalDEVStakesInContract() public view returns(uint256){
      return totalDEVStakesInContract;
  }
  
  /*
  * -------------------------------------------------------------------------------------------------------------------------------
  * Get Functions for Stake Token Functionality
  * -------------------------------------------------------------------------------------------------------------------------------
  */

  // function to get Token Staking address by id
  function getTokenStakingAddressById(uint256 id) external view returns (address){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingAddress[id];
  }
  
  // function to get Token staking id by address
  function getTokenStakingIdByAddress(address add) external view returns(uint256[]){
    require(add != address(0),"Invalid Address, Pleae Try Again!!!");
    return _tokenStakingId[add];
  }
  
  // function to get Token Staking Starting time by id
  function getTokenStakingStartTimeById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingStartTime[id];
  }
  
  // function to get Token Staking Ending time by id
  function getTokenStakingEndTimeById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingEndTime[id];
  }
  
  // function to get Token Staking Total Days by Id
  function getTokenStakingTotalDaysById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenTotalDays[id];
  }

  // function to get Staking tokens by id
  function getStakingTokenById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _usersTokens[id];
  }

  // function to get Token lockstatus by id
  function getTokenLockStatus(uint256 id) external view returns(bool){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _TokenTransactionstatus[id];
  }
  
  /*
  * ----------------------------------------------------------------------------------------------------------------------------------
  * Get Functions for Stake DEV Functionality
  * ----------------------------------------------------------------------------------------------------------------------------------
  */

  // function to get DEV Staking address by id
  function getDEVStakingAddressById(uint256 id) external view returns (address){
    require(id <= _devStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _devStakingAddress[id];
  }
  
  // function to get DEV Staking id by address
  function getDEVStakingIdByAddress(address add) external view returns(uint256[]){
    require(add != address(0),"Invalid Address, Pleae Try Again!!!");
    return _devStakingId[add];
  }
  
  // function to get DEV Staking Starting time by id
  function getDEVStakingStartTimeById(uint256 id) external view returns(uint256){
    require(id <= _devStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _devStakingStartTime[id];
  }
  
  // function to get DEV Staking End time by id
  function getDEVStakingEndTimeById(uint256 id) external view returns(uint256){
    require(id <= _devStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _devStakingEndTime[id];
  }
  
  // function to get DEV Staking Total Days by Id
  function getDEVStakingTotalDaysById(uint256 id) external view returns(uint256){
    require(id <= _devStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _devTotalDays[id];
  }
  
  // function to get Staked DEV by id
  function getDEVStakedById(uint256 id) external view returns(uint256){
    require(id <= _devStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _usersDEV[id];
  }

  // function to get Staked DEV by address
  function getDEVStakedByUser(address add) external view returns(uint256){
    require(add != address(0),"Invalid Address, Please try again!!");
    return _devStakedByUser[add];
  }

  // function to get DEV lockstatus by id
  function getDEVLockStatus(uint256 id) external view returns(bool){
    require(id <= _devStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _devTransactionstatus[id];
  }

}
