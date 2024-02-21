// Sources flattened with hardhat v2.19.5 https://hardhat.org

// SPDX-License-Identifier: MIT

// File contracts/lib/interfaces/IERC165.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
  /**
   * @dev Returns true if this contract implements the interface defined by
   * `interfaceId`. See the corresponding
   * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
   * to learn more about how these ids are created.
   *
   * This function call must use less than 30 000 gas.
   */
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File contracts/interfaces/IERC404.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;

interface IERC404 is IERC165 {
  event ERC20Approval(address owner, address spender, uint256 value);
  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );
  event ERC721Approval(
    address indexed owner,
    address indexed spender,
    uint256 indexed id
  );
  event ERC20Transfer(address indexed from, address indexed to, uint256 amount);
  event ERC721Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed id
  );

  error NotFound();
  error InvalidId();
  error AlreadyExists();
  error InvalidRecipient();
  error InvalidSender();
  error InvalidSpender();
  error InvalidOperator();
  error UnsafeRecipient();
  error NotWhitelisted();
  error Unauthorized();
  error InsufficientAllowance();
  error DecimalsTooLow();
  error CannotRemoveFromWhitelist();
  error PermitDeadlineExpired();
  error InvalidSigner();
  error InvalidApproval();
  error OwnedIndexOverflow();
  error ClassificationSizeNotSet();
  error InsufficientTierHoldings();
  error InvalidTier();

  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function totalSupply() external view returns (uint256);
  function erc20TotalSupply() external view returns (uint256);
  function erc721TotalSupply() external view returns (uint256);
  function balanceOf(address owner_) external view returns (uint256);
  function erc721BalanceOf(address owner_) external view returns (uint256);
  function erc20BalanceOf(address owner_) external view returns (uint256);
  function whitelist(address account_) external view returns (bool);
  function isApprovedForAll(
    address owner_,
    address operator_
  ) external view returns (bool);
  function allowance(
    address owner_,
    address spender_
  ) external view returns (uint256);
  function owned(address owner_) external view returns (uint256[] memory);
  function ownerOf(uint256 id_) external view returns (address erc721Owner);
  function tokenURI(uint256 id_) external view returns (string memory);
  function approve(
    address spender_,
    uint256 valueOrId_
  ) external returns (bool);
  function setApprovalForAll(address operator_, bool approved_) external;
  function transferFrom(
    address from_,
    address to_,
    uint256 valueOrId_
  ) external returns (bool);
  function transfer(address to_, uint256 amount_) external returns (bool);
  function erc721TokensBankedInQueue() external view returns (uint256);
  function safeTransferFrom(address from_, address to_, uint256 id_) external;
  function safeTransferFrom(
    address from_,
    address to_,
    uint256 id_,
    bytes calldata data_
  ) external;
  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function permit(
    address owner_,
    address spender_,
    uint256 value_,
    uint256 deadline_,
    uint8 v_,
    bytes32 r_,
    bytes32 s_
  ) external;
}


// File contracts/lib/DoubleEndedQueue.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/DoubleEndedQueue.sol)
// Modified by Pandora Labs to support native uint256 operations
pragma solidity ^0.8.20;

/**
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
 * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `Bytes32Deque`. Other types can be cast to and from `bytes32`. This data structure can only be
 * used in storage, and not in memory.
 * ```solidity
 * DoubleEndedQueue.Bytes32Deque queue;
 * ```
 */
