// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {EIPAuthorReward} from "../../../src/EIPAuthorReward.sol";

contract MockEIPAuthorReward is EIPAuthorReward {
    constructor(address owner) EIPAuthorReward(owner, "Mock EIP Author Reward", "MER") {}

    function hashClaimableStruct(Claimable memory _claimable)
        public
        view
        returns (bytes32)
    {
        return super._hashClaimableStruct(_claimable);
    }

    function isValidSignature(
        address signer,
        bytes32 hash,
        bytes calldata signature
    ) public view returns (bool) {
        return super._isValidSignature(signer, hash, signature);
    }
}