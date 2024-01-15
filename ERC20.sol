// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 创建合约并继承ERC-20
contract Atomicals is ERC20 {
    // 构造函数，设置代币的名称、符号和初始供应量
    constructor() ERC20("Atomicals", "atom") {
        // 初始发行量为 1,000,000 个代币
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
}
