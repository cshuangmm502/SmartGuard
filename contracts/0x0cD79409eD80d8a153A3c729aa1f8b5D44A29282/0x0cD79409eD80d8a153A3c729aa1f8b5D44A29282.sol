// Decompiled by library.dedaub.com
// 2026.05.18 07:51 UTC
// Compiled using the solidity compiler version 0.6.12


// Data structures and variables inferred from the use of storage instructions
bool stor_0_0_0; // STORAGE[0x0] bytes 0 to 0
bool _initialize; // STORAGE[0x0] bytes 1 to 1
uint256 _lastPauseTime; // STORAGE[0x65]
mapping (uint256 => struct_1415) _getRoleAdmin; // STORAGE[0x99]
mapping (uint8 => uint64) __depositCounts; // STORAGE[0xcc]
mapping (uint256 => address) _resourceIDToHandlerAddress; // STORAGE[0xcd]
mapping (uint72 => mapping (uint256 => struct_1417)) _getProposal; // STORAGE[0xce]
bool _paused; // STORAGE[0x66] bytes 0 to 0
bool _domainID; // STORAGE[0xcb] bytes 0 to 0
uint8 _relayerThreshold; // STORAGE[0xcb] bytes 1 to 1
address _owner; // STORAGE[0x33] bytes 0 to 19
uint128 _fee; // STORAGE[0xcb] bytes 2 to 17
uint40 _expiry; // STORAGE[0xcb] bytes 18 to 22

struct struct_1415 { uint256[] field0; mapping (address => uint256) field1; uint256 field2; };
struct struct_1417 { uint8 field0_0_0; uint200 field0_1_25; bool field0_26_26; uint40 field0_27_31; };

// Events
Deposit(uint8, bytes32, uint64, address, bytes);
PauseChanged(bool);
RelayerRemoved(address);
OwnershipTransferred(address, address);
RelayerThresholdChanged(uint256);
ProposalVote(uint8, uint64, uint8, bytes32);
FailedHandlerExecution(bytes);
RoleGranted(bytes32, address, address);
RoleRevoked(bytes32, address, address);
ProposalEvent(uint8, uint64, uint8, bytes32);

function 0x109f() private { 
    return _getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].length;
}

function 0x1a50(uint256 varg0, uint256 varg1) private { 
    require(bool(_getRoleAdmin[_getRoleAdmin[varg1].field2].field1[msg.sender]), Error('AccessControl: sender must be an admin to revoke'));
    0x2071(varg0, varg1);
    return ;
}

function _SafeSub(uint256 varg0, uint256 varg1) private { 
    require(varg0 <= varg1, Error('SafeMath: subtraction overflow'));
    return varg1 - varg0;
}

function 0x1f76(address varg0, uint256 varg1) private { 
    v0 = varg0;
    if (bool(_getRoleAdmin[varg1].field1[v0])) {
        v1 = v2 = 0;
    } else {
        v1 = 1;
        _getRoleAdmin[varg1].length += v1;
        _getRoleAdmin[varg1].field0[_getRoleAdmin[varg1].length] = v0;
        _getRoleAdmin[varg1].field1[v0] = _getRoleAdmin[varg1].length;
    }
    if (!v1) {
        return ;
    } else {
        emit RoleGranted(varg1, varg0, msg.sender);
        return ;
    }
}

function 0x2071(address varg0, uint256 varg1) private { 
    v0 = keccak256(varg1, 153);
    v1 = varg0;
    if (!_getRoleAdmin[varg1].field1[v1]) {
        v2 = v3 = 0;
    } else {
        assert(_getRoleAdmin[varg1].length - 1 < _getRoleAdmin[varg1].length);
        assert(_getRoleAdmin[varg1].field1[v1] - 1 < _getRoleAdmin[varg1].length);
        _getRoleAdmin[varg1].field0[_getRoleAdmin[varg1].field1[v1] - 1] = _getRoleAdmin[varg1].field0[_getRoleAdmin[varg1].length - 1];
        _getRoleAdmin[varg1].field1[_getRoleAdmin[varg1].field0[_getRoleAdmin[varg1].length - 1]] = _getRoleAdmin[varg1].field1[v1] - 1 + 1;
        assert(_getRoleAdmin[varg1].length);
        _getRoleAdmin[varg1].field0[_getRoleAdmin[varg1].length - 1] = 0;
        _getRoleAdmin[varg1].length = _getRoleAdmin[varg1].length - 1;
        _getRoleAdmin[varg1].field1[v1] = 0;
        v2 = 1;
    }
    if (!v2) {
        return ;
    } else {
        emit RoleRevoked(varg1, varg0, msg.sender);
        return ;
    }
}

