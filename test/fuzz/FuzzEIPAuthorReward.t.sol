// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseTest} from "../utils/base/BaseTest.sol";
import {EIPAuthorReward} from "../../src/EIPAuthorReward.sol";
import {MockEIPAuthorReward} from "../utils/mock/MockEIPAuthorReward.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FuzzEIPAuthorRewardTest is BaseTest {
    MockEIPAuthorReward internal reward;
    
    uint256 internal ownerPrivateKey = 11111111;
    address internal owner;

    function setUp() public {
        owner = vm.addr(ownerPrivateKey);
        reward = new MockEIPAuthorReward(owner);
        assertEq(reward.name(), "Mock EIP Author Reward");
        assertEq(reward.symbol(), "MER");
        assertEq(reward.owner(), owner);
    }

    function test_revert_claim_alreadyClaimed(address attempter) public {
        uint256 id = 1;
        string memory author = "author";
        address recipient = vm.addr(3);
        EIPAuthorReward.Claimable memory claimable = EIPAuthorReward.Claimable({
            id: id,
            author: author,
            to: recipient
        });

        bytes memory signature = _signAndExecuteClaim(
            reward, 
            claimable, 
            ownerPrivateKey
        );
        assertEq(reward.balanceOf(recipient, id), 1);

        bytes32 authorHash = keccak256(abi.encodePacked(author));
        vm.expectRevert(abi.encodeWithSelector(EIPAuthorReward.AlreadyClaimed.selector, authorHash, id));
        reward.claim(claimable, signature);

        assertEq(reward.balanceOf(attempter, id), 0);
    }

    function test_revert_claim_invalidSignature(uint32 nonOwnerPrivateKey) public {
        vm.assume(nonOwnerPrivateKey > 0 && nonOwnerPrivateKey != ownerPrivateKey);

        uint256 id = 1;
        string memory author = "author";
        address recipient = vm.addr(3);
        EIPAuthorReward.Claimable memory claimable = EIPAuthorReward.Claimable({
            id: id,
            author: author,
            to: recipient
        });
        bytes memory signature = _signClaimable(
            reward, 
            claimable, 
            nonOwnerPrivateKey
        );
        
        vm.expectRevert(abi.encodeWithSelector(EIPAuthorReward.InvalidSignature.selector));
        reward.claim(claimable, signature);

        assertEq(reward.balanceOf(recipient, id), 0);
    }

    function test_revert_setUri_notOwner(address nonOwner) public {
        vm.assume(nonOwner != owner);
        vm.startPrank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        reward.setUri(1, "uri");
    }

    function test_revert_pause_notOwner(address nonOwner) public {
        vm.assume(nonOwner != owner);
        vm.startPrank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        reward.pause();
    }

    function test_revert_unpause_notOwner(address nonOwner) public {
        vm.assume(nonOwner != owner);

        vm.prank(owner);
        reward.pause();

        vm.startPrank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        reward.unpause();
    }
}
