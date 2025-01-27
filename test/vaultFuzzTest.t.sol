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
    ERC20 fakeDai;//token
    Vault vault;//vault to be tested
    VaultHandler handler;//vault handler for fuzzing

    function setUp() public {
        fakeDai = new ERC20("Dai", "FDAI", 18, 100_000);
        vault = new Vault(address(fakeDai));
        handler = new VaultHandler(vault);
        targetContract(address(handler));

        //Solution-to-the-arithmetic-overflow-revert error = minting some tokens to the handler
        fakeDai.mint(address(handler), 1000e6);
    }

    ///////////////////////// Stateless Fuzz Tests ////////////////////////////////

    /**
     * Fuzzing the amount to deposit parameter
     * @param amount amount to deposit
     */
    function testFuzzDeposit(uint256 amount) public {
        amount = bound(amount,20e3,2000000e18);

        fakeDai.mint(address(this), amount);
        fakeDai.approve(address(vault),amount);

        vault.deposit(amount);
        assertGt(vault.totalSupply(),0);
    }

    /**
     * Depositing an amount 
     * Then fuzzing the withdrawal amount
     * @param amount amount to withdraw
     */
    function testFuzzWithdraw(uint256 amount) public{
        amount = bound(amount,20e2,2000e18); // we have to bound to the amount deposited

        fakeDai.mint(address(this), 2000e18);
        fakeDai.approve(address(vault),2000e18);

        vault.deposit(2000e18);

        vault.withdraw(amount);

        assertEq(vault.totalSupply(),2000e18 - amount);
    }

   
    ///////////////////////// Stateful Fuzz Tests ////////////////////////////////

    /**
     * Testing whether my handler is working
     */
    function testHandlerDeposit() public{
        handler.deposit(200);
    }

    /**
     * Invariant to check whether totalSupply will always be equal to the balance of vault
     * function asserted true == test passes
     */
    function invariant_TotalSuppEqualsbalOfVault() public view{
        assertEq(vault.totalSupply(),fakeDai.balanceOf(address(vault)));
    }

    /**
     * Invariant to check whether user balance will always be less than or equal to total supply
     * function asserted true == test passes
     */
    function invariant_BalUserLteTotalSupply() public view {
        assertLe(vault.balanceOf(msg.sender), vault.totalSupply());
    }

    /**
     * Invariant to check whether vault balance can be uint256 MAX
     * function asserted true == test passes
     */
    function invariant_maxAssetsOfVault() public view{
        assertNotEq(fakeDai.balanceOf(address(vault)),type(uint256).max);
    }
}