function 0x20eb() private { 
    v0 = v1 = _initialize;
    if (!v1) {
        v0 = bool(!this.code.size);
    }
    if (!v0) {
        v0 = v2 = !stor_0_0_0;
    }
    require(v0, Error('Initializable: contract is already initialized'));
    if (!_initialize) {
        stor_0_0_0 = 1;
        _initialize = 1;
    }
    v3 = v4 = _initialize;
    if (!v4) {
        v3 = bool(!this.code.size);
    }
    if (!v3) {
        v3 = v5 = !stor_0_0_0;
    }
    require(v3, Error('Initializable: contract is already initialized'));
    if (!_initialize) {
        stor_0_0_0 = 1;
        _initialize = 1;
    }
    0x23bc();
    0x25ae();
    if (!_initialize) {
        _initialize = 0;
    }
    require(_owner != 0, Error('PausableUpgradeable: owner must be set'));
    if (_initialize) {
        return ;
    } else {
        _initialize = 0;
        return ;
    }
}

function 0x21a6() private { 
    v0 = v1 = _initialize;
    if (!v1) {
        v0 = bool(!this.code.size);
    }
    if (!v0) {
        v0 = v2 = !stor_0_0_0;
    }
    require(v0, Error('Initializable: contract is already initialized'));
    if (!_initialize) {
        stor_0_0_0 = 1;
        _initialize = 1;
    }
    0x23bc();
    0x23bc();
    if (_initialize) {
        return ;
    } else {
        _initialize = 0;
        return ;
    }
}

function 0x2268(address varg0) private { 
    if (varg0) {
        v0 = _SafeSub(1, _getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[varg0]);
        return 1 << v0;
    } else {
        return 0;
    }
}

function 0x22ad(uint256 varg0, uint200 varg1) private { 
    require(varg0 | varg1 < uint200.max + 1, Error('QBridge: value does not fit in 200 bits'));
    return varg0 | varg1;
}

function 0x23bc() private { 
    v0 = v1 = _initialize;
    if (!v1) {
        v0 = bool(!this.code.size);
    }
    if (!v0) {
        v0 = v2 = !stor_0_0_0;
    }
    require(v0, Error('Initializable: contract is already initialized'));
    if (_initialize) {
        if (_initialize) {
            return ;
        } else {
            _initialize = 0;
            return ;
        }
    } else {
        stor_0_0_0 = 1;
        _initialize = 1;
        if (_initialize) {
            return ;
        } else {
            _initialize = 0;
            return ;
        }
    }
}

function deposit(uint8 destinationChainID, bytes32 resourceID, bytes data) public payable { 
    require(msg.data.length - 4 >= 96);
    require(data <= uint64.max);
    require(4 + data + 31 < msg.data.length);
    require(data.length <= uint64.max);
    require(4 + data + data.length + 32 <= msg.data.length);
    require(!_paused, Error('PausableUpgradeable: cannot be performed while the contract is paused'));
    require(msg.value == _fee, Error('QBridge: invalid fee'));
    require(_resourceIDToHandlerAddress[resourceID], Error('QBridge: invalid resourceID'));
    __depositCounts[destinationChainID] = __depositCounts[destinationChainID] + 1;
    v0 = new bytes[](data.length);
    CALLDATACOPY(v0.data, data.data, data.length);
    v0[data.length] = 0;
    require(bool((_resourceIDToHandlerAddress[resourceID]).code.size));
    v1 = _resourceIDToHandlerAddress[resourceID].deposit(resourceID, msg.sender, v0).gas(msg.gas);
    require(bool(v1), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    v2 = new bytes[](data.length);
    CALLDATACOPY(v2.data, data.data, data.length);
    v2[data.length] = 0;
    emit Deposit(msg.sender, destinationChainID, resourceID, uint64(__depositCounts[destinationChainID] + 1), v2);
}

function 0x25ae() private { 
    v0 = v1 = _initialize;
    if (!v1) {
        v0 = bool(!this.code.size);
    }
    if (!v0) {
        v0 = v2 = !stor_0_0_0;
    }
    require(v0, Error('Initializable: contract is already initialized'));
    if (!_initialize) {
        stor_0_0_0 = 1;
        _initialize = 1;
    }
    _owner = msg.sender;
    emit OwnershipTransferred(0, msg.sender);
    if (_initialize) {
        return ;
    } else {
        _initialize = 0;
        return ;
    }
}

function setPaused(bool _state) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    if (_state != _paused) {
        _paused = _state;
        if (_paused) {
            _lastPauseTime = block.timestamp;
        }
        emit PauseChanged(_paused);
    }
}

