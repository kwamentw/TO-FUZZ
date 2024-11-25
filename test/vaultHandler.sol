// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Vault,IERC20} from "../src/vault.sol";

contract VaultHandler is Test{
    Vault vault;
    address immutable DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    constructor(Vault vault_){
        vault = vault_;
    }

    function deposit(uint256 assets) public {
        assets = bound(assets, 10, 100e18);

        deal(DAI,address(this), assets,true);
        IERC20(DAI).approve(address(vault),assets);

        vault.deposit(assets);
    }

    function withdraw(uint256 shares) public {
        shares = bound(shares, 1, 10_000);
        vault.withdraw(shares);
    }

}