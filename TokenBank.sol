// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC777Recipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount
    ) external;
}

contract TokenBank is IERC777Recipient {
    address public owner;
    address public tokenAddress;

    mapping(address => uint256) private balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw() external onlyOwner {
        uint256 totalBalance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(owner, totalBalance);
        emit Withdrawal(totalBalance);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount
    ) external override {
        balances[to] += amount;
    }
}