function cancelProposal(uint8 chainID, uint64 depositNonce, bytes32 dataHash) public nonPayable { 
    require(msg.data.length - 4 >= 96);
    v0 = v1 = _owner == msg.sender;
    if (_owner != msg.sender) {
        v0 = bool(_getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[msg.sender]);
    }
    require(v0, Error('QBridge: caller is not the owner or relayer'));
    MEM[MEM[64]] = 0;
    MEM[MEM[64] + 32] = 0;
    MEM[MEM[64] + 64] = 0;
    MEM[MEM[64] + 96] = 0;
    v2 = new bytes[](4);
    assert(_getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_0_0 <= 4);
    assert(_getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_0_0 <= 4);
    assert(v2.length <= 4);
    v3 = v4 = v2.length == 1;
    if (v2.length != 1) {
        assert(v2.length <= 4);
        v3 = v5 = v2.length == 2;
    }
    require(v3, Error('QBridge: cannot be cancelled'));
    v6 = _SafeSub(uint40(_getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_27_31), block.number);
    require(uint40(v6) > _expiry, Error('QBridge: not at expiry threshold'));
    assert(v2.length <= 4);
    _getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_0_0 = v2.length;
    v7 = v2.data;
    _getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_1_25 = _getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_1_25;
    _getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_26_26 = _getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_26_26;
    _getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_27_31 = _getProposal[uint72(chainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_27_31;
    assert(4 < 5);
    emit ProposalEvent(chainID, depositNonce, 4, dataHash);
}

function getRoleAdmin(bytes32 role) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    return _getRoleAdmin[role].field2;
}

function grantRole(bytes32 role, address account) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    0xc11(account, role);
}

function sweep() public nonPayable { 
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    v0 = v1 = 0;
    while (v0 < 0) {
        MEM[v0 + MEM[64]] = MEM[v0 + (MEM[64] + 32)];
        v0 += 32;
    }
    if (v0 > 0) {
        MEM[MEM[64]] = 0;
    }
    v2, /* uint256 */ v3 = msg.sender.call().value(this.balance).gas(msg.gas);
    if (RETURNDATASIZE() != 0) {
        v4 = new bytes[](RETURNDATASIZE());
        RETURNDATACOPY(v4.data, 0, RETURNDATASIZE());
    }
    require(v2, Error('!safeTransferETH'));
}

function renounceRole(bytes32 role, address account) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    require(account == msg.sender, Error('AccessControl: can only renounce roles for self'));
    0x2071(account, role);
}

function setFee(uint128 varg0) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    _fee = varg0;
}

function initialize(uint8 varg0, uint8 varg1, uint128 varg2, uint40 varg3) public nonPayable { 
    require(msg.data.length - 4 >= 128);
    v0 = v1 = _initialize;
    if (!v1) {
        v0 = bool(!this.code.size);
    }
    if (!v0) {
        v0 = v2 = !stor_0_0_0;
    }
    require(v0, Error('Initializable: contract is already initialized'));
    if (!_initialize) {
        stor_0_0_0 = 1;
        _initialize = 1;
    }
    0x20eb();
    0x21a6();
    _domainID = varg0;
    _expiry = varg3;
    _relayerThreshold = varg1;
    _fee = varg2;
    0x1f76(msg.sender, 0);
    if (!_initialize) {
        _initialize = 0;
    }
}

function _depositCounts(uint8 varg0) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    return __depositCounts[varg0];
}

function getRoleMemberIndex(bytes32 role, address account) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    return _getRoleAdmin[role].field1[account];
}

function isRelayer(address relayer) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    return bool(_getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[relayer]);
}

function paused() public nonPayable { 
    return _paused;
}

function removeRelayer(address _relayer) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    require(bool(_getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[_relayer]), Error('QBridge: invalid relayer'));
    0x1a50(_relayer, 0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4);
    emit RelayerRemoved(_relayer);
}

