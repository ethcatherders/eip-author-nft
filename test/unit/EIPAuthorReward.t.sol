// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseTest} from "../utils/base/BaseTest.sol";
import {EIPAuthorReward} from "../../src/EIPAuthorReward.sol";
import {MockEIPAuthorReward} from "../utils/mock/MockEIPAuthorReward.sol";

contract EIPAuthorRewardTest is BaseTest {
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

    function test_claim() public {
        // Mint to recipient
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
            ownerPrivateKey
        );
        
        vm.expectEmit();
        emit EIPAuthorReward.Claimed(id, recipient, author);
        reward.claim(claimable, signature);

        assertEq(reward.balanceOf(recipient, id), 1);
    }

    function test_claim_asMsgSender() public {
        // Mint to msg.sender
        uint256 id = 1;
        address sender = vm.addr(3);
        bytes memory signature = _signClaimable(
            reward, 
            EIPAuthorReward.Claimable({
                id: id,
                author: "author",
                to: sender
            }), 
            ownerPrivateKey
        );
        
        vm.prank(sender);
        reward.claim(id, "author", signature);

        assertEq(reward.balanceOf(sender, id), 1);
    }

    function test_claimed() public {
        _signAndExecuteClaim(
            reward, 
            EIPAuthorReward.Claimable({
                id: 1,
                author: "author",
                to: vm.addr(2)
            }), 
            ownerPrivateKey
        );
        assertTrue(reward.claimed("author", 1));
    }

    function test_setUri() public {
        uint256 id = 1;
        string memory newUri = "newUri";

        vm.startPrank(owner);

        vm.expectEmit();
        emit EIPAuthorReward.MetadataUpdated(id, newUri);
        reward.setUri(id, newUri);

        vm.stopPrank();

        assertEq(reward.uri(id), newUri);
    }
}
