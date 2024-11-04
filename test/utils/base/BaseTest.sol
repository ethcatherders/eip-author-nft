// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {EIPAuthorReward} from "../../../src/EIPAuthorReward.sol";
import {MockEIPAuthorReward} from "../mock/MockEIPAuthorReward.sol";

contract BaseTest is Test {
    function _signClaimable(
        MockEIPAuthorReward _reward, 
        EIPAuthorReward.Claimable memory claimable,
        uint256 privateKey
    ) internal view returns (bytes memory) {
        bytes32 hash = _reward.hashClaimableStruct(claimable);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);
        return abi.encodePacked(r, s, v);
    }

    function _signAndExecuteClaim(
        MockEIPAuthorReward _reward,
        EIPAuthorReward.Claimable memory claimable,
        uint256 ownerPrivateKey
    ) internal returns (bytes memory signature) {
        vm.prank(vm.addr(ownerPrivateKey));
        signature = _signClaimable(
            _reward, 
            claimable,
            ownerPrivateKey
        );
        _reward.claim(claimable, signature);
    }
}