function renounceOwnership() public nonPayable { 
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    emit OwnershipTransferred(_owner, 0);
    _owner = 0;
}

function manualRelease(address handlerAddress, address tokenAddress, address recipient, uint256 amount) public nonPayable { 
    require(msg.data.length - 4 >= 128);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    require(bool(handlerAddress.code.size));
    v0 = handlerAddress.withdraw(tokenAddress, recipient, amount).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
}

function totalRelayers() public nonPayable { 
    v0 = 0x109f();
    return v0;
}

function owner() public nonPayable { 
    return _owner;
}

function setRelayerThreshold(uint8 newThreshold) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    _relayerThreshold = newThreshold;
    emit RelayerThresholdChanged(newThreshold);
}

function getRoleMember(bytes32 role, uint256 index) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    require(index < _getRoleAdmin[role].length, Error('EnumerableSet: index out of bounds'));
    assert(index < _getRoleAdmin[role].length);
    return address(_getRoleAdmin[role].field0[index]);
}

function lastPauseTime() public nonPayable { 
    return _lastPauseTime;
}

function hasRole(bytes32 role, address account) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    return bool(_getRoleAdmin[role].field1[account]);
}

function RELAYER_ROLE() public nonPayable { 
    return 0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4;
}

function domainID() public nonPayable { 
    return _domainID;
}

function MAX_RELAYERS() public nonPayable { 
    return 200;
}

function DEFAULT_ADMIN_ROLE() public nonPayable { 
    return 0;
}

function setResource(address handlerAddress, bytes32 resourceID, address tokenAddress) public nonPayable { 
    require(msg.data.length - 4 >= 96);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    _resourceIDToHandlerAddress[resourceID] = handlerAddress;
    require(bool(handlerAddress.code.size));
    v0 = handlerAddress.setResource(resourceID, tokenAddress).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
}

function combinedProposalId(uint8 varg0, uint64 nonce) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    return uint72(varg0 | nonce << 8 & 0xffffffffffffffff00);
}

function resourceIDToHandlerAddress(bytes32 varg0) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    return _resourceIDToHandlerAddress[varg0];
}

function setDepositNonce(uint8 varg0, uint64 nonce) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    require(nonce > __depositCounts[varg0], Error('QBridge: decrements not allowed'));
    __depositCounts[varg0] = nonce;
}

