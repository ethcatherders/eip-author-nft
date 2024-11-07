// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {EIPAuthorReward} from "../src/EIPAuthorReward.sol";

contract Deploy is Script {
    function run() external returns (EIPAuthorReward nft, address owner) {
        string memory name = "EIP Author Reward";
        string memory symbol = "EIP";
        owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        nft = new EIPAuthorReward(owner, name, symbol);
        vm.stopBroadcast();
    }
}
