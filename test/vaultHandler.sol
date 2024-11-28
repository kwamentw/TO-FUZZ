// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Vault,IERC20} from "../src/vault.sol";
import {ERC20} from "./ERC20Mock.sol";

/**
 * @title Vault Handler
 * @author 4b
 * @notice This assists in fuzzing the vault functions
 */
contract VaultHandler is Test{
    Vault vault; // vualt to test
    ERC20 fakeDai; // mock token

    constructor(Vault vault_){
        vault = vault_;
        fakeDai = new ERC20("4BTOKEN", "4BTKN", 6, 9000e18);
    }

    /**
     * Deposit helper function
     * @param assets amount of asstes to deposit
     */
    function deposit(uint256 assets) public {
        assets = bound(assets, 10, 100e18);
        
        fakeDai.mint(address(this), assets);
        fakeDai.approve(address(vault),assets);

        vault.deposit(assets);
    }

    /**
     * Withdraw helper function
     * @param shares amount of shares to withdraw
     */
    function withdraw(uint256 shares) public {
        shares = bound(shares, 1, 10_000);
        vault.withdraw(shares);
    }

}