function voteProposal(uint8 domainID, uint64 depositNonce, bytes32 resourceID, bytes data) public nonPayable { 
    require(msg.data.length - 4 >= 128);
    require(data <= uint64.max);
    require(4 + data + 31 < msg.data.length);
    require(data.length <= uint64.max);
    require(4 + data + data.length + 32 <= msg.data.length);
    require(bool(_getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[msg.sender]), Error('QBridge: caller is not the relayer'));
    require(!_paused, Error('PausableUpgradeable: cannot be performed while the contract is paused'));
    require(_resourceIDToHandlerAddress[resourceID], Error('QBridge: invalid handler'));
    v0 = new uint256[](20 + (data.length + v0.data) - MEM[64] - 32);
    MEM[v0.data] = _resourceIDToHandlerAddress[resourceID];
    CALLDATACOPY(v0.data + 20, data.data, data.length);
    MEM[20 + (data.length + v0.data)] = 0;
    v1 = v0.length;
    v2 = v0.data;
    MEM[MEM[64]] = 0;
    MEM[MEM[64] + 32] = 0;
    MEM[MEM[64] + 64] = 0;
    MEM[MEM[64] + 96] = 0;
    v3 = v4 = new bytes[](4);
    assert(_getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_0_0 <= 4);
    assert(_getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_0_0 <= 4);
    MEM[v4 + 64] = _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_26_26;
    assert(v4.length <= 4);
    if (v4.length != 2) {
        assert(v4.length <= 4);
        require(v4.length <= 1, Error('QBridge: proposal already executed/cancelled'));
        v5 = v4.data;
        v6 = 0x2268(msg.sender);
        require(v6 & uint200(_getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_1_25) <= 0, Error('QBridge: relayer already voted'));
        assert(v4.length <= 4);
        if (v4.length != 0) {
            v7 = _SafeSub(uint40(_getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_27_31), block.number);
            if (uint40(v7) > _expiry) {
                assert(4 < 5);
                emit ProposalEvent(domainID, depositNonce, 4, keccak256(v0), domainID, depositNonce, 4, keccak256(v0));
            }
        } else {
            v3 = MEM[64];
            MEM[v3] = 1;
            MEM[v3 + 32] = 0;
            MEM[64 + v3] = 0;
            MEM[v3 + 96] = uint40(block.number);
            assert(1 < 5);
            emit ProposalEvent(domainID, depositNonce, 1, keccak256(v0));
        }
        assert(MEM[v3] <= 4);
        if (MEM[v3] != 4) {
            v8 = 0x2268(msg.sender);
            v9 = 0x22ad(v8, MEM[32 + v3]);
            MEM[v3 + 32] = uint200(v9);
            MEM[v3 + 64] = uint8(1 + MEM[v3 + 64]);
            assert(MEM[v3] < 5);
            emit ProposalVote(domainID, depositNonce, MEM[v3], keccak256(v0), domainID);
            if (uint8(MEM[v3 + 64]) >= _relayerThreshold) {
                MEM[v3] = 2;
                assert(2 < 5);
                emit ProposalEvent(domainID, depositNonce, 2, keccak256(v0), domainID);
            }
        }
        assert(MEM[v3] <= 4);
        _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_0_0 = MEM[v3];
        _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_1_25 = MEM[v3 + 32];
        _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_26_26 = MEM[v3 + 64];
        _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_27_31 = MEM[v3 + 96];
        assert(MEM[v3] <= 4);
        if (MEM[v3] == 2) {
            require(bool(_getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[msg.sender]), Error('QBridge: caller is not the relayer', v10, v10, 0x8c379a000000000000000000000000000000000000000000000000000000000));
            require(!_paused, Error('PausableUpgradeable: cannot be performed while the contract is paused', v10, v10, 0x8c379a000000000000000000000000000000000000000000000000000000000));
            v11 = new uint256[](20 + (data.length + v11.data) - MEM[64] - 32);
            MEM[v11.data] = _resourceIDToHandlerAddress[resourceID];
            CALLDATACOPY(v11.data + 20, data.data, data.length);
            MEM[20 + (data.length + v11.data)] = 0;
            v12 = v11.length;
            v13 = v11.data;
            assert(_getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v11)].field0_0_0 <= 4);
            require(_getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v11)].field0_0_0 == 2, Error('QBridge: Proposal must have Passed status'));
            _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v11)].field0_0_0 = 3;
            if (!0) {
                v14 = new bytes[](data.length);
                CALLDATACOPY(v14.data, data.data, data.length);
                v14[data.length] = 0;
                require(bool((_resourceIDToHandlerAddress[resourceID]).code.size));
                v15 = v16, /* uint256 */ v17 = _resourceIDToHandlerAddress[resourceID].executeProposal(resourceID, v14).gas(msg.gas);
                if (v16) {
                    v15 = 1;
                }
                if (!v15) {
                    if (!RETURNDATASIZE()) {
                        v18 = v19 = 96;
                    } else {
                        v18 = v20 = new bytes[](RETURNDATASIZE());
                        RETURNDATACOPY(v20.data, 0, RETURNDATASIZE());
                    }
                    _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v11)].field0_0_0 = 2;
                    v21 = new uint256[](MEM[v18]);
                    v22 = v23 = 0;
                    while (v22 < MEM[v18]) {
                        MEM[v22 + v21.data] = MEM[v22 + v17];
                        v22 += 32;
                    }
                    if (v22 > MEM[v18]) {
                        MEM[v21.data + MEM[v18]] = 0;
                    }
                    emit FailedHandlerExecution(v21);
                }
            } else {
                v24 = new bytes[](data.length);
                CALLDATACOPY(v24.data, data.data, data.length);
                v24[data.length] = 0;
                require(bool((_resourceIDToHandlerAddress[resourceID]).code.size));
                v25 = _resourceIDToHandlerAddress[resourceID].executeProposal(resourceID, v24).gas(msg.gas);
                require(bool(v25), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
            }
            assert(3 < 5);
            emit ProposalEvent(domainID, depositNonce, 3, keccak256(v11));
        }
    } else {
        require(bool(_getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[msg.sender]), Error('QBridge: caller is not the relayer'));
        require(!_paused, Error('PausableUpgradeable: cannot be performed while the contract is paused'));
        v26 = new uint256[](20 + (data.length + v26.data) - MEM[64] - 32);
        MEM[v26.data] = _resourceIDToHandlerAddress[resourceID];
        CALLDATACOPY(v26.data + 20, data.data, data.length);
        MEM[20 + (data.length + v26.data)] = 0;
        v27 = v26.length;
        v28 = v26.data;
        assert(_getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v26)].field0_0_0 <= 4);
        require(_getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v26)].field0_0_0 == 2, Error('QBridge: Proposal must have Passed status'));
        _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v26)].field0_0_0 = 3;
        if (!1) {
            v29 = new bytes[](data.length);
            CALLDATACOPY(v29.data, data.data, data.length);
            v29[data.length] = 0;
            require(bool((_resourceIDToHandlerAddress[resourceID]).code.size));
            v30 = v31, /* uint256 */ v32 = _resourceIDToHandlerAddress[resourceID].executeProposal(resourceID, v29).gas(msg.gas);
            if (v31) {
                v30 = 1;
            }
            if (!v30) {
                if (!RETURNDATASIZE()) {
                    v33 = v34 = 96;
                } else {
                    v33 = v35 = new bytes[](RETURNDATASIZE());
                    RETURNDATACOPY(v35.data, 0, RETURNDATASIZE());
                }
                _getProposal[uint72(domainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v26)].field0_0_0 = 2;
                v36 = new uint256[](MEM[v33]);
                v37 = v38 = 0;
                while (v37 < MEM[v33]) {
                    MEM[v37 + v36.data] = MEM[v37 + v32];
                    v37 += 32;
                }
                if (v37 > MEM[v33]) {
                    MEM[v36.data + MEM[v33]] = 0;
                }
                emit FailedHandlerExecution(v36);
            }
        } else {
            v39 = new bytes[](data.length);
            CALLDATACOPY(v39.data, data.data, data.length);
            v39[data.length] = 0;
            require(bool((_resourceIDToHandlerAddress[resourceID]).code.size));
            v40 = _resourceIDToHandlerAddress[resourceID].executeProposal(resourceID, v39).gas(msg.gas);
            require(bool(v40), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
        }
        assert(3 < 5);
        emit ProposalEvent(domainID, depositNonce, 3, keccak256(v26));
    }
}

