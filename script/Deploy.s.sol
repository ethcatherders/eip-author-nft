// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {EIPAuthorReward} from "../src/EIPAuthorReward.sol";

contract Deploy is Script {
    function run() external returns (EIPAuthorReward nft, address owner) {
        string memory name = "EIP Author Reward";
        string memory symbol = "EIP";
        owner = 0xB447E28C6894Acd85594cF057E6E3C622493F03b;

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        nft = new EIPAuthorReward(owner, name, symbol);
        vm.stopBroadcast();
    }
}
