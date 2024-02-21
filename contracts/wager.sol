// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import ownable
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Wager is Ownable {
    struct Match {
        address player1;
        address player2;
        uint256 amount; //amount that both parties have to pay
        address winner;
        bool isdraw;
        address _token;
    }
    mapping(address => bool) public _managers;

    mapping (address => bool) public _whitelistedTokens;

    mapping(uint256 => Match) public matches;

    uint256 public totalAmount;

    uint public HouseFee;

    address public houseRevenueAddress;

    modifier onlyManager
    {
        require(_managers[msg.sender], "Only manager can call this function");
        _;
    }


    constructor() Ownable(msg.sender){
        _managers[msg.sender] = true;
        HouseFee = 5;
        houseRevenueAddress = msg.sender;
    }

    function createMatch(
        uint256 _id,
        address _player1,
        address _player2,
        uint256 _amount,
        address _token
    ) public onlyManager {
        require(_whitelistedTokens[_token], "Token not whitelisted");
        IERC20 token = IERC20(_token);
        require(token.transferFrom(_player1, address(this), _amount), "Transfer failed");
        require(token.transferFrom(_player2, address(this), _amount), "Transfer failed");
        totalAmount += _amount * 2;
        matches[_id] = Match(_player1, _player2, _amount, address(0), false, _token);
    }

    function endMatch(uint256 _id, address _winner, bool isDraw) public onlyManager {
        Match storage _match = matches[_id];
        require(_match.player1 != address(0), "Match does not exist");
        require(_match.winner == address(0), "Match already ended");
        if (isDraw) {
            IERC20 token = IERC20(_match._token);
            require(token.transfer(_match.player1, _match.amount), "Transfer failed");
            require(token.transfer(_match.player2, _match.amount), "Transfer failed");
        } else {
            IERC20 token = IERC20(_match._token);
            uint totalAmount = _match.amount * 2; // Constant rn for both players to get the same amount (*2)
            uint houseFee = totalAmount * HouseFee / 100; //Take House Fee
            require(token.transfer(owner(), houseFee), "Transfer failed");
            require(token.transfer(_winner, totalAmount - houseFee), "Transfer failed");
        }
    }

    
    function getMatch(uint256 _id) public view returns (Match memory) {
        return matches[_id];
    }

    function addManager(address _manager) public onlyOwner {
        _managers[_manager] = true;
    }

    function removeManager(address _manager) public onlyOwner {
        _managers[_manager] = false;
    }

    function addToken(address _token) public onlyOwner {
        _whitelistedTokens[_token] = true;
    }

    function removeToken(address _token) public onlyOwner {
        _whitelistedTokens[_token] = false;
    }

    function setHouseFee(uint _fee) public onlyOwner {
        HouseFee = _fee;
    }

    function setHouseRevenueAddress(address _address) public onlyOwner {
        houseRevenueAddress = _address;
    }

    function withdraw(address _token, uint256 _amount) public onlyOwner {
        IERC20 token = IERC20(_token);
        require(token.transfer(owner(), _amount), "Transfer failed");
    }

    function withdrawAll(address _token) public onlyOwner {
        IERC20 token = IERC20(_token);
        require(token.transfer(owner(), token.balanceOf(address(this))), "Transfer failed");
    }

    function withdrawETH(uint256 _amount) public onlyOwner {
        payable(owner()).transfer(_amount);
    }

    function getMatchData(uint _matchid) public returns(Match memory){
        return matches[_matchid];
    }
    
}