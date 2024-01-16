// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IERC1820Registry } from "./IERC1820Registry.sol";

interface IERC777Recipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount
    ) external;
}

// 创建你的合约并继承ERC-20
contract Atomicals is ERC20 {
    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    // 构造函数，设置代币的名称、符号和初始供应量
    constructor() ERC20("Atomicals", "atom") {
        // 初始发行量为 1,000,000 个代币，你可以根据需要调整这个值
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        bool success = super.transferFrom(sender, recipient, amount);
        if (success) {
            _callTokensReceived(msg.sender, sender, recipient, amount);
        }
        return success;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        bool success = super.transfer(recipient, amount);
        if (success) {
            _callTokensReceived(msg.sender, msg.sender, recipient, amount);
        }
        return success;
    }

    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal {
         address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount);
        }
    }
}