library DoubleEndedQueue {
  /**
   * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
   */
  error QueueEmpty();

  /**
   * @dev A push operation couldn't be completed due to the queue being full.
   */
  error QueueFull();

  /**
   * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
   */
  error QueueOutOfBounds();

  /**
   * @dev Indices are 128 bits so begin and end are packed in a single storage slot for efficient access.
   *
   * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
   * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
   * lead to unexpected behavior.
   *
   * The first item is at data[begin] and the last item is at data[end - 1]. This range can wrap around.
   */
  struct Uint256Deque {
    uint128 _begin;
    uint128 _end;
    mapping(uint128 index => uint256) _data;
  }

  /**
   * @dev Inserts an item at the end of the queue.
   *
   * Reverts with {QueueFull} if the queue is full.
   */
  function pushBack(Uint256Deque storage deque, uint256 value) internal {
    unchecked {
      uint128 backIndex = deque._end;
      if (backIndex + 1 == deque._begin) revert QueueFull();
      deque._data[backIndex] = value;
      deque._end = backIndex + 1;
    }
  }

  /**
   * @dev Removes the item at the end of the queue and returns it.
   *
   * Reverts with {QueueEmpty} if the queue is empty.
   */
  function popBack(
    Uint256Deque storage deque
  ) internal returns (uint256 value) {
    unchecked {
      uint128 backIndex = deque._end;
      if (backIndex == deque._begin) revert QueueEmpty();
      --backIndex;
      value = deque._data[backIndex];
      delete deque._data[backIndex];
      deque._end = backIndex;
    }
  }

  /**
   * @dev Inserts an item at the beginning of the queue.
   *
   * Reverts with {QueueFull} if the queue is full.
   */
  function pushFront(Uint256Deque storage deque, uint256 value) internal {
    unchecked {
      uint128 frontIndex = deque._begin - 1;
      if (frontIndex == deque._end) revert QueueFull();
      deque._data[frontIndex] = value;
      deque._begin = frontIndex;
    }
  }

  /**
   * @dev Removes the item at the beginning of the queue and returns it.
   *
   * Reverts with `QueueEmpty` if the queue is empty.
   */
  function popFront(
    Uint256Deque storage deque
  ) internal returns (uint256 value) {
    unchecked {
      uint128 frontIndex = deque._begin;
      if (frontIndex == deque._end) revert QueueEmpty();
      value = deque._data[frontIndex];
      delete deque._data[frontIndex];
      deque._begin = frontIndex + 1;
    }
  }

  /**
   * @dev Returns the item at the beginning of the queue.
   *
   * Reverts with `QueueEmpty` if the queue is empty.
   */
  function front(
    Uint256Deque storage deque
  ) internal view returns (uint256 value) {
    if (empty(deque)) revert QueueEmpty();
    return deque._data[deque._begin];
  }

  /**
   * @dev Returns the item at the end of the queue.
   *
   * Reverts with `QueueEmpty` if the queue is empty.
   */
  function back(
    Uint256Deque storage deque
  ) internal view returns (uint256 value) {
    if (empty(deque)) revert QueueEmpty();
    unchecked {
      return deque._data[deque._end - 1];
    }
  }

  /**
   * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
   * `length(deque) - 1`.
   *
   * Reverts with `QueueOutOfBounds` if the index is out of bounds.
   */
  function at(
    Uint256Deque storage deque,
    uint256 index
  ) internal view returns (uint256 value) {
    if (index >= length(deque)) revert QueueOutOfBounds();
    // By construction, length is a uint128, so the check above ensures that index can be safely downcast to uint128
    unchecked {
      return deque._data[deque._begin + uint128(index)];
    }
  }

  /**
   * @dev Resets the queue back to being empty.
   *
   * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
   * out on potential gas refunds.
   */
  function clear(Uint256Deque storage deque) internal {
    deque._begin = 0;
    deque._end = 0;
  }

  /**
   * @dev Returns the number of items in the queue.
   */
  function length(Uint256Deque storage deque) internal view returns (uint256) {
    unchecked {
      return uint256(deque._end - deque._begin);
    }
  }

  /**
   * @dev Returns true if the queue is empty.
   */
  function empty(Uint256Deque storage deque) internal view returns (bool) {
    return deque._end == deque._begin;
  }
}


// File contracts/lib/ERC721Receiver.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ERC721Receiver {
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external virtual returns (bytes4) {
    return ERC721Receiver.onERC721Received.selector;
  }
}


// File contracts/ERC404.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;




