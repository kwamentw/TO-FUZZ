// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;

import {Vault} from "../src/vault.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";


/**
 * @title Vault test file
 * @author 4b
 * @notice Tesing a vault contract by smartcontractprogrammer
 */
contract TestVault is Test{
    Vault vault;

    uint256 mainnetFork;

    function setUp() public {
        vault = new Vault();
    }
}