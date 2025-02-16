// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../src/vault.sol";

/**
 * @title ERC20 contract
 * @author solidty by example
 * @notice Needed to create a mock for testing purposes
 */
contract ERC20 is IERC20 {

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialAmount
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(address(this), initialAmount);
    }

    //transfer tokens from msg.sender to recipient
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    //approve tokens on behalf of sender
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // transfer tokens from sender to receiver
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        // allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //mint tokens `to`
    function _mint(address to, uint256 amount) internal {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    //burn tokens from `from`
    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    //external mint 
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    // external burn
    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}