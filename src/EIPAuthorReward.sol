// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract EIPAuthorReward is
    ERC1155,
    EIP712,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    string private _name;
    string private _symbol;
    uint256 private _supply;
    // keccak256(author) => id of network upgrade => claimed
    mapping(bytes32 author => mapping(uint256 id => bool)) private _claimed;
    mapping(uint256 id => string uri) private _uris;

    string private constant SIGNING_DOMAIN = "EIP Author Reward";
    string private constant SIGNATURE_VERSION = "1";
    bytes32 private constant CLAIMABLE_TYPE_HASH = keccak256("Claimable(uint256 id,address to,string author)");

    /**
     * @dev Struct containing the claimable information.
     *
     * @param id - token ID of network upgrade
     * @param to - address of recipient
     * @param author - github username of EIP author
     */
    struct Claimable {
        uint256 id;
        address to;
        string  author;
    }

    /**
     * @dev Emitted when a claim is made.
     *
     * @param id - token ID of network upgrade
     * @param to - address of recipient
     * @param author - github username of EIP author
     */
    event Claimed(
        uint256 indexed id,
        address indexed to,
        string indexed author
    );

    /**
     * @dev Emitted when the URI for a token is updated.
     *
     * @param id - token ID of network upgrade
     * @param uri - URI to set
     */
    event MetadataUpdated(
        uint256 indexed id,
        string indexed uri
    );

    error InvalidSignature();

    error AlreadyClaimed(bytes32 author, uint256 id);

    /**
     * @dev Initializes the contract.
     *
     * @param owner - address of owner
     * @param name_ - name of the contract
     * @param symbol_ - symbol of the contract
     */
    constructor(
        address owner,
        string memory name_,
        string memory symbol_
    ) 
        Ownable(owner)
        ERC1155("")
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) 
    {
        require(bytes(name_).length > 0, "Reward: no name");
        require(bytes(symbol_).length > 0, "Reward: no symbol");
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Mints token to msg.sender. Assumes msg.sender is the author of the EIP.
     *
     * @param id - token ID of network upgrade
     * @param author - github username of EIP author
     * @param signature - signature of the author
     *
     * Note: author can only claim once per token ID.
     */
    function claim(
        uint256 id,
        string calldata author,
        bytes calldata signature
    ) external whenNotPaused nonReentrant {
        _claimMint(
            Claimable({
                id: id,
                to: msg.sender,
                author: author
            }),
            signature
        );
    }

    /**
     * @dev Mints token to recipient address that has not claimed before
     *
     * @param claimable - struct containing the claimable information
     * @param signature - signature of the author
     * 
     * Note: author can only claim once per token ID.
     */
    function claim(Claimable calldata claimable, bytes calldata signature) external whenNotPaused nonReentrant {
        _claimMint(claimable, signature);
    }

    /**
     * @dev Returns a boolean to indicate if account has been used to mint token
     *
     * @param author - github username of EIP author
     * @param id - token ID of network upgrade
     *
     * Note: Only owner can call this view function.
     */
    function claimed(string calldata author, uint256 id)
        external
        view
        returns (bool)
    {
        return _claimed[keccak256(abi.encodePacked(author))][id];
    }

    /**
     * @dev Returns supply of tokens
     */
    function supply() external view returns (uint256) {
        return _supply;
    }

    /**
     * @dev Returns the name of the reward.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the reward.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the URI for a given token ID.
     */
    function uri(uint256 id) public override view returns (string memory) {
        return _uris[id];
    }

    /**
     * @dev Sets the URI for a given token ID.
     *
     * Note: Only owner can call this function.
     *
     * @param id - token ID of network upgrade
     * @param uri_ - URI to set
     */
    function setUri(uint256 id, string calldata uri_) external onlyOwner {
        _uris[id] = uri_;
        emit MetadataUpdated(id, uri_);
    }

    /**
     * @dev Pauses claims on the contract.
     *
     * Note: Only owner can call this function.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses claims on the contract.
     *
     * Note: Only owner can call this function.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Internal function to claim and mint token.
     */
    function _claimMint(Claimable memory claimable, bytes calldata signature) internal {
        bytes32 author = keccak256(abi.encodePacked(claimable.author));
        if (_claimed[author][claimable.id]) {
            revert AlreadyClaimed(author, claimable.id);
        }
        bytes32 hash = _hashClaimableStruct(claimable);
        if (!_isValidSignature(owner(), hash, signature)) {
            revert InvalidSignature();
        }
        _claimed[author][claimable.id] = true;
        _supply++;
        _mint(claimable.to, claimable.id, 1, "");
        emit Claimed(claimable.id, claimable.to, claimable.author);
    }

    /**
     * @dev Internal function to hash the claimable struct.
     */
    function _hashClaimableStruct(Claimable memory _claimable)
        internal
        view
        returns (bytes32)
    {
        bytes32 structHash = keccak256(
            abi.encode(
                CLAIMABLE_TYPE_HASH,
                _claimable.id,
                address(_claimable.to),
                keccak256(abi.encodePacked(_claimable.author))
            )
        );
        return _hashTypedDataV4(structHash);
    }

    /**
     * @dev Internal function to validate the signature.
     */
    function _isValidSignature(
        address signer,
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool) {
        return SignatureChecker.isValidSignatureNow(signer, hash, signature);
    }
}