// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Vault
 * @author Solidity by example
 * @notice This is just for educational purposes and not production code
 */
contract Vault {
    IERC20 public immutable token; // token to be deposited

    uint256 public totalSupply; // total amount of vault tokens supplied or minted
    mapping(address => uint256) public balanceOf; // balance of depositors

    constructor(address _token) {
        token = IERC20(_token);
    }

    /**
     * Amount of vault tokens minted to user
     * @param _to receiver
     * @param _shares amount of vault tokens minted
     */
    function _mint(address _to, uint256 _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    /**
     * Burns tokens from address provided
     * @param _from account to burn from
     * @param _shares amount of vault tokens to burn
     */
    function _burn(address _from, uint256 _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    /**
     *  deposits amount into his vault 
     * @param _amount amount of tokens user wants to deposit
     */
    function deposit(uint256 _amount) external {
        /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */
        uint256 shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    /**
     * withdraw from vault 
     * @param _shares amount of shares to withdraw
     */
    function withdraw(uint256 _shares) external {
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B 

        a = sB / T
        */
        uint256 amount =
            (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }
}

////////////==============ERC20 INTERFACE====================/////////////
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner, address indexed spender, uint256 amount
    );
}