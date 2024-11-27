// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Vault,IERC20} from "../src/vault.sol";
import {ERC20} from "./ERC20Mock.sol";

contract VaultHandler is Test{
    Vault vault;
    ERC20 fakeDai;

    constructor(Vault vault_){
        vault = vault_;
        fakeDai = new ERC20("4BTOKEN", "4BTKN", 6, 9000e18);
    }

    function deposit(uint256 assets) public {
        assets = bound(assets, 10, 100e18);
        
        fakeDai.mint(address(this), assets);
        fakeDai.approve(address(vault),assets);

        vault.deposit(assets);
    }

    function withdraw(uint256 shares) public {
        shares = bound(shares, 1, 10_000);
        vault.withdraw(shares);
    }

}