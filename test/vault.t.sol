// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {Vault} from "../src/vault.sol";
import {IERC20} from "../src/vault.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";


/**
 * @title Vault test file
 * @author 4b
 * @notice Tesing a vault contract by smartcontractprogrammer
 */
contract TestVault is Test{
    Vault vault;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    uint256 mainnetFork;

    function setUp() public {
        vault = new Vault(DAI);
        mainnetFork = vm.createSelectFork({urlOrAlias: vm.envString("MAINNET_FORK_URL")});
    }

    function testSelectForkV() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(),mainnetFork);
    }

    function depositIntoVault() public {
        deal(DAI,address(this),10000e18,true);
        IERC20(DAI).approve(address(vault), 5620e18);

        vault.deposit(5620e18); 

        deal(DAI,address(0xabc),100e18,true);
        vm.prank(address(0xabc));
        IERC20(DAI).approve(address(vault), 56e18);

        vm.prank(address(0xabc));
        vault.deposit(56e18); 

        deal(DAI,address(0xcab),1000e18,true);
        vm.prank(address(0xcab));
        IERC20(DAI).approve(address(vault), 562e18);

        vm.prank(address(0xcab));
        vault.deposit(562e18); 
    }

    function testVaultDeposit() public{
        deal(DAI,address(this),10000e18,true);
        IERC20(DAI).approve(address(vault), 5620e18);

        vault.deposit(5620e18);

        assertEq(vault.totalSupply(), 5620e18);
        assertEq(vault.balanceOf(address(this)), 5620e18);
        assertEq(IERC20(DAI).balanceOf(address(vault)),5620e18);
    }

    function testVaultWithdraw() public {
        //------- some deposits first ------
        depositIntoVault();

        console2.log("Total Supply of vault is: ", vault.totalSupply());

        uint256 balBefore1 = IERC20(DAI).balanceOf(address(this));
        vault.withdraw(5620e18);
        assertEq(IERC20(DAI).balanceOf(address(this)), balBefore1 + 5620e18);
        assertEq(vault.totalSupply(), 6238e18-5620e18);
        assertEq(vault.balanceOf(address(this)),0);

        console2.log("Total Supply of vault is: ", vault.totalSupply());

        uint256 balBefore2 = IERC20(DAI).balanceOf(address(0xabc));
        vm.prank(address(0xabc));
        vault.withdraw(56e18);
        assertEq(IERC20(DAI).balanceOf(address(0xabc)), balBefore2 + 56e18);
        assertEq(vault.totalSupply(), 6238e18-5620e18-56e18);
        assertEq(vault.balanceOf(address(0xabc)),0);

        console2.log("Total Supply of vault is: ", vault.totalSupply());

        uint256 balBefore3 = IERC20(DAI).balanceOf(address(0xcab));
        vm.prank(address(0xcab));
        vault.withdraw(562e18);
        assertEq(IERC20(DAI).balanceOf(address(0xcab)), balBefore3 + 562e18);
        assertEq(vault.totalSupply(), 6238e18-5620e18-56e18-562e18);
        assertEq(vault.balanceOf(address(0xcab)),0);

        console2.log("Total Supply of vault is: ", vault.totalSupply());

        // There should be nothing in the vault since all users have withdrawn all their assets
        assertEq(vault.totalSupply(),0);
         // This further confirms there will be no leftover funds in the vault after every withdrawal
        assertEq(IERC20(DAI).balanceOf(address(vault)),0);
    }
}