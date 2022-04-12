// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TpToken is ERC20 {
    address payable owner;
    using SafeMath for uint256;

        constructor() ERC20("TP Token", "TP") {
            owner = payable(msg.sender);
            _mint(msg.sender, 1000 * 10 ** 18); 
        }

        struct RoundToken {
            uint id;
            uint256 startTime;
            uint256 endTime;
            uint256 totalCap;
            uint256 price;
            uint256 soldToken;
        }

        RoundToken[] public rounds;
        bool isTokenLocked = true;

         function addRounds(
            uint256 _startTime,
            uint256 _endTime,
            uint256 _totalCap,
            uint256 _price
        ) public {
        require(msg.sender == owner,"You are not Owner.");
            rounds.push(
                RoundToken({
                    id: rounds.length,
                    startTime: _startTime,
                    endTime: _endTime,
                    totalCap: _totalCap,
                    price: _price,
                    soldToken : 0
                })
            );
        }

        function unlockedToken(bool _tokenStatus) public {
           require(owner == msg.sender,"Only owner changes the token status");
           isTokenLocked = _tokenStatus;
        }

        function transfer(address to,uint256 amount) public virtual override returns(bool) {
            require((owner == msg.sender) || (!isTokenLocked) ,"can't transfer token , token still locked");
            _transfer(msg.sender , to , amount);
            return true;
        }

        function roundCount() view public returns(uint) {
            return rounds.length;
        }

        function findElementInArray(uint256 _time) public view returns(uint) {
            for (uint i = 0; i < rounds.length; i++) {
                if (rounds[i].startTime <= _time || rounds[i].endTime >= _time) {
                    return i;
                }
            }
            return (rounds.length + 1);
        }

        function buyToken() public payable {
            require(msg.value > 0,"Send ETH to buy some tokens");
            uint _roundId = findElementInArray(block.timestamp);
            if(_roundId < rounds.length) {
            require(rounds[_roundId].soldToken < rounds[_roundId].totalCap,"Over Max category tokens");

            uint tokenToSend = rounds[_roundId].totalCap.mul(msg.value).div(rounds[_roundId].price) ; // Token send

            require(tokenToSend < rounds[_roundId].totalCap.sub(rounds[_roundId].soldToken),"Round has Not enough token to sale.");

            transfer(msg.sender,tokenToSend);
            rounds[_roundId].soldToken = rounds[_roundId].soldToken.add(tokenToSend);
            } else {
                revert("Round is not found.");
            }
        }
}