function getRoleMemberCount(bytes32 role) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    return _getRoleAdmin[role].length;
}

function executeProposal(uint8 originDomainID, uint64 depositNonce, bytes32 resourceID, bytes data, bool revertOnFail) public nonPayable { 
    require(msg.data.length - 4 >= 160);
    require(data <= uint64.max);
    require(4 + data + 31 < msg.data.length);
    require(data.length <= uint64.max);
    require(4 + data + data.length + 32 <= msg.data.length);
    require(bool(_getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[msg.sender]), Error('QBridge: caller is not the relayer'));
    require(!_paused, Error('PausableUpgradeable: cannot be performed while the contract is paused'));
    v0 = new uint256[](20 + (data.length + v0.data) - MEM[64] - 32);
    MEM[v0.data] = _resourceIDToHandlerAddress[resourceID];
    CALLDATACOPY(v0.data + 20, data.data, data.length);
    MEM[20 + (data.length + v0.data)] = 0;
    v1 = v0.length;
    v2 = v0.data;
    assert(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_0_0 <= 4);
    require(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_0_0 == 2, Error('QBridge: Proposal must have Passed status'));
    _getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_0_0 = 3;
    if (!revertOnFail) {
        v3 = new bytes[](data.length);
        CALLDATACOPY(v3.data, data.data, data.length);
        v3[data.length] = 0;
        require(bool((_resourceIDToHandlerAddress[resourceID]).code.size));
        v4 = v5, /* uint256 */ v6 = _resourceIDToHandlerAddress[resourceID].executeProposal(resourceID, v3).gas(msg.gas);
        if (v5) {
            v4 = 1;
        }
        if (!v4) {
            if (!RETURNDATASIZE()) {
                v7 = v8 = 96;
            } else {
                v7 = v9 = new bytes[](RETURNDATASIZE());
                RETURNDATACOPY(v9.data, 0, RETURNDATASIZE());
            }
            _getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][keccak256(v0)].field0_0_0 = 2;
            v10 = new uint256[](MEM[v7]);
            v11 = v12 = 0;
            while (v11 < MEM[v7]) {
                MEM[v11 + v10.data] = MEM[v11 + v6];
                v11 += 32;
            }
            if (v11 > MEM[v7]) {
                MEM[v10.data + MEM[v7]] = 0;
            }
            emit FailedHandlerExecution(v10);
        }
    } else {
        v13 = new bytes[](data.length);
        CALLDATACOPY(v13.data, data.data, data.length);
        v13[data.length] = 0;
        require(bool((_resourceIDToHandlerAddress[resourceID]).code.size));
        v14 = _resourceIDToHandlerAddress[resourceID].executeProposal(resourceID, v13).gas(msg.gas);
        require(bool(v14), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    }
    assert(3 < 5);
    emit ProposalEvent(originDomainID, depositNonce, 3, keccak256(v0));
}

