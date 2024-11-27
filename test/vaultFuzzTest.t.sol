// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {Vault} from "../src/vault.sol";
import {IERC20} from "../src/vault.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {VaultHandler} from "./vaultHandler.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {ERC20} from "./ERC20Mock.sol";

/**
 * @title Vault test file
 * @author 4b
 * @notice Tesing a vault contract by smartcontractprogrammer
 */
contract TestVault is Test{
    ERC20 fakeDai;
    Vault vault;
    VaultHandler handler;

    function setUp() public {
        fakeDai = new ERC20("Dai", "FDAI", 18, 100_000);
        vault = new Vault(address(fakeDai));
        handler = new VaultHandler(vault);
        targetContract(address(handler));

        //Solution-to-the-arithmetic-overflow-revert error = minting some tokens to the handler
        vm.prank(address(handler));
        fakeDai.mint(address(handler), 1000e6);
    }

    ///////////////////////// Stateless Fuzz Tests ////////////////////////////////

   
    ///////////////////////// Stateful Fuzz Tests ////////////////////////////////

    function testHandlerDeposit() public{
        handler.deposit(200);
    }

    function invariant_TotalSuppEqualsbalOfVault() public{
        assertEq(vault.totalSupply(),fakeDai.balanceOf(address(vault)));
    }

    function invariant_BalUserLteTotalSupply() public{
        assertLe(vault.balanceOf(msg.sender), vault.totalSupply());
    }

    function invariant_maxAssetsOfVault() public {
        assertNotEq(fakeDai.balanceOf(address(vault)),type(uint256).max);
    }
}