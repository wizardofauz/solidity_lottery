// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Lottery
 * @dev Implements a Lottery
 */
contract Lottery {

    // name of the lottery
    string public name;
    // Creator of the lottery contract
    address public manager;
    // Minimum participation amount in gwei
    uint minParticipationInWei;
    bool isLotteryLive = false;
    uint entrants = 0;
    uint256 total_value = 0;
    Player last_entrant;

    // variables for players
    struct Player {
        string name;
        uint index;
        uint entryCount;
        uint256 value_contributed;
    }

    address[] addressIndexes;
    mapping(address => Player) players;
    address winner;

    // constructor
    constructor(string memory lotteryName, uint weiToParticipate) {
        manager = msg.sender;
        name = lotteryName;
        minParticipationInWei = weiToParticipate;
        isLotteryLive = true;
    }

    // Let users participate by sending eth directly to contract address
    receive () external payable {
        require(isLotteryLive);
        participate("Anonymous");
    }

    function participate(string memory playerName) public payable {
        require(isLotteryLive);
        require(bytes(playerName).length > 0, "Player name must have > 0 length");
        require(msg.value >= (minParticipationInWei * 1 wei), "Participation required is not met");

        if (isNewPlayer(msg.sender)) {
            entrants += 1;
            uint index = addressIndexes.length;
            addressIndexes.push(msg.sender);
            players[msg.sender].entryCount = 1;
            players[msg.sender].name = playerName;
            players[msg.sender].index = index;
            players[msg.sender].value_contributed = msg.value;
        } else {
            players[msg.sender].entryCount += 1;
            players[msg.sender].value_contributed += msg.value;
        }
        total_value += msg.value;
        last_entrant = players[msg.sender];

        emit PlayerParticipated(players[msg.sender].name);
    }

    modifier onlyBy(address _account) {
      require(
         msg.sender == _account,
         "Sender not authorized."
      );
      _;
   }

   function getMinimumEntryRequirement() public view returns (uint) {
       return minParticipationInWei * 1 wei;
   }

   function getEntrants() public view returns (uint) {
       return entrants;
   }

   function getLastEntrant() public view returns (Player memory) {
       return last_entrant;
   }

    function isLive() public view returns (bool) {
       return isLotteryLive;
   }

   function getWinningPrice() public view returns (uint256) {
        return address(this).balance;
        // return total_value;
    }

    function getWinner() public view returns (address) {
        if (isLotteryLive) {
            return address(0);
        } else {
            return winner;
        }
    }

    function declareWinner() public onlyBy(manager) {
        if (isLotteryLive) {
            uint index = generateRandomNumber() % addressIndexes.length;
            address payable self = payable(address(this));
            uint256 balance = self.balance;
            
            winner = addressIndexes[index];
            payable(addressIndexes[index]).transfer(balance);

            // Mark the lottery inactive
            isLotteryLive = false;
        
            // event
            emit WinnerDeclared(players[winner].name);
        }
    }

    // Private functions
    function isNewPlayer(address playerAddress) private view returns(bool) {
        if (addressIndexes.length == 0) {
            return true;
        }
        return (addressIndexes[players[playerAddress].index] != playerAddress);
    }

    function generateRandomNumber() private view returns (uint) {
        // sha3 and now have been deprecated
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, addressIndexes)));
    }

    // Events
    event WinnerDeclared(string name);
    event PlayerParticipated(string name);

}