function revokeRole(bytes32 role, address account) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    0x1a50(account, role);
}

function addRelayer(address _relayer) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    require(bool(!_getRoleAdmin[0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4].field1[_relayer]), Error('QBridge: duplicated relayer'));
    v0 = 0x109f();
    require(v0 < 200, Error('QBridge: relayers limit reached'));
    0xc11(_relayer, 0xe2b7fb3b832174769106daebcfd6d1970523240dda11281102db9363b83b0dc4);
    emit 0x3580ee9f53a62b7cb409a2cb56f9be87747dd15017afc5cef6eef321e4fb2c5(_relayer);
}

function fee() public nonPayable { 
    return _fee;
}

function fallback() public payable { 
    revert();
}

function setBurnable(address handlerAddress, address tokenAddress) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    require(bool(handlerAddress.code.size));
    v0 = handlerAddress.setBurnable(tokenAddress).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
}

function expiry() public nonPayable { 
    return _expiry;
}

function getProposal(uint8 originDomainID, uint64 depositNonce, bytes32 dataHash, address relayer) public nonPayable { 
    require(msg.data.length - 4 >= 128);
    MEM[64] = MEM[64] + 128;
    MEM[MEM[64]] = 0;
    MEM[MEM[64] + 32] = 0;
    MEM[MEM[64] + 64] = 0;
    MEM[MEM[64] + 96] = 0;
    assert(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_0_0 <= 4);
    assert(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_0_0 <= 4);
    v0 = 0x2268(relayer);
    assert(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_0_0 < 5);
    return _getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_0_0, uint200(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_1_25), uint8(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_26_26), uint40(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_27_31), v0 & uint200(_getProposal[uint72(originDomainID | depositNonce << 8 & 0xffffffffffffffff00)][dataHash].field0_1_25) > 0;
}

function relayerThreshold() public nonPayable { 
    return _relayerThreshold;
}