abstract contract ERC404_V2_Plus is IERC404 {
  using DoubleEndedQueue for DoubleEndedQueue.Uint256Deque;

  /// @dev The queue of ERC-721 tokens stored in the contract.
  DoubleEndedQueue.Uint256Deque private _storedERC721Ids;

  /// @dev Token name
  string public name;

  /// @dev Token symbol
  string public symbol;

  /// @dev Decimals for ERC-20 representation
  uint8 public immutable decimals;

  /// @dev Units for ERC-20 representation
  uint256 public immutable units;

  /// @dev Total supply in ERC-20 representation
  uint256 public totalSupply;

  /// @dev Current mint counter which also represents the highest
  ///      minted id, monotonically increasing to ensure accurate ownership
  uint256 internal _minted;

  /// @dev Initial chain id for EIP-2612 support
  uint256 internal immutable INITIAL_CHAIN_ID;

  /// @dev Initial domain separator for EIP-2612 support
  bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

  /// @dev Balance of user in ERC-20 representation
  mapping(address => uint256) public balanceOf;

  /// @dev Allowance of user in ERC-20 representation
  mapping(address => mapping(address => uint256)) public allowance;

  /// @dev Approval in ERC-721 representaion
  mapping(uint256 => address) public getApproved;

  /// @dev Approval for all in ERC-721 representation
  mapping(address => mapping(address => bool)) public isApprovedForAll;

  /// @dev Packed representation of ownerOf and owned indices
  mapping(uint256 => uint256) internal _ownedData;

  /// @dev Array of owned ids in ERC-721 representation
  mapping(address => uint256[]) internal _owned;

  /// @dev Addresses whitelisted from minting / banking for gas savings (pairs, routers, etc)
  mapping(address => bool) public whitelist;

  /// @dev EIP-2612 nonces
  mapping(address => uint256) public nonces;

  /// @dev Address bitmask for packed ownership data
  uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;

  /// @dev Owned index bitmask for packed ownership data
  uint256 private constant _BITMASK_OWNED_INDEX = ((1 << 96) - 1) << 160;
  
  /// @dev bool to check if ERC721 classification is enabled
  bool public isERC721ClassificationEnabled;

  /// @dev a list of ERC721 classification sizes
  /// Size can be the amount of tokens required for each tier upgrade
  /// Eg: [10 units, 20 units, 30 units....] 
  /// i.e say 10 tokens bind tier1, 20 tokens bind tier2, 30 tokens bind tier3
  uint256[] public classificationSize; 

  /// @dev a mappin to store the classified tier of ERC721 Tokens with their ID's
  /// Eg: [nft id 100 -> 1, nft id 101 -> 2, nft id 102 -> 3]
  /// This will be used to get the tier of the ERC721 token with the help of _classificationOfERC721
  // mapping(uint256 => uint256) public _ERC721_tier;
  mapping(uint256 => uint256) private _ERC721_tokenTierAndIndex;
  enum Operation { PACK, UNPACK }

  uint256 private constant MAX_TIER = 2**128 - 1; 
  uint256 private constant MAX_INDEX = 2**128 - 1; 
  uint256 private constant INDEX_SHIFT = 128;

  // /// @dev a struct to store the user holding's of ERC721 classification
  struct tierBalances {
    mapping (uint256 => uint256[]) userNFTids;
    mapping (uint256 => uint256) countNFTs;
  }

  /// @dev a mapping to store the user holding's of ERC721 classification
  mapping(address => tierBalances) _tierBalances;

  constructor(string memory name_, string memory symbol_, uint8 decimals_, bool isERC721ClassificationEnabled_) {
    name = name_;
    symbol = symbol_;

    if (decimals_ < 18) {
      revert DecimalsTooLow();
    }

    decimals = decimals_;
    units = 10 ** decimals;
    isERC721ClassificationEnabled = isERC721ClassificationEnabled_;

    // EIP-2612 initialization
    INITIAL_CHAIN_ID = block.chainid;
    INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
  }

  function _setClassificationSize(uint256[] memory _classificationSize) virtual public {
    classificationSize = _classificationSize;
  }

  function _setERC721ClassificationEnabled(bool _isERC721ClassificationEnabled) virtual public {
    isERC721ClassificationEnabled = _isERC721ClassificationEnabled;
  }
  /// @notice Function to find owner of a given ERC-721 token
  function ownerOf(
    uint256 id_
  ) public view virtual returns (address erc721Owner) {
    erc721Owner = _getOwnerOf(id_);

    // If the id_ is beyond the range of minted tokens, is 0, or the token is not owned by anyone, revert.
    if (id_ > _minted || id_ == 0 || erc721Owner == address(0)) {
      revert NotFound();
    }
  }

  function owned(
    address owner_
  ) public view virtual returns (uint256[] memory) {
    return _owned[owner_];
  }

  function erc721BalanceOf(
    address owner_
  ) public view virtual returns (uint256) {
    return _owned[owner_].length;
  }

  function erc20BalanceOf(
    address owner_
  ) public view virtual returns (uint256) {
    return balanceOf[owner_];
  }

  function erc20TotalSupply() public view virtual returns (uint256) {
    return totalSupply;
  }

  function erc721TotalSupply() public view virtual returns (uint256) {
    return _minted;
  }

  function erc721TokensBankedInQueue() public view virtual returns (uint256) {
    return _storedERC721Ids.length();
  }

  /// @notice tokenURI must be implemented by child contract
  function tokenURI(uint256 id_) public view virtual returns (string memory);

  /// @notice Function for token approvals
  /// @dev This function assumes the operator is attempting to approve an ERC-721
  ///      if valueOrId is less than the minted count. Note: Unlike setApprovalForAll,
  ///      spender_ must be allowed to be 0x0 so that approval can be revoked.
  function approve(
    address spender_,
    uint256 valueOrId_
  ) public virtual returns (bool) {
    // The ERC-721 tokens are 1-indexed, so 0 is not a valid id and indicates that
    // operator is attempting to set the ERC-20 allowance to 0.
    if (valueOrId_ <= _minted && valueOrId_ > 0) {
      // Intention is to approve as ERC-721 token (id).
      uint256 id = valueOrId_;
      address erc721Owner = _getOwnerOf(id);

      if (
        msg.sender != erc721Owner && !isApprovedForAll[erc721Owner][msg.sender]
      ) {
        revert Unauthorized();
      }

      getApproved[id] = spender_;

      emit ERC721Approval(erc721Owner, spender_, id);
    } else {
      // Prevent granting 0x0 an ERC-20 allowance.
      if (spender_ == address(0)) {
        revert InvalidSpender();
      }

      // Intention is to approve as ERC-20 token (value).
      uint256 value = valueOrId_;
      allowance[msg.sender][spender_] = value;

      emit ERC20Approval(msg.sender, spender_, value);
    }

    return true;
  }

  /// @notice Function for ERC-721 approvals
  function setApprovalForAll(address operator_, bool approved_) public virtual {
    // Prevent approvals to 0x0.
    if (operator_ == address(0)) {
      revert InvalidOperator();
    }
    isApprovedForAll[msg.sender][operator_] = approved_;
    emit ApprovalForAll(msg.sender, operator_, approved_);
  }

  /// @notice Function for mixed transfers from an operator that may be different than 'from'.
  /// @dev This function assumes the operator is attempting to transfer an ERC-721
  ///      if valueOrId is less than or equal to current max id.
  function transferFrom(
    address from_,
    address to_,
    uint256 valueOrId_
  ) public virtual returns (bool) {
    // Prevent transferring tokens from 0x0.
    if (from_ == address(0)) {
      revert InvalidSender();
    }

    // Prevent burning tokens to 0x0.
    if (to_ == address(0)) {
      revert InvalidRecipient();
    }

    if (valueOrId_ <= _minted) {
      // Intention is to transfer as ERC-721 token (id).
      uint256 id = valueOrId_;

      if (from_ != _getOwnerOf(id)) {
        revert Unauthorized();
      }

      // Check that the operator is either the sender or approved for the transfer.
      if (
        msg.sender != from_ &&
        !isApprovedForAll[from_][msg.sender] &&
        msg.sender != getApproved[id]
      ) {
        revert Unauthorized();
      }

      // Transfer 1 * units ERC-20 and 1 ERC-721 token.
      if (isERC721ClassificationEnabled && classificationSize.length > 0){
        // uint _units = _ERC721_tier[id];
        (uint256 _units,uint256 index) = getTokenTierAndIndex(id);
        if (_units == 0){
          // TODO: Find a better way to handle this
          revert("Cannot TransferFrom from a whitelisted Address in Classification Mode Ask the dev for help!");
        }
        // Sender's Modifications
        tierBalances storage tierBalancesAfter = _tierBalances[from_];
        uint currentCount = tierBalancesAfter.countNFTs[_units];
        tierBalancesAfter.countNFTs[_units] = currentCount - 1;
        uint256[] storage userNFTids = tierBalancesAfter.userNFTids[_units];

        // Swap Places with the last element and delete the last element and its info as well
        if (userNFTids.length == 1 || id == userNFTids[userNFTids.length - 1]){ //only one element no need to swap or if last element is the one to be deleted
          userNFTids.pop();
        }else{
          userNFTids[index] = userNFTids[userNFTids.length - 1];
          userNFTids.pop();
          // index != userNFTids.length?setTokenTierAndIndex(userNFTids[index], _units, index):(); // does this help in saving gas fees?
          setTokenTierAndIndex(userNFTids[index], _units, index);
        }

        // Receievers Modifications
        tierBalancesAfter = _tierBalances[to_];
        tierBalancesAfter.userNFTids[_units].push(id);
        tierBalancesAfter.countNFTs[_units] += 1;
        setTokenTierAndIndex(id, _units, tierBalancesAfter.userNFTids[_units].length - 1);


        _transferERC20(from_, to_, _units); 
        _transferERC721(from_, to_, id);
      }else{
        _transferERC20(from_, to_, units);
        _transferERC721(from_, to_, id);
      }
    } else {
      // Intention is to transfer as ERC-20 token (value).
      uint256 value = valueOrId_;
      uint256 allowed = allowance[from_][msg.sender];

      // Check that the operator has sufficient allowance.
      if (allowed != type(uint256).max) {
        allowance[from_][msg.sender] = allowed - value;
      }
      // Transferring ERC-20s directly requires the _transfer function.
      _transferERC20WithERC721(from_, to_, value);
    }

    return true;
  }

  /// @notice Function for ERC-20 transfers.
  /// @dev This function assumes the operator is attempting to transfer as ERC-20
  ///      given this function is only supported on the ERC-20 interface
  function transfer(address to_, uint256 value_) public virtual returns (bool) {
    // Prevent burning tokens to 0x0.
    if (to_ == address(0)) {
      revert InvalidRecipient();
    }

    // Transferring ERC-20s directly requires the _transfer function.
    return _transferERC20WithERC721(msg.sender, to_, value_);
  }

  /// @notice Function for ERC-721 transfers with contract support.
  function safeTransferFrom(
    address from_,
    address to_,
    uint256 id_
  ) public virtual {
    transferFrom(from_, to_, id_);

    if (
      to_.code.length != 0 &&
      ERC721Receiver(to_).onERC721Received(msg.sender, from_, id_, "") !=
      ERC721Receiver.onERC721Received.selector
    ) {
      revert UnsafeRecipient();
    }
  }

  /// @notice Function for ERC-721 transfers with contract support and callback data.
  function safeTransferFrom(
    address from_,
    address to_,
    uint256 id_,
    bytes calldata data_
  ) public virtual {
    transferFrom(from_, to_, id_);

    if (
      to_.code.length != 0 &&
      ERC721Receiver(to_).onERC721Received(msg.sender, from_, id_, data_) !=
      ERC721Receiver.onERC721Received.selector
    ) {
      revert UnsafeRecipient();
    }
  }
  
  /// @notice Function for EIP-2612 permits
  function permit(
    address owner_,
    address spender_,
    uint256 value_,
    uint256 deadline_,
    uint8 v_,
    bytes32 r_,
    bytes32 s_
  ) public virtual {
    if (deadline_ < block.timestamp) {
      revert PermitDeadlineExpired();
    }

    if (value_ <= _minted && value_ > 0) {
      revert InvalidApproval();
    }

    if (spender_ == address(0)) {
      revert InvalidSpender();
    }

    unchecked {
      address recoveredAddress = ecrecover(
        keccak256(
          abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR(),
            keccak256(
              abi.encode(
                keccak256(
                  "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                ),
                owner_,
                spender_,
                value_,
                nonces[owner_]++,
                deadline_
              )
            )
          )
        ),
        v_,
        r_,
        s_
      );

      if (recoveredAddress == address(0) || recoveredAddress != owner_) {
        revert InvalidSigner();
      }

      allowance[recoveredAddress][spender_] = value_;
    }

    emit ERC20Approval(owner_, spender_, value_);
  }

  /// @notice Returns domain initial domain separator, or recomputes if chain id is not equal to initial chain id
  function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
    return
      block.chainid == INITIAL_CHAIN_ID
        ? INITIAL_DOMAIN_SEPARATOR
        : _computeDomainSeparator();
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual returns (bool) {
    return
      interfaceId == type(IERC404).interfaceId ||
      interfaceId == type(IERC165).interfaceId;
  }

  /// @notice Internal function to compute domain separator for EIP-2612 permits
  function _computeDomainSeparator() internal view virtual returns (bytes32) {
    return
      keccak256(
        abi.encode(
          keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
          ),
          keccak256(bytes(name)),
          keccak256("1"),
          block.chainid,
          address(this)
        )
      );
  }

  /// @notice This is the lowest level ERC-20 transfer function, which
  ///         should be used for both normal ERC-20 transfers as well as minting.
  /// Note that this function allows transfers to and from 0x0.
  function _transferERC20(
    address from_,
    address to_,
    uint256 value_
  ) internal virtual {
    // Minting is a special case for which we should not check the balance of
    // the sender, and we should increase the total supply.
    if (from_ == address(0)) {
      totalSupply += value_;
    } else {
      // Deduct value from sender's balance.
      balanceOf[from_] -= value_;
    }

    // Update the recipient's balance.
    // Can be unchecked because on mint, adding to totalSupply is checked, and on transfer balance deduction is checked.
    unchecked {
      balanceOf[to_] += value_;
    }

    emit ERC20Transfer(from_, to_, value_);
  }

  /// @notice Consolidated record keeping function for transferring ERC-721s.
  /// @dev Assign the token to the new owner, and remove from the old owner.
  /// Note that this function allows transfers to and from 0x0.
  function _transferERC721(
    address from_,
    address to_,
    uint256 id_
  ) internal virtual {
    // If this is not a mint, handle record keeping for transfer from previous owner.
    if (from_ != address(0)) {
      // On transfer of an NFT, any previous approval is reset.
      delete getApproved[id_];

      uint256 updatedId = _owned[from_][_owned[from_].length - 1];
      if (updatedId != id_) {
        uint256 updatedIndex = _getOwnedIndex(id_);
        // update _owned for sender
        _owned[from_][updatedIndex] = updatedId;
        // update index for the moved id
        _setOwnedIndex(updatedId, updatedIndex);
      }

      // pop
      _owned[from_].pop();
    }

    if (to_ != address(0)) {
      // Update owner of the token to the new owner.
      _setOwnerOf(id_, to_);
      // Push token onto the new owner's stack.
      _owned[to_].push(id_);
      // Update index for new owner's stack.
      _setOwnedIndex(id_, _owned[to_].length - 1);
    } else {
      delete _ownedData[id_];
    }

    emit ERC721Transfer(from_, to_, id_);
  }

  /// @notice Internal function for ERC-20 transfers. Also handles any ERC-721 transfers that may be required.
  function _transferERC20WithERC721(
    address from_,
    address to_,
    uint256 value_
  ) internal virtual returns (bool) {
    uint256 erc20BalanceOfSenderBefore = erc20BalanceOf(from_);
    uint256 erc20BalanceOfReceiverBefore = erc20BalanceOf(to_);

    _transferERC20(from_, to_, value_);

    // uint256 erc20BalanceOfSenderAfter = erc20BalanceOf(from_);
    // uint256 erc20BalanceOfReceiverAfter = erc20BalanceOf(to_);

    // Preload for gas savings on branches
    bool isFromWhitelisted = whitelist[from_];
    bool isToWhitelisted = whitelist[to_];

    // Skip _withdrawAndStoreERC721 and/or _retrieveOrMintERC721 for whitelisted addresses
    // 1) to save gas
    // 2) because whitelisted addresses won't always have/need ERC-721s corresponding to their ERC20s.
    if (isFromWhitelisted && isToWhitelisted) {
      // Case 1) Both sender and recipient are whitelisted. No ERC-721s need to be transferred.
      // NOOP.
    } else if (isFromWhitelisted) {
      // Case 2) The sender is whitelisted, but the recipient is not. Contract should not attempt
      //         to transfer ERC-721s from the sender, but the recipient should receive ERC-721s
      //         from the bank/minted for any whole number increase in their balance.
      // Only cares about whole number increments.
      if (isERC721ClassificationEnabled && classificationSize.length > 0){
        _tierERC721Handle(to_);
        return true; //Halt the execution
      }

      uint256 tokensToRetrieveOrMint = (balanceOf[to_] / units) -
        (erc20BalanceOfReceiverBefore / units);
      for (uint256 i = 0; i < tokensToRetrieveOrMint; i++) {
        _retrieveOrMintERC721(to_);
      }
    } else if (isToWhitelisted) {
      // Case 3) The sender is not whitelisted, but the recipient is. Contract should attempt
      //         to withdraw and store ERC-721s from the sender, but the recipient should not
      //         receive ERC-721s from the bank/minted.
      // Only cares about whole number increments.
      if (isERC721ClassificationEnabled && classificationSize.length > 0){
        _tierERC721Handle(from_);
        return true; //Halt the execution
      }

      uint256 tokensToWithdrawAndStore = (erc20BalanceOfSenderBefore / units) -
        (balanceOf[from_] / units);
      for (uint256 i = 0; i < tokensToWithdrawAndStore; i++) {
        _withdrawAndStoreERC721(from_);
      }
    } else {
      // Case 4) Neither the sender nor the recipient are whitelisted.
      // Strategy:
      // 1. First deal with the whole tokens. These are easy and will just be transferred.
      // 2. Look at the fractional part of the value:
      //   a) If it causes the sender to lose a whole token that was represented by an NFT due to a
      //      fractional part being transferred, withdraw and store an additional NFT from the sender.
      //   b) If it causes the receiver to gain a whole new token that should be represented by an NFT
      //      due to receiving a fractional part that completes a whole token, retrieve or mint an NFT to the recevier.

      // Whole tokens worth of ERC-20s get transferred as ERC-721s without any burning/minting.
      {
        if (isERC721ClassificationEnabled && classificationSize.length > 0){
          // If classification is enabled, tier the ERC721s
          _tierERC721Handle(from_);
          _tierERC721Handle(to_);
          return true; //Halt the execution
        }
      }
      uint256 nftsToTransfer = value_ / units;
      for (uint256 i = 0; i < nftsToTransfer; i++) {
        // Pop from sender's ERC-721 stack and transfer them (LIFO)
        uint256 indexOfLastToken = _owned[from_].length - 1;
        uint256 tokenId = _owned[from_][indexOfLastToken];
        _transferERC721(from_, to_, tokenId);
      }

      // If the sender's transaction changes their holding from a fractional to a non-fractional
      // amount (or vice versa), adjust ERC-721s.
      //
      // Check if the send causes the sender to lose a whole token that was represented by an ERC-721
      // due to a fractional part being transferred.
      //
      // To check this, look if subtracting the fractional amount from the balance causes the balance to
      // drop below the original balance % units, which represents the number of whole tokens they started with.
      uint256 fractionalAmount = value_ % units;

      if (
        (erc20BalanceOfSenderBefore - fractionalAmount) / units <
        (erc20BalanceOfSenderBefore / units)
      ) {
        _withdrawAndStoreERC721(from_);
      }

      // Check if the receive causes the receiver to gain a whole new token that should be represented
      // by an NFT due to receiving a fractional part that completes a whole token.
      if (
        (erc20BalanceOfReceiverBefore + fractionalAmount) / units >
        (erc20BalanceOfReceiverBefore / units)
      ) {
        _retrieveOrMintERC721(to_);
      }
    }

    return true;
  }

  /// @notice Internal function for Tiering ERC721 Token Transfers and Mint 
  /// @dev This function will allow tiering of ERC721s based on the classification size

  function _tierERC721Handle(address _user) internal {
    if (whitelist[_user] || classificationSize.length == 0) {
        return; // Exit early to save gas if user is whitelisted or classificationSize not set
    }
    uint256 remainingBalance = erc20BalanceOf(_user); // Cached balance
    tierBalances storage userTierBalances = _tierBalances[_user]; // Cache user's tier balances
    
    for (uint256 i = classificationSize.length; i > 0; i--) {
        uint256 tierSize = classificationSize[i - 1];
        if (remainingBalance < tierSize) {
            uint256 currentNFTCountInTier = userTierBalances.countNFTs[tierSize];
            currentNFTCountInTier>0?_burnTierNFTs(_user, tierSize, currentNFTCountInTier):();
            continue; // Skip this tier if balance is less than tier size
        }
        uint256 nftsNeededForTier = remainingBalance / tierSize;
        remainingBalance -= (nftsNeededForTier * tierSize); // Adjust remaining balance
        
        uint256 currentNFTCountInTier = userTierBalances.countNFTs[tierSize];
        if (currentNFTCountInTier < nftsNeededForTier) {
            // Need to mint additional NFTs for this tier
            uint256 nftsToMint = nftsNeededForTier - currentNFTCountInTier;
            _mintTierNFTs(_user, tierSize, nftsToMint);
        } else if (currentNFTCountInTier > nftsNeededForTier) {
            // Need to burn excess NFTs from this tier
            uint256 nftsToBurn = currentNFTCountInTier - nftsNeededForTier;
            _burnTierNFTs(_user, tierSize, nftsToBurn);
        }
        // If count is equal, no action needed
    }
}

  /// @dev Internal function to mint a new ERC721 token with Tiers

  function _mintTierNFTs(
    address _user,
    uint _tier,
    uint _amount
  ) virtual internal{
    if (_tier == 0){
      revert InvalidTier();
    }
    tierBalances storage tierBalancesAfter = _tierBalances[_user];
    for (uint i = 0; i < _amount; i++){
      uint id = _minted + 1;
      _minted++;
      _transferERC721(address(0), _user, id);
      tierBalancesAfter.userNFTids[_tier].push(id);
      setTokenTierAndIndex(id, _tier, tierBalancesAfter.userNFTids[_tier].length - 1);
    }
    tierBalancesAfter.countNFTs[_tier] += _amount;
  }


  /// @dev Internal function to burn a ERC721 token with Tiers
  function _burnTierNFTs(
    address _user,
    uint _tier,
    uint amount
  ) virtual internal{
    if (_tier == 0){
      revert InvalidTier();
    }
    tierBalances storage tierBalance = _tierBalances[_user];
    if (tierBalance.countNFTs[_tier] < amount){
      revert InsufficientTierHoldings();
    }

    for (uint i = 0; i < amount; i++){
      uint id = tierBalance.userNFTids[_tier][tierBalance.userNFTids[_tier].length - 1];
      _transferERC721(_user, address(0), id);
      tierBalance.userNFTids[_tier].pop();
      setTokenTierAndIndex(id, 0, 0);
    }
    tierBalance.countNFTs[_tier] -= amount;
    
  }

  function getNFTsByTier(
    address _user,
    uint _tier
  ) public view virtual returns (uint256[] memory){
    return _tierBalances[_user].userNFTids[_tier];
  }


  /// @notice Internal function for ERC20 minting
  /// @dev This function will allow minting of new ERC20s.
  ///      If mintCorrespondingERC721s_ is true, it will also mint the corresponding ERC721s.
  function _mintERC20(
    address to_,
    uint256 value_,
    bool mintCorrespondingERC721s_
  ) internal virtual {
    /// You cannot mint to the zero address (you can't mint and immediately burn in the same transfer).
    if (to_ == address(0)) {
      revert InvalidRecipient();
    }

    _transferERC20(address(0), to_, value_);

    // If mintCorrespondingERC721s_ is true, mint the corresponding ERC721s.
    if (mintCorrespondingERC721s_) {
      uint256 nftsToRetrieveOrMint = value_ / units;
      for (uint256 i = 0; i < nftsToRetrieveOrMint; i++) {
        _retrieveOrMintERC721(to_);
      }
    }
  }

  /// @notice Internal function for ERC-721 minting and retrieval from the bank.
  /// @dev This function will allow minting of new ERC-721s up to the total fractional supply. It will
  ///      first try to pull from the bank, and if the bank is empty, it will mint a new token.
  function _retrieveOrMintERC721(address to_) internal virtual {
    if (to_ == address(0)) {
      revert InvalidRecipient();
    }

    uint256 id;

    if (!DoubleEndedQueue.empty(_storedERC721Ids) && !isERC721ClassificationEnabled){
      // If there are any tokens in the bank, use those first.
      // Pop off the end of the queue (FIFO).
      id = _storedERC721Ids.popBack();
    } else {
      // Otherwise, mint a new token, should not be able to go over the total fractional supply.
      _minted++;
      id = _minted;
    }

    address erc721Owner = _getOwnerOf(id);

    // The token should not already belong to anyone besides 0x0 or this contract.
    // If it does, something is wrong, as this should never happen.
    if (erc721Owner != address(0)) {
      revert AlreadyExists();
    }

    // Transfer the token to the recipient, either transferring from the contract's bank or minting.
    _transferERC721(erc721Owner, to_, id);
  }

  /// @notice Internal function for ERC-721 deposits to bank (this contract).
  /// @dev This function will allow depositing of ERC-721s to the bank, which can be retrieved by future minters.
  function _withdrawAndStoreERC721(address from_) internal virtual {
    if (from_ == address(0)) {
      revert InvalidSender();
    }

    // Retrieve the latest token added to the owner's stack (LIFO).
    uint256 id = _owned[from_][_owned[from_].length - 1];

    // Transfer the token to the contract.
    _transferERC721(from_, address(0), id);

    // Record the token in the contract's bank queue.
    _storedERC721Ids.pushFront(id);
  }

  /// @notice Initialization function to set pairs / etc, saving gas by avoiding mint / burn on unnecessary targets
  function _setWhitelist(address target_, bool state_) internal virtual {
    // If the target has at least 1 full ERC-20 token, they should not be removed from the whitelist
    // because if they were and then they attempted to transfer, it would revert as they would not
    // necessarily have ehough ERC-721s to bank.
    if (erc20BalanceOf(target_) >= units && !state_) {
      revert CannotRemoveFromWhitelist();
    }
    whitelist[target_] = state_;
  }

  function _getOwnerOf(
    uint256 id_
  ) internal view virtual returns (address ownerOf_) {
    uint256 data = _ownedData[id_];

    assembly {
      ownerOf_ := and(data, _BITMASK_ADDRESS)
    }
  }

  function _setOwnerOf(uint256 id_, address owner_) internal virtual {
    uint256 data = _ownedData[id_];

    assembly {
      data := add(
        and(data, _BITMASK_OWNED_INDEX),
        and(owner_, _BITMASK_ADDRESS)
      )
    }

    _ownedData[id_] = data;
  }

  function _getOwnedIndex(
    uint256 id_
  ) internal view virtual returns (uint256 ownedIndex_) {
    uint256 data = _ownedData[id_];

    assembly {
      ownedIndex_ := shr(160, data)
    }
  }

  function _setOwnedIndex(uint256 id_, uint256 index_) internal virtual {
    uint256 data = _ownedData[id_];

    if (index_ > _BITMASK_OWNED_INDEX >> 160) {
      revert OwnedIndexOverflow();
    }

    assembly {
      data := add(
        and(data, _BITMASK_ADDRESS),
        and(shl(160, index_), _BITMASK_OWNED_INDEX)
      )
    }

    _ownedData[id_] = data;
  }


    // Example usage function for packing
    function setTokenTierAndIndex(uint256 tokenId, uint256 tier, uint256 index) public {
            require(tier <= MAX_TIER && index <= MAX_INDEX, "Tier/Index exceeds limit");
            _ERC721_tokenTierAndIndex[tokenId] = (tier | (index << INDEX_SHIFT));
    }

    // Example usage function for unpacking
    function getTokenTierAndIndex(uint256 tokenId) public view returns (uint256 , uint256 ) {
            uint256 data = _ERC721_tokenTierAndIndex[tokenId];
            uint256 unpackedTier = (data & MAX_TIER);
            uint256 unpackedIndex = (data >> INDEX_SHIFT);
            return (unpackedTier, unpackedIndex);
    }
}
