// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    address public owner;
    mapping(address => uint256) private balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(address tokenAddress) external onlyOwner {
        uint256 totalBalance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(owner, totalBalance);
        emit Withdrawal(totalBalance);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