function depositETH(uint8 destinationChainID, bytes32 resourceID, bytes data) public payable { 
    require(msg.data.length - 4 >= 96);
    require(data <= uint64.max);
    require(4 + data + 31 < msg.data.length);
    v0 = msg.data[4 + data];
    require(v0 <= uint64.max);
    require(v1.data <= msg.data.length);
    require(!_paused, Error('PausableUpgradeable: cannot be performed while the contract is paused'));
    require(4 + data + 32 + v0 - (4 + data + 32) >= 64);
    require(_fee + data.word2 >= data.word2, Error('SafeMath: addition overflow'));
    require(msg.value == _fee + data.word2, Error('QBridge: invalid fee'));
    require(_resourceIDToHandlerAddress[resourceID], Error('QBridge: invalid resourceID'));
    __depositCounts[destinationChainID] = __depositCounts[destinationChainID] + 1;
    v2 = new uint256[](v0);
    CALLDATACOPY(v2.data, 4 + data + 32, v0);
    MEM[v2 + v0 + 32] = 0;
    require(bool((_resourceIDToHandlerAddress[resourceID]).code.size));
    v3 = _resourceIDToHandlerAddress[resourceID].depositETH(resourceID, msg.sender, v2).value(data.word2).gas(msg.gas);
    require(bool(v3), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    v4 = new uint256[](v0);
    CALLDATACOPY(v4.data, 4 + data + 32, v0);
    MEM[v4 + v0 + 32] = 0;
    emit Deposit(msg.sender, destinationChainID, resourceID, uint64(__depositCounts[destinationChainID] + 1), v4);
}

function transferOwnership(address newOwner) public nonPayable { 
    require(msg.data.length - 4 >= 32);
    require(_owner == msg.sender, Error('Ownable: caller is not the owner'));
    require(newOwner, Error('Ownable: new owner is the zero address'));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
}

function 0xc11(uint256 varg0, uint256 varg1) private { 
    require(bool(_getRoleAdmin[_getRoleAdmin[varg1].field2].field1[msg.sender]), Error('AccessControl: sender must be an admin to grant'));
    0x1f76(varg0, varg1);
    return ;
}

// Note: The function selector is not present in the original solidity code.
// However, we display it for the sake of completeness.

function __function_selector__( function_selector) public payable { 
    MEM[64] = 128;
    if (msg.data.length < 4) {
        fallback();
    } else {
        v0 = function_selector >> 224;
        if (0x91d14854 > v0) {
            if (0x4e0df3f6 > v0) {
                if (0x35faa416 > v0) {
                    if (0x5e2ca17 == v0) {
                        deposit(uint8,bytes32,bytes);
                    } else if (0x16c38b3c == v0) {
                        setPaused(bool);
                    } else if (0x17f03ce5 == v0) {
                        cancelProposal(uint8,uint64,bytes32);
                    } else if (0x248a9ca3 == v0) {
                        getRoleAdmin(bytes32);
                    } else {
                        require(0x2f2ff15d == v0);
                        grantRole(bytes32,address);
                    }
                } else if (0x35faa416 == v0) {
                    sweep();
                } else if (0x36568abe == v0) {
                    renounceRole(bytes32,address);
                } else if (0x3687f24a == v0) {
                    setFee(uint128);
                } else if (0x498bbede == v0) {
                    initialize(uint8,uint8,uint128,uint40);
                } else {
                    require(0x4b0b919d == v0);
                    _depositCounts(uint8);
                }
            } else if (0x7ca21e54 > v0) {
                if (0x4e0df3f6 == v0) {
                    getRoleMemberIndex(bytes32,address);
                } else if (0x541d5548 == v0) {
                    isRelayer(address);
                } else if (0x5c975abb == v0) {
                    paused();
                } else if (0x60f0a5ac == v0) {
                    removeRelayer(address);
                } else {
                    require(0x715018a6 == v0);
                    renounceOwnership();
                }
            } else if (0x7ca21e54 == v0) {
                manualRelease(address,address,address,uint256);
            } else if (0x862159ab == v0) {
                totalRelayers();
            } else if (0x8da5cb5b == v0) {
                owner();
            } else if (0x8dcf4200 == v0) {
                setRelayerThreshold(uint8);
            } else if (0x9010d07c == v0) {
                getRoleMember(bytes32,uint256);
            } else {
                require(0x91b4ded9 == v0);
                lastPauseTime();
            }
        } else if (0xca15c873 > v0) {
            if (0xa737be4f > v0) {
                if (0x91d14854 == v0) {
                    hasRole(bytes32,address);
                } else if (0x926d7d7f == v0) {
                    RELAYER_ROLE();
                } else if (0x949fcf0e == v0) {
                    domainID();
                } else if (0x9debb3bd == v0) {
                    MAX_RELAYERS();
                } else {
                    require(0xa217fddf == v0);
                    DEFAULT_ADMIN_ROLE();
                }
            } else if (0xa737be4f == v0) {
                setResource(address,bytes32,address);
            } else if (0xab6d8266 == v0) {
                combinedProposalId(uint8,uint64);
            } else if (0xacc1b42e == v0) {
                resourceIDToHandlerAddress(bytes32);
            } else if (0xbedeed5e == v0) {
                setDepositNonce(uint8,uint64);
            } else {
                require(0xc0331b3e == v0);
                voteProposal(uint8,uint64,bytes32,bytes);
            }
        } else if (0xdf0fc133 > v0) {
            if (0xca15c873 == v0) {
                getRoleMemberCount(bytes32);
            } else if (0xd28ba851 == v0) {
                executeProposal(uint8,uint64,bytes32,bytes,bool);
            } else if (0xd547741f == v0) {
                revokeRole(bytes32,address);
            } else if (0xdd39f00d == v0) {
                addRelayer(address);
            } else {
                require(0xddca3f43 == v0);
                fee();
            }
        } else if (0xdf0fc133 == v0) {
            setBurnable(address,address);
        } else if (0xe184c9be == v0) {
            expiry();
        } else if (0xebbcdb98 == v0) {
            getProposal(uint8,uint64,bytes32,address);
        } else if (0xf0e9b0b8 == v0) {
            relayerThreshold();
        } else if (0xf179637c == v0) {
            depositETH(uint8,bytes32,bytes);
        } else {
            require(0xf2fde38b == v0);
            transferOwnership(address);
        }
    }
}
