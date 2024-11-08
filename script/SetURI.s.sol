// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {EIPAuthorReward} from "../src/EIPAuthorReward.sol";

contract SetURI is Script {
    function run() external returns (uint256 tokenId, string memory uri) {
        EIPAuthorReward nft = EIPAuthorReward(vm.envAddress("NFT_ADDRESS"));
        tokenId = uint256(keccak256(abi.encodePacked(vm.envString("UPGRADE_NAME"))));
        uri = vm.envString("IPFS_URI");

        uint256 ownerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");

        vm.startBroadcast(ownerPrivateKey);
        nft.setUri(tokenId, uri);
        vm.stopBroadcast();
    }
}
