// Decompiled by library.dedaub.com
// 2026.04.30 08:19 UTC
// Compiled using the solidity compiler version 0.8.17


// Data structures and variables inferred from the use of storage instructions
bool _paused; // STORAGE[0x0] bytes 0 to 0
string _eip712Domain; // STORAGE[0x1]
string array_2; // STORAGE[0x2]
string _version; // STORAGE[0x3]
mapping (uint256 => struct_2110) _getRoleAdmin; // STORAGE[0x5]
mapping (uint256 => struct_2114) _getRoleMemberCount; // STORAGE[0x6]
mapping (uint256 => bool) _ops; // STORAGE[0x7]
mapping (address => uint256) _nonces; // STORAGE[0x8]
mapping (uint256 => string) _startedOps; // STORAGE[0x9]
uint256 stor_a; // STORAGE[0xa]
uint256 _@_nonReentrantBefore_716; // STORAGE[0xc]
mapping (uint256 => uint8) _processedOps; // STORAGE[0xd]
mapping (address => address) _@_getPoolAdapter_7289; // STORAGE[0xe]
uint64 _@_emergencyUnlock_6253; // STORAGE[0xb] bytes 0 to 7
bool stor_b_8_8; // STORAGE[0xb] bytes 8 to 8
address _addressBook; // STORAGE[0x4] bytes 0 to 19

struct struct_2110 { mapping (address => bool) field0; uint256 field1; };
struct struct_2114 { uint256[] field0; mapping (address => uint256) field1; };

// Events
ComplexOpSet(string, bytes32, bool);
RoleGranted(bytes32, address, address);
Unpaused(address);
ComplexOpProcessed(uint64, bytes32, uint64, bytes32, uint8, uint8);
Paused(address);
RoleRevoked(bytes32, address, address);
FeePaid(address, address, uint256);

function @_checkRole_92(uint256 varg0) private {
    if (_getRoleAdmin[varg0].field0[msg.sender]) {
        return ;
    } else {
        v0 = @toHexString_2161(20, msg.sender);
        v1 = @toHexString_2161(32, varg0);
        MEM[32 + MEM[64]] = 'AccessControl: account ';
        v2 = v3 = 0;
        while (1) {
            if (v2 >= v0.length) {
                MEM[v0.length + (32 + MEM[64] + 23)] = 0;
                MEM[32 + MEM[64] + v0.length + 23] = ' is missing role ';
                v4 = v5 = 0;
                while (1) {
                    if (v4 >= v1.length) {
                        MEM[v1.length + (32 + MEM[64] + v0.length + 40)] = 0;
                        MEM[40 + (v1.length + (32 + MEM[64] + v0.length))] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
                        MEM[44 + (v1.length + (32 + MEM[64] + v0.length))] = 32;
                        MEM[44 + (v1.length + (32 + MEM[64] + v0.length)) + 32] = 40 + (v1.length + (32 + MEM[64] + v0.length)) - MEM[64] - 32;
                        v6 = v7 = 0;
                        while (v6 < 40 + (v1.length + (32 + MEM[64] + v0.length)) - MEM[64] - 32) {
                            MEM[v6 + (44 + (v1.length + (32 + MEM[64] + v0.length)) + 32 + 32)] = MEM[v6 + (MEM[64] + 32)];
                            v6 += 32;
                        }
                        MEM[40 + (v1.length + (32 + MEM[64] + v0.length)) - MEM[64] - 32 + (44 + (v1.length + (32 + MEM[64] + v0.length)) + 32 + 32)] = 0;
                        revert(MEM[64], 32 + ((0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 31 + (40 + (v1.length + (32 + MEM[64] + v0.length)) - MEM[64] - 32)) + (44 + (v1.length + (32 + MEM[64] + v0.length)) + 32)) - MEM[64]);
                    } else {
                        MEM[v4 + (32 + MEM[64] + v0.length + 40)] = v1[v4];
                        v4 += 32;
                        continue;
                    }
                }
            } else {
                MEM[v2 + (32 + MEM[64] + 23)] = v0[v2];
                v2 += 32;
                continue;
            }
        }
    }
}

function @_grantRole_415(address varg0, uint256 varg1) private {
    if (!_getRoleAdmin[varg1].field0[varg0]) {
        _getRoleAdmin[varg1].field0[varg0] = 1;
        emit RoleGranted(varg1, varg0, msg.sender);
    }
    v0 = varg0;
    if (!_getRoleMemberCount[varg1].field1[v0]) {
        v1 = 1;
        _getRoleMemberCount[varg1].length += v1;
        _getRoleMemberCount[varg1].field0[_getRoleMemberCount[varg1].length] = v0;
        _getRoleMemberCount[varg1].field1[v0] = _getRoleMemberCount[varg1].length;
    }
    return ;
}

function @_revokeRole_439(uint256 varg0, uint256 varg1) private {
    @_revokeRole_314(varg0, varg1);
    v0 = keccak256(varg1, 6);
    v1 = address(varg0);
    if (_getRoleMemberCount[varg1].field1[v1]) {
        v2 = _SafeSub(_getRoleMemberCount[varg1].field1[v1], 1);
        v3 = _SafeSub(_getRoleMemberCount[varg1].length, 1);
        if (v3 != v2) {
            require(v3 < _getRoleMemberCount[varg1].length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            require(v2 < _getRoleMemberCount[varg1].length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            _getRoleMemberCount[varg1].field0[v2] = _getRoleMemberCount[varg1].field0[v3];
            _getRoleMemberCount[varg1].field1[_getRoleMemberCount[varg1].field0[v3]] = _getRoleMemberCount[varg1].field1[v1];
        }
        require(_getRoleMemberCount[varg1].length, Panic(49)); // attemp to .pop an empty array
        _getRoleMemberCount[varg1].field0[_getRoleMemberCount[varg1].length - 1] = 0;
        _getRoleMemberCount[varg1].length = _getRoleMemberCount[varg1].length - 1;
        _getRoleMemberCount[varg1].field1[v1] = 0;
    }
    return ;
}

function @_unpause_670() private {
    require(_paused, Error('Pausable: not paused'));
    _paused = 0;
    emit Unpaused(msg.sender);
    return ;
}

function @_nonReentrantBefore_716() private {
    require(_@_nonReentrantBefore_716 - 2, Error('ReentrancyGuard: reentrant call'));
    _@_nonReentrantBefore_716 = 2;
    return ;
}

function @_pause_654() private {
    require(!_paused, Error('Pausable: paused'));
    _paused = 1;
    emit Paused(msg.sender);
    return ;
}

function @_revokeRole_314(address varg0, uint256 varg1) private {
    if (!_getRoleAdmin[varg1].field0[varg0]) {
        return ;
    } else {
        _getRoleAdmin[varg1].field0[varg0] = 0;
        emit RoleRevoked(varg1, varg0, msg.sender);
        return ;
    }
}

function @toHexString_2161(uint256 varg0, uint256 varg1) private {
    require((varg0 == varg0 << 1 >> 1) | !0x2, Panic(17)); // arithmetic overflow or underflow
    v0 = (varg0 << 1) + 2;
    require(2 <= v0, Panic(17)); // arithmetic overflow or underflow
    require(v0 <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v1 = new bytes[](v0);
    if (v0) {
        CALLDATACOPY(v1.data, msg.data.length, v0);
    }
    require(0 < v1.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
    MEM8[v1.data] = (byte(bytes1(0x3000000000000000000000000000000000000000000000000000000000000000), 0x0)) & 0xFF;
    require(1 < v1.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
    MEM8[33 + v1] = (byte(bytes1(0x7800000000000000000000000000000000000000000000000000000000000000), 0x0)) & 0xFF;
    require((varg0 == varg0 << 1 >> 1) | !0x2, Panic(17)); // arithmetic overflow or underflow
    v2 = (varg0 << 1) + 1;
    require(1 <= v2, Panic(17)); // arithmetic overflow or underflow
    while (v2 > 1) {
        require(bool(varg1) < 16, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(v2 < v1.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        MEM8[32 + v2 + v1] = (byte(bytes1((byte('0123456789abcdef', bool(varg1))) << 248), 0x0)) & 0xFF;
        varg1 = varg1 >> 4;
        require(v2, Panic(17)); // arithmetic overflow or underflow
        v2 += uint256.max;
    }
    require(!varg1, Error('Strings: hex length insufficient'));
    return v1;
}

function receive() public payable {
}

function supportsInterface(bytes4 interfaceId) public nonPayable {
    require(msg.data.length - 4 >= 32);
    v0 = v1 = 0x5a05180f00000000000000000000000000000000000000000000000000000000 == interfaceId;
    if (0x5a05180f00000000000000000000000000000000000000000000000000000000 != interfaceId) {
        v0 = v2 = 0x7965db0b00000000000000000000000000000000000000000000000000000000 == interfaceId;
        if (0x7965db0b00000000000000000000000000000000000000000000000000000000 != interfaceId) {
            v0 = v3 = interfaceId == 0x1ffc9a700000000000000000000000000000000000000000000000000000000;
        }
    }
    return bool(v0);
}

function @_getRequestId_5249(uint64 varg0, address varg1) private {
    v0, /* address */ v1 = _addressBook.gateKeeper().gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v1 == address(v1));
    v2, /* uint256 */ v3 = address(v1).getNonce().gas(msg.gas);
    require(bool(v2), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    return keccak256(this, v3, varg0, CHAINID(), varg1);
}

function setAddressBook(address varg0) public nonPayable {
    require(msg.data.length - 4 >= 32);
    @_checkRole_92(0);
    require(varg0, Error('EndPoint: zero address'));
    _addressBook = varg0;
}

function castToAddress(bytes32 x) public nonPayable {
    require(msg.data.length - 4 >= 32);
    return address(x);
}

function EMERGENCY_MINT_CODE() public nonPayable {
    return keccak256(8533);
}

function getRoleAdmin(bytes32 role) public nonPayable {
    require(msg.data.length - 4 >= 32);
    return _getRoleAdmin[role].field1;
}

function WRAP_CODE() public nonPayable {
    return keccak256(87);
}

function REMOVE_CODE() public nonPayable {
    return keccak256(0x5200000000000000000000000000000000000000000000000000000000000000);
}

function @_getPoolAdapter_7289(address varg0) private {
    require(_@_getPoolAdapter_7289[varg0], Error('UnifiedRouterV2: pool adapter not set'));
    return _@_getPoolAdapter_7289[varg0];
}

function LOCK_MINT_CODE() public nonPayable {
    return keccak256(19533);
}

function @_checkTo_7265(uint256 varg0, uint64 varg1, address varg2, uint256 varg3) private {
    varg3 = v0 = 0;
    v1 = v2 = !address(varg3);
    if (address(varg3)) {
        v1 = !varg0;
    }
    require(v1, Error('Router: wrong to'));
    if (varg0) {
        if (varg0 - keccak256(19533)) {
            v3 = v4 = varg0 == keccak256(16981);
            if (varg0 != keccak256(16981)) {
                v3 = varg0 == keccak256(16973);
            }
            if (!v3) {
                if (keccak256(87) == varg0) {
                    if (keccak256(87) == varg0) {
                        v5 = v6 = _addressBook;
                    }
                } else if (!(keccak256(21879) - varg0)) {
                    v5 = v7 = _addressBook;
                }
                v8, varg3 = v5.router(varg1, 0xd0fe96ae00000000000000000000000000000000000000000000000000000000, varg1, varg1).gas(msg.gas);
                require(bool(v8), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                require(varg3 == address(varg3));
            } else {
                v9 = v10 = _addressBook;
            }
        } else {
            v9 = v11 = _addressBook;
        }
        v12, varg3 = v9.portal(0xd4f0cceb, varg1, varg1).gas(msg.gas);
        require(bool(v12), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
        require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
        require(varg3 == address(varg3));
    } else {
        require(address(varg3) == varg2, Error('Router: wrong receiver'));
    }
    if (address(varg3)) {
        return varg3;
    } else {
        v13 = v14 = varg0 == keccak256(65);
        if (varg0 != keccak256(65)) {
            v13 = v15 = varg0 == keccak256(0x5200000000000000000000000000000000000000000000000000000000000000);
        }
        if (!v13) {
            v13 = v16 = varg0 == keccak256(83);
        }
        if (!v13) {
            return varg3;
        } else {
            v17, /* address */ v18 = _addressBook.router(varg1).gas(msg.gas);
            require(bool(v17), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
            require(v18 == address(v18));
            return v18;
        }
    }
}

function grantRole(bytes32 role, address account) public nonPayable {
    require(msg.data.length - 4 >= 64);
    @_checkRole_92(_getRoleAdmin[role].field1);
    @_grantRole_415(account, role);
}

function @_transferToAdapter_7331(uint256 varg0, address varg1, address varg2, address varg3) private {
    if (varg2 - this) {
        v0 = v1 = 0;
        while (v0 < 132 + MEM[64] - MEM[64] - 32) {
            MEM[v0 + MEM[64]] = MEM[v0 + (MEM[64] + 32)];
            v0 += 32;
        }
        MEM[132 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
        v2, /* uint256 */ v3, /* uint256 */ v4, /* uint256 */ v5 = varg3.transferFrom(varg2, varg1, varg0).gas(msg.gas);
        if (RETURNDATASIZE() == 0) {
            v6 = v7 = 96;
        } else {
            v6 = v8 = new bytes[](RETURNDATASIZE());
            RETURNDATACOPY(v8.data, 0, RETURNDATASIZE());
        }
        if (!v2) {
            require(!MEM[v6], v5, MEM[v6]);
            v9 = new bytes[](v10.length);
            v11 = v12 = 0;
            while (v11 < v10.length) {
                v9[v11] = v10[v11];
                v11 += 32;
            }
            v9[v10.length][32] = 0;
            revert(Error(v9, v13, 'SafeERC20: low-level call failed'));
        } else {
            if (!(0 - MEM[v6])) {
                require(varg3.code.size, Error('Address: call to non-contract'));
            }
            v14 = v15 = 0 == MEM[v6];
            if (0 != MEM[v6]) {
                require(32 + v6 + MEM[v6] - (32 + v6) >= 32);
                v14 = MEM[32 + v6];
                require(v14 == bool(v14));
            }
            require(v14, Error('SafeERC20: ERC20 operation did not succeed'));
            return ;
        }
    } else {
        v16 = v17 = 0;
        while (v16 < 100 + MEM[64] - MEM[64] - 32) {
            MEM[v16 + MEM[64]] = MEM[v16 + (MEM[64] + 32)];
            v16 += 32;
        }
        MEM[100 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
        v18, /* uint256 */ v19, /* uint256 */ v20, /* uint256 */ v21 = varg3.transfer(varg1, varg0).gas(msg.gas);
        if (RETURNDATASIZE() == 0) {
            v22 = v23 = 96;
        } else {
            v22 = v24 = new bytes[](RETURNDATASIZE());
            RETURNDATACOPY(v24.data, 0, RETURNDATASIZE());
        }
        if (!v18) {
            require(!MEM[v22], v21, MEM[v22]);
            v25 = new bytes[](v26.length);
            v27 = v28 = 0;
            while (v27 < v26.length) {
                v25[v27] = v26[v27];
                v27 += 32;
            }
            v25[v26.length][32] = 0;
            revert(Error(v25, v13, 'SafeERC20: low-level call failed'));
        } else {
            if (!(0 - MEM[v22])) {
                require(varg3.code.size, Error('Address: call to non-contract'));
            }
            v29 = v30 = 0 == MEM[v22];
            if (0 != MEM[v22]) {
                require(32 + v22 + MEM[v22] - (32 + v22) >= 32);
                v29 = MEM[32 + v22];
                require(v29 == bool(v29));
            }
            require(v29, Error('SafeERC20: ERC20 operation did not succeed'));
            return ;
        }
    }
}

function renounceRole(bytes32 role, address account) public nonPayable {
    require(msg.data.length - 4 >= 64);
    require(msg.sender == account, Error('AccessControl: can only renounce roles for self'));
    @_revokeRole_439(account, role);
}

function castToBytes32(address a) public nonPayable {
    require(msg.data.length - 4 >= 32);
    return a;
}

function @_lock_6169(struct(7) varg0) private {
    v0, /* address */ v1 = _addressBook.portal(uint64(CHAINID())).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v1 == address(v1));
    if (address(varg0.word2) != address(v1)) {
        v2 = v3 = 0;
        while (v2 < 132 + MEM[64] - MEM[64] - 32) {
            MEM[v2 + MEM[64]] = MEM[v2 + (MEM[64] + 32)];
            v2 += 32;
        }
        MEM[132 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
        v4, /* uint256 */ v5, /* uint256 */ v6, /* uint256 */ v7 = address(varg0.word0).transferFrom(address(varg0.word2), address(v1), varg0.word1).gas(msg.gas);
        if (RETURNDATASIZE() == 0) {
            v8 = v9 = 96;
        } else {
            v8 = v10 = new bytes[](RETURNDATASIZE());
            RETURNDATACOPY(v10.data, 0, RETURNDATASIZE());
        }
        if (!v4) {
            require(!MEM[v8], v7, MEM[v8]);
            v11 = new bytes[](v12.length);
            v13 = v14 = 0;
            while (v13 < v12.length) {
                v11[v13] = v12[v13];
                v13 += 32;
            }
            v11[v12.length][32] = 0;
            revert(Error(v11, v15, 'SafeERC20: low-level call failed'));
        } else {
            if (!(0 - MEM[v8])) {
                require((address(varg0.word0)).code.size, Error('Address: call to non-contract'));
            }
            v16 = v17 = 0 == MEM[v8];
            if (0 != MEM[v8]) {
                require(32 + v8 + MEM[v8] - (32 + v8) >= 32);
                v16 = MEM[32 + v8];
                require(v16 == bool(v16));
            }
            require(v16, Error('SafeERC20: ERC20 operation did not succeed'));
        }
    }
    require(bool((address(v1)).code.size));
    v18 = address(v1).setGraveNft(address(varg0.word0), varg0.word1, address(varg0.word2), address(varg0.word3)).gas(msg.gas);
    require(bool(v18), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    return ;
}

function @_mint_6293(struct(7) varg0) private {
    v0, /* address */ v1 = _addressBook.synthesis(uint64(CHAINID())).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v1 == address(v1));
    v2, /* uint256 */ v3 = address(v1).mint(address(varg0.word0), varg0.word1, address(varg0.word2), address(varg0.word3), uint64(varg0.word5)).gas(msg.gas);
    require(bool(v2), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    return v3;
}

function unpause() public nonPayable {
    @_checkRole_92(0);
    @_unpause_670();
}

function @_unlock_6207(struct(7) varg0) private {
    v0, /* address */ v1 = _addressBook.portal(uint64(CHAINID())).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v1 == address(v1));
    v2, /* uint256 */ v3 = address(v1).unlock(address(varg0.word0), varg0.word1, address(varg0.word2), address(varg0.word3)).gas(msg.gas);
    require(bool(v2), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    return v3;
}

function version() public nonPayable {
    v0 = v1 = _version.length >> 1;
    if (!(_version.length & 0x1)) {
        v0 = v2 = v1 & 0x7f;
    }
    require((_version.length & 0x1) - (v0 < 32), Panic(34)); // access to incorrectly encoded storage byte array
    v3 = new bytes[](v0);
    v4 = v5 = v3.data;
    v6 = v7 = _version.length >> 1;
    if (!(_version.length & 0x1)) {
        v6 = v8 = v7 & 0x7f;
    }
    require((_version.length & 0x1) - (v6 < 32), Panic(34)); // access to incorrectly encoded storage byte array
    if (v6) {
        if (31 < v6) {
            v9 = v10 = _version.data;
            while (v5 + v6 > v4) {
                MEM[v4] = STORAGE[v9];
                v9 += 1;
                v4 += 32;
            }
        } else {
            MEM[v5] = _version.length >> 8 << 8;
        }
    }
    v11 = new bytes[](v3.length);
    v12 = v13 = 0;
    while (v12 < v3.length) {
        v11[v12] = v3[v12];
        v12 += 32;
    }
    v11[v3.length] = 0;
    return v11;
}

function @_emergencyUnlock_6253(struct(7) varg0) private {
    require(uint64(varg0.word4) == _@_emergencyUnlock_6253, Error('Router: wrong emergency init'));
    v0, /* address */ v1 = _addressBook.portal(uint64(CHAINID())).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v1 == address(v1));
    v2, /* uint256 */ v3 = address(v1).emergencyUnlock(address(varg0.word0), varg0.word1, address(varg0.word2), address(varg0.word6)).gas(msg.gas);
    require(bool(v2), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    return v3;
}

function paused() public nonPayable {
    return _paused;
}

function @_emergencyMint_6353(struct(7) varg0) private {
    require(uint64(varg0.word4) == _@_emergencyUnlock_6253, Error('Router: wrong emergency init'));
    v0, /* address */ v1 = _addressBook.synthesis(uint64(CHAINID())).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v1 == address(v1));
    v2, /* address */ v3 = address(v1).synthByOriginal(uint64(varg0.word5), address(varg0.word0)).gas(msg.gas);
    require(bool(v2), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v3 == address(v3));
    varg0.word0 = address(v3);
    v4, /* uint256 */ v5 = address(v1).emergencyMint(address(v3), varg0.word1, address(varg0.word2), address(varg0.word6)).gas(msg.gas);
    require(bool(v4), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    return v5;
}

function BURN_MINT_CODE() public nonPayable {
    return keccak256(16973);
}

function ops(bytes32 varg0) public nonPayable {
    require(msg.data.length - 4 >= 32);
    return _ops[varg0];
}

function resume(bytes32 requestId, uint8 cPos, string[] operations, bytes[] params) public nonPayable {
    require(msg.data.length - 4 >= 128);
    require(operations <= uint64.max);
    require(4 + operations + 31 < msg.data.length);
    require(operations.length <= uint64.max);
    v0 = v1 = operations.data;
    require(4 + operations + (operations.length << 5) + 32 <= msg.data.length);
    require(params <= uint64.max);
    require(4 + params + 31 < msg.data.length);
    require(params.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v2 = new uint256[](params.length);
    require(!((v2 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (params.length << 5) + 31) < v2) | (v2 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (params.length << 5) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    v3 = v4 = v2.data;
    require(32 + (4 + params + (params.length << 5)) <= msg.data.length);
    v5 = v6 = params.data;
    while (v5 < 32 + (4 + params + (params.length << 5))) {
        require(msg.data[v5] <= uint64.max);
        require(msg.data.length > 4 + params + msg.data[v5] + 63);
        v7 = msg.data[4 + params + msg.data[v5] + 32];
        require(v7 <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
        v8 = new bytes[](v7);
        require(!((v8 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & v7 + 31) + 31) < v8) | (v8 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & v7 + 31) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
        require(4 + params + msg.data[v5] + 64 + v7 <= msg.data.length);
        CALLDATACOPY(v8.data, 4 + params + msg.data[v5] + 64, v7);
        v8[v7] = 0;
        MEM[v3] = v8;
        v3 += 32;
        v5 += 32;
    }
    v9, /* address */ v10 = _addressBook.bridge().gas(msg.gas);
    require(bool(v9), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v10 == address(v10));
    require(msg.sender == address(v10), Error('Router: bridge only'));
    stor_a = requestId;
    @_nonReentrantBefore_716();
    require(operations.length < uint8.max + 1, Error('BaseRouter: wrong params count'));
    require(operations.length == v2.length, Error('BaseRouter: wrong params'));
    require(cPos < v2.length, Error('BaseRouter: wrong params'));
    v11 = v12 = cPos;
    v13 = v14 = 0;
    v11 = v15 = 0;
    require(!_paused, Error('Pausable: paused'));
    v16 = v17 = MEM[64];
    MEM[64] = v17 + 96;
    MEM[v17] = 0;
    MEM[v17 + 32] = 0;
    MEM[v17 + 64] = 0;
    while (v11 < operations.length) {
        v18 = v19 = bool(stor_a);
        if (stor_a) {
            v18 = v11 == v12;
        }
        require(v11 < operations.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(operations[v11] < msg.data.length - v1 - 31);
        require(msg.data[v1 + operations[v11]] <= uint64.max);
        require(32 + (v1 + operations[v11]) <= msg.data.length - msg.data[v1 + operations[v11]]);
        CALLDATACOPY(v20.data, 32 + (v1 + operations[v11]), msg.data[v1 + operations[v11]]);
        MEM[msg.data[v1 + operations[v11]] + v20.data] = 0;
        v21 = _SafeSub(operations.length, 1);
        if (v11 < v21) {
            require(1 <= v11 + 1, Panic(17)); // arithmetic overflow or underflow
            require(v11 + 1 < operations.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            require(operations[v11 + 1] < msg.data.length - v1 - 31);
            require(msg.data[v1 + operations[v11 + 1]] <= uint64.max);
            require(32 + (v1 + operations[v11 + 1]) <= msg.data.length - msg.data[v1 + operations[v11 + 1]]);
            CALLDATACOPY(MEM[64], 32 + (v1 + operations[v11 + 1]), msg.data[v1 + operations[v11 + 1]]);
            MEM[msg.data[v1 + operations[v11 + 1]] + MEM[64]] = 0;
            v22 = v23 = keccak256(v24.data);
        } else {
            v22 = v25 = 0;
        }
        require(v11 < v2.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        MEM[MEM[64]] = 0;
        MEM[MEM[64] + 32] = 0;
        MEM[MEM[64] + 64] = 0;
        v16 = new struct(3);
        v26 = v27 = 96;
        v13 = v28 = 0;
        v16.word0 = v28;
        v16.word1 = v28;
        v16.word2 = v28;
        v11 = v29 = 1;
        if (keccak256(0x5000000000000000000000000000000000000000000000000000000000000000) - keccak256(v20.data)) {
            v30 = v31 = keccak256(19533) == keccak256(v20.data);
            if (keccak256(19533) != keccak256(v20.data)) {
                v30 = v32 = keccak256(16981) == keccak256(v20.data);
            }
            if (!v30) {
                v30 = keccak256(16973) == keccak256(v20.data);
            }
            if (!v30) {
                v33 = v34 = keccak256(87) == keccak256(v20.data);
                if (keccak256(87) != keccak256(v20.data)) {
                    v33 = keccak256(21879) == keccak256(v20.data);
                }
                if (!v33) {
                    v35 = v36 = keccak256(8525) == keccak256(v20.data);
                    if (keccak256(8525) != keccak256(v20.data)) {
                        v35 = keccak256(8533) == keccak256(v20.data);
                    }
                    if (!v35) {
                        v11 = v37 = 0;
                    } else {
                        require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= 64);
                        v38 = new struct(2);
                        require(!((v38 + 64 > uint64.max) | (v38 + 64 < v38)), Panic(65)); // failed memory allocation (too much memory)
                        v38.word0 = MEM[32 + v2[v11]];
                        require(MEM[32 + v2[v11] + 32] == uint64(MEM[32 + v2[v11] + 32]));
                        v38.word1 = MEM[32 + v2[v11] + 32];
                        if (0 - bool(v18)) {
                            v39 = v40 = _startedOps[v38.word0].length >> 1;
                            if (!(_startedOps[v38.word0].length & 0x1)) {
                                v39 = v41 = v40 & 0x7f;
                            }
                            require((_startedOps[v38.word0].length & 0x1) - (v39 < 32), Panic(34)); // access to incorrectly encoded storage byte array
                            v42 = new bytes[](v39);
                            v43 = v44 = v42.data;
                            v45 = v46 = _startedOps[v38.word0].length >> 1;
                            if (!(_startedOps[v38.word0].length & 0x1)) {
                                v45 = v47 = v46 & 0x7f;
                            }
                            require((_startedOps[v38.word0].length & 0x1) - (v45 < 32), Panic(34)); // access to incorrectly encoded storage byte array
                            if (v45) {
                                if (31 < v45) {
                                    v48 = v49 = _startedOps[v38.word0].data;
                                    while (v44 + v45 > v43) {
                                        MEM[v43] = STORAGE[v48];
                                        v48 += 1;
                                        v43 += 32;
                                    }
                                } else {
                                    MEM[v44] = _startedOps[v38.word0].length >> 8 << 8;
                                }
                            }
                            require(0 - v42.length, Error('Router: op not started'));
                            require(v42.data + v42.length - v42.data >= 224);
                            v50 = allocate_memory_7374();
                            require(MEM[v42.data] == address(MEM[v42.data]));
                            v50.word0 = MEM[v42.data];
                            v50.word1 = v42[32][32];
                            require(v42[64] == address(v42[64]));
                            v50.word2 = v42[64];
                            require(v42[96] == address(v42[96]));
                            v50.word3 = v42[96];
                            require(v42[128] == uint64(v42[128]));
                            v50.word4 = v42[128];
                            require(v42[160] == uint64(v42[160]));
                            v50.word5 = v42[160];
                            require(v42[192] == address(v42[192]));
                            v50.word6 = v42[192];
                            v51 = v52 = _startedOps[v38.word0].length >> 1;
                            if (!(_startedOps[v38.word0].length & 0x1)) {
                                v51 = v53 = v52 & 0x7f;
                            }
                            require((_startedOps[v38.word0].length & 0x1) - (v51 < 32), Panic(34)); // access to incorrectly encoded storage byte array
                            _startedOps[v38.word0].length = 0;
                            if (31 < v51) {
                                v54 = v55 = _startedOps[v38.word0].data;
                                while (v55 + (31 + v51 >> 5) > v54) {
                                    STORAGE[v54] = 0;
                                    v54 += 1;
                                }
                            }
                            if (keccak256(8525) - keccak256(v20.data)) {
                                v56 = @_emergencyMint_6353(v50);
                                v16.word0 = v56;
                            } else {
                                v57 = @_emergencyUnlock_6253(v50);
                                v16.word0 = v57;
                            }
                        } else {
                            require(_processedOps[v38.word0] <= 2, Panic(33)); // failed convertion to enum type
                            require(_processedOps[v38.word0] - 1, Error('Router: op processed'));
                            _processedOps[v38.word0] = 2;
                            v13 = v58 = v38.word1;
                        }
                    }
                } else {
                    require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= 128);
                    v59 = new struct(4);
                    require(!((v59 + 128 > uint64.max) | (v59 + 128 < v59)), Panic(65)); // failed memory allocation (too much memory)
                    require(MEM[32 + v2[v11]] == address(MEM[32 + v2[v11]]));
                    v59.word0 = MEM[32 + v2[v11]];
                    v59.word1 = MEM[64 + v2[v11]];
                    require(MEM[32 + v2[v11] + 64] == address(MEM[32 + v2[v11] + 64]));
                    v59.word2 = MEM[32 + v2[v11] + 64];
                    require(MEM[32 + v2[v11] + 96] == address(MEM[32 + v2[v11] + 96]));
                    v59.word3 = MEM[32 + v2[v11] + 96];
                    v60 = v61 = v59.word1;
                    v62 = v63 = v59.word2;
                    v64 = v65 = 0;
                    if (v61 == uint256.max) {
                        v60 = v66 = MEM[v16];
                    }
                    if (!address(v63)) {
                        v62 = v67 = MEM[32 + v16];
                    } else {
                        require(msg.sender == address(v63), Error('Router: wrong sender'));
                    }
                    v68 = v69 = !stor_a;
                    if (!bool(stor_a)) {
                        v68 = bool(address(v65));
                    }
                    if (v68) {
                        require(msg.sender == address(v65), Error('Router: wrong emergencyTo'));
                    }
                    v59.word2 = address(v62);
                    v59.word1 = v60;
                    v70 = @_checkTo_7265(v22, CHAINID(), v59.word3, v59.word3);
                    v59.word3 = address(v70);
                    if (keccak256(87) == keccak256(v20.data)) {
                        require(msg.value >= v59.word1, Error('Router: invalid amount'));
                        require(bool((address(v59.word0)).code.size));
                        v71 = address(v59.word0).deposit().value(v59.word1).gas(msg.gas);
                        if (bool(v71)) {
                            MEM[MEM[64] + 36] = address(v59.word3);
                            MEM[MEM[64] + 68] = v59.word1;
                            MEM[MEM[64] + 32] = bytes4(0xa9059cbb00000000000000000000000000000000000000000000000000000000) | uint224(MEM[MEM[64] + 32]);
                            v72 = v73 = 0;
                            while (v72 < 100 + MEM[64] - MEM[64] - 32) {
                                MEM[v72 + MEM[64]] = MEM[v72 + (MEM[64] + 32)];
                                v72 += 32;
                            }
                            MEM[100 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
                            v74 = address(v59.word0).call(MEM[MEM[64]:MEM[64] + 100 + MEM[64] - MEM[64] - 32 + MEM[64] - MEM[64]], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                            if (RETURNDATASIZE() == 0) {
                                v75 = v76 = 96;
                            } else {
                                v75 = v77 = MEM[64];
                                MEM[64] = v77 + (RETURNDATASIZE() + 63 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                                MEM[v77] = RETURNDATASIZE();
                                RETURNDATACOPY(v77 + 32, 0, RETURNDATASIZE());
                            }
                            if (!v74) {
                                require(!MEM[v75], 32 + v75, MEM[v75]);
                                v78 = new bytes[](v79.length);
                                v80 = v81 = 0;
                                while (v80 < v79.length) {
                                    v78[v80] = v79[v80];
                                    v80 += 32;
                                }
                                v78[v79.length][32] = 0;
                                revert(Error(v78, v82, 'SafeERC20: low-level call failed'));
                            } else {
                                if (!(0 - MEM[v75])) {
                                    require((address(v59.word0)).code.size, Error('Address: call to non-contract'));
                                }
                                v83 = v84 = 0 == MEM[v75];
                                if (0 != MEM[v75]) {
                                    require(32 + v75 + MEM[v75] - (32 + v75) >= 32);
                                    v83 = MEM[32 + v75];
                                    require(v83 == bool(v83));
                                }
                                require(v83, Error('SafeERC20: ERC20 operation did not succeed'));
                                v16.word0 = v59.word1;
                                v16.word1 = address(v59.word3);
                                v16.word2 = address(MEM[64 + v16]);
                            }
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    } else {
                        if (this != address(v59.word2)) {
                            MEM[MEM[64] + 36] = address(v59.word2);
                            MEM[MEM[64] + 68] = address(this);
                            MEM[MEM[64] + 100] = v59.word1;
                            MEM[MEM[64] + 32] = bytes4(0x23b872dd00000000000000000000000000000000000000000000000000000000) | uint224(MEM[MEM[64] + 32]);
                            v85 = v86 = 0;
                            while (v85 < 132 + MEM[64] - MEM[64] - 32) {
                                MEM[v85 + MEM[64]] = MEM[v85 + (MEM[64] + 32)];
                                v85 += 32;
                            }
                            MEM[132 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
                            v87 = address(v59.word0).call(MEM[MEM[64]:MEM[64] + 132 + MEM[64] - MEM[64] - 32 + MEM[64] - MEM[64]], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                            if (RETURNDATASIZE() == 0) {
                                v88 = v89 = 96;
                            } else {
                                v88 = v90 = MEM[64];
                                MEM[64] = v90 + (RETURNDATASIZE() + 63 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                                MEM[v90] = RETURNDATASIZE();
                                RETURNDATACOPY(v90 + 32, 0, RETURNDATASIZE());
                            }
                            if (!v87) {
                                require(!MEM[v88], 32 + v88, MEM[v88]);
                                v91 = new bytes[](v92.length);
                                v93 = v94 = 0;
                                while (v93 < v92.length) {
                                    v91[v93] = v92[v93];
                                    v93 += 32;
                                }
                                v91[v92.length][32] = 0;
                                revert(Error(v91, v82, 'SafeERC20: low-level call failed'));
                            } else {
                                if (!(0 - MEM[v88])) {
                                    require((address(v59.word0)).code.size, Error('Address: call to non-contract'));
                                }
                                v95 = v96 = 0 == MEM[v88];
                                if (0 != MEM[v88]) {
                                    require(32 + v88 + MEM[v88] - (32 + v88) >= 32);
                                    v95 = MEM[32 + v88];
                                    require(v95 == bool(v95));
                                }
                                require(v95, Error('SafeERC20: ERC20 operation did not succeed'));
                            }
                        }
                        MEM[MEM[64]] = 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000;
                        MEM[4 + MEM[64]] = v59.word1;
                        require(bool((address(v59.word0)).code.size));
                        v97 = address(v59.word0).call(MEM[MEM[64]:MEM[64] + 36], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                        if (bool(v97)) {
                            v98 = address(v59.word3).call().value(v59.word1).gas(msg.gas);
                            if (RETURNDATASIZE() != 0) {
                                MEM[MEM[64]] = RETURNDATASIZE();
                                RETURNDATACOPY(MEM[64] + 32, 0, RETURNDATASIZE());
                            }
                            require(v98, Error('Router: failed to send ETH'));
                            v16.word0 = v59.word1;
                            v16.word1 = address(v59.word3);
                            v16.word2 = address(MEM[64 + v16]);
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    }
                }
            } else {
                require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= 224);
                v99 = allocate_memory_7374();
                require(MEM[32 + v2[v11]] == address(MEM[32 + v2[v11]]));
                v99.word0 = MEM[32 + v2[v11]];
                v99.word1 = MEM[64 + v2[v11]];
                require(MEM[32 + v2[v11] + 64] == address(MEM[32 + v2[v11] + 64]));
                v99.word2 = MEM[32 + v2[v11] + 64];
                require(MEM[32 + v2[v11] + 96] == address(MEM[32 + v2[v11] + 96]));
                v99.word3 = MEM[32 + v2[v11] + 96];
                require(MEM[32 + v2[v11] + 128] == uint64(MEM[32 + v2[v11] + 128]));
                v99.word4 = MEM[32 + v2[v11] + 128];
                require(MEM[32 + v2[v11] + 160] == uint64(MEM[32 + v2[v11] + 160]));
                v99.word5 = MEM[32 + v2[v11] + 160];
                require(MEM[32 + v2[v11] + 192] == address(MEM[32 + v2[v11] + 192]));
                v99.word6 = MEM[32 + v2[v11] + 192];
                if (0 - bool(v18)) {
                    require(_processedOps[stor_a] <= 2, Panic(33)); // failed convertion to enum type
                    require(_processedOps[stor_a] == 0, Error('Router: op processed'));
                    _processedOps[stor_a] = 1;
                    if (!address(v99.word3)) {
                        v100 = @_checkTo_7265(v22, v99.word4, v99.word6, v99.word3);
                        v99.word3 = address(v100);
                    }
                    if (keccak256(16981) == keccak256(v20.data)) {
                        v101 = v102 = @_unlock_6207(v99);
                    } else {
                        v101 = v103 = @_mint_6293(v99);
                    }
                    v16.word0 = v101;
                    v16.word1 = address(v99.word3);
                    v16.word2 = address(v99.word6);
                } else {
                    v104 = v105 = v99.word1;
                    v106 = v107 = v99.word2;
                    v108 = v109 = v99.word6;
                    if (v105 == uint256.max) {
                        v104 = v110 = MEM[v16];
                    }
                    if (!address(v107)) {
                        v106 = v111 = MEM[32 + v16];
                    } else {
                        require(msg.sender == address(v107), Error('Router: wrong sender'));
                    }
                    v112 = v113 = !stor_a;
                    if (!bool(stor_a)) {
                        v112 = bool(address(v109));
                    }
                    if (!v112) {
                        v108 = MEM[v16 + 64];
                    } else {
                        require(msg.sender == address(v109), Error('Router: wrong emergencyTo'));
                    }
                    v99.word6 = address(v108);
                    v99.word2 = address(v106);
                    v99.word1 = v104;
                    v114 = @_checkTo_7265(v22, v99.word4, address(v108), v99.word3);
                    v99.word3 = address(v114);
                    v115 = v116 = 0;
                    if (keccak256(19533) - keccak256(v20.data)) {
                        v117 = _addressBook.synthesis(uint64(CHAINID())).gas(msg.gas);
                        if (bool(v117)) {
                            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                            require(MEM[MEM[64]] == address(MEM[MEM[64]]));
                            v118 = address(MEM[MEM[64]]).synthBySynth(address(v99.word0)).gas(msg.gas);
                            if (bool(v118)) {
                                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                                v115 = MEM[MEM[64]];
                                require(v115 == address(v115));
                                if (!address(v115)) {
                                    v115 = v119 = v99.word0;
                                } else {
                                    if (address(v99.word2) != address(MEM[MEM[64]])) {
                                        MEM[MEM[64] + 36] = address(v99.word2);
                                        MEM[MEM[64] + 68] = address(MEM[MEM[64]]);
                                        MEM[MEM[64] + 100] = v99.word1;
                                        MEM[MEM[64] + 32] = bytes4(0x23b872dd00000000000000000000000000000000000000000000000000000000) | uint224(MEM[MEM[64] + 32]);
                                        v120 = v121 = 0;
                                        while (v120 < 132 + MEM[64] - MEM[64] - 32) {
                                            MEM[v120 + MEM[64]] = MEM[v120 + (MEM[64] + 32)];
                                            v120 += 32;
                                        }
                                        MEM[132 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
                                        v122 = address(v99.word0).call(MEM[MEM[64]:MEM[64] + 132 + MEM[64] - MEM[64] - 32 + MEM[64] - MEM[64]], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                                        if (RETURNDATASIZE() == 0) {
                                            v123 = v124 = 96;
                                        } else {
                                            v123 = v125 = MEM[64];
                                            MEM[64] = v125 + (RETURNDATASIZE() + 63 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                                            MEM[v125] = RETURNDATASIZE();
                                            RETURNDATACOPY(v125 + 32, 0, RETURNDATASIZE());
                                        }
                                        if (!v122) {
                                            require(!MEM[v123], 32 + v123, MEM[v123]);
                                            v126 = new bytes[](v127.length);
                                            v128 = v129 = 0;
                                            while (v128 < v127.length) {
                                                v126[v128] = v127[v128];
                                                v128 += 32;
                                            }
                                            v126[v127.length][32] = 0;
                                            revert(Error(v126, v82, 'SafeERC20: low-level call failed'));
                                        } else {
                                            if (!(0 - MEM[v123])) {
                                                require((address(v99.word0)).code.size, Error('Address: call to non-contract'));
                                            }
                                            v130 = v131 = 0 == MEM[v123];
                                            if (0 != MEM[v123]) {
                                                require(32 + v123 + MEM[v123] - (32 + v123) >= 32);
                                                v130 = MEM[32 + v123];
                                                require(v130 == bool(v130));
                                            }
                                            require(v130, Error('SafeERC20: ERC20 operation did not succeed'));
                                        }
                                    }
                                    v99.word2 = address(MEM[MEM[64]]);
                                }
                                MEM[MEM[64]] = 0xb6ff156a00000000000000000000000000000000000000000000000000000000;
                                MEM[4 + MEM[64]] = address(v99.word0);
                                MEM[4 + MEM[64] + 32] = v99.word1;
                                MEM[4 + MEM[64] + 64] = address(v99.word2);
                                MEM[4 + MEM[64] + 96] = address(v99.word3);
                                MEM[4 + MEM[64] + 128] = uint64(v99.word4);
                                require(bool((address(MEM[MEM[64]])).code.size));
                                v132 = address(MEM[MEM[64]]).call(MEM[MEM[64]:MEM[64] + 164], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                                if (!bool(v132)) {
                                    RETURNDATACOPY(0, 0, RETURNDATASIZE());
                                    revert(0, RETURNDATASIZE());
                                }
                            } else {
                                RETURNDATACOPY(0, 0, RETURNDATASIZE());
                                revert(0, RETURNDATASIZE());
                            }
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    } else {
                        @_lock_6169(v99);
                    }
                    v13 = v133 = v99.word4;
                    MEM[32 + MEM[64]] = 0x4c4d000000000000000000000000000000000000000000000000000000000000;
                    if (keccak256(MEM[32 + MEM[64]:32 + MEM[64] + 2]) == keccak256(v20.data)) {
                        v99.word5 = uint64(CHAINID());
                    } else {
                        v134 = address(v115).originalToken().gas(msg.gas);
                        if (bool(v134)) {
                            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                            require(MEM[MEM[64]] == address(MEM[MEM[64]]));
                            v99.word0 = address(MEM[MEM[64]]);
                            v135 = address(v115).chainIdFrom().gas(msg.gas);
                            if (bool(v135)) {
                                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                                require(MEM[MEM[64]] == uint64(MEM[MEM[64]]));
                                v99.word5 = uint64(MEM[MEM[64]]);
                            } else {
                                RETURNDATACOPY(0, 0, RETURNDATASIZE());
                                revert(0, RETURNDATASIZE());
                            }
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    }
                    MEM[32 + MEM[64]] = address(v99.word0);
                    MEM[32 + MEM[64] + 32] = v99.word1;
                    MEM[32 + MEM[64] + 64] = address(v99.word2);
                    MEM[32 + MEM[64] + 96] = address(v99.word3);
                    MEM[32 + MEM[64] + 128] = uint64(v99.word4);
                    MEM[32 + MEM[64] + 160] = uint64(v99.word5);
                    MEM[32 + MEM[64] + 192] = address(v99.word6);
                    v26 = MEM[64];
                    MEM[v26] = 224;
                }
            }
        } else {
            require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= 224);
            v136 = allocate_memory_7374();
            require(MEM[32 + v2[v11]] == address(MEM[32 + v2[v11]]));
            v136.word0 = MEM[32 + v2[v11]];
            require(MEM[32 + v2[v11] + 32] == address(MEM[32 + v2[v11] + 32]));
            v136.word1 = MEM[32 + v2[v11] + 32];
            v136.word2 = MEM[32 + v2[v11] + 64];
            v136.word3 = MEM[32 + v2[v11] + 96];
            require(MEM[32 + v2[v11] + 128] == uint8(MEM[32 + v2[v11] + 128]));
            v136.word4 = MEM[32 + v2[v11] + 128];
            v136.word5 = MEM[192 + v2[v11]];
            v136.word6 = MEM[224 + v2[v11]];
            require(bool((address(v136.word0)).code.size));
            v137 = address(v136.word0).permit(address(v136.word1), this, v136.word2, v136.word3, uint8(v136.word4), v136.word5, v136.word6).gas(msg.gas);
            if (!bool(v137)) {
                RETURNDATACOPY(0, 0, RETURNDATASIZE());
                revert(0, RETURNDATASIZE());
            }
        }
        require(v138 <= 2, Panic(33)); // failed convertion to enum type
        if (!(v138 - 0)) {
            v11 = v139 = 1;
            if (keccak256(65) - keccak256(v20.data)) {
                if (keccak256(0x5200000000000000000000000000000000000000000000000000000000000000) - keccak256(v20.data)) {
                    if (keccak256(83) - keccak256(v20.data)) {
                        v11 = v140 = 0;
                    } else {
                        require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= 288);
                        v141 = new struct(9);
                        require(!((v141 + 288 < v141) | (v141 + 288 > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
                        require(MEM[32 + v2[v11]] == address(MEM[32 + v2[v11]]));
                        v141.word0 = MEM[32 + v2[v11]];
                        v141.word1 = MEM[32 + v2[v11] + 32];
                        require(MEM[32 + v2[v11] + 64] == address(MEM[32 + v2[v11] + 64]));
                        v141.word2 = MEM[32 + v2[v11] + 64];
                        require(MEM[32 + v2[v11] + 96] == address(MEM[32 + v2[v11] + 96]));
                        v141.word3 = MEM[32 + v2[v11] + 96];
                        require(MEM[32 + v2[v11] + 128] == address(MEM[32 + v2[v11] + 128]));
                        v141.word4 = MEM[32 + v2[v11] + 128];
                        v141.word5 = MEM[32 + v2[v11] + 160];
                        require(MEM[32 + v2[v11] + 192] == uint8(MEM[32 + v2[v11] + 192]));
                        v141.word6 = MEM[32 + v2[v11] + 192];
                        require(MEM[32 + v2[v11] + 224] == uint8(MEM[32 + v2[v11] + 224]));
                        v141.word7 = MEM[32 + v2[v11] + 224];
                        require(MEM[32 + v2[v11] + (uint8.max + 1)] == address(MEM[32 + v2[v11] + (uint8.max + 1)]));
                        v141.word8 = MEM[32 + v2[v11] + (uint8.max + 1)];
                        v142 = @_getPoolAdapter_7289(v141.word4);
                        v143 = v144 = v141.word1;
                        v145 = v146 = v141.word2;
                        v147 = v148 = v141.word8;
                        if (v144 == uint256.max) {
                            v143 = v149 = MEM[v16];
                        }
                        if (!address(v146)) {
                            v145 = v150 = MEM[32 + v16];
                        } else {
                            require(msg.sender == address(v146), Error('Router: wrong sender'));
                        }
                        v151 = v152 = !stor_a;
                        if (!bool(stor_a)) {
                            v151 = bool(address(v148));
                        }
                        if (!v151) {
                            v147 = MEM[v16 + 64];
                        } else {
                            require(msg.sender == address(v148), Error('Router: wrong emergencyTo'));
                        }
                        v141.word8 = address(v147);
                        v141.word2 = address(v145);
                        v141.word1 = v143;
                        v153 = @_checkTo_7265(v22, CHAINID(), address(v147), v141.word3);
                        v141.word3 = address(v153);
                        @_transferToAdapter_7331(v141.word1, v142, v141.word2, v141.word0);
                        v154 = address(v142).swap(address(v141.word0), v141.word1, address(v141.word3), address(v141.word4), v141.word5, uint8(v141.word6), uint8(v141.word7), address(v141.word8)).gas(msg.gas);
                        if (bool(v154)) {
                            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                            MEM[v16] = MEM[MEM[64]];
                            MEM[v16 + 32] = address(v141.word3);
                            MEM[v16 + 64] = address(v141.word8);
                            if (!(0 - MEM[MEM[64]])) {
                                require(!stor_b_8_8, Error('UnifiedRouterV2: slippage'));
                            }
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    }
                } else {
                    require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= uint8.max + 1);
                    require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= uint8.max + 1);
                    v155 = new struct(8);
                    require(!((v155 + (uint8.max + 1) < v155) | (v155 + (uint8.max + 1) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
                    require(MEM[32 + v2[v11]] == address(MEM[32 + v2[v11]]));
                    v155.word0 = MEM[32 + v2[v11]];
                    v155.word1 = MEM[32 + v2[v11] + 32];
                    require(MEM[32 + v2[v11] + 64] == address(MEM[32 + v2[v11] + 64]));
                    v155.word2 = MEM[32 + v2[v11] + 64];
                    require(MEM[32 + v2[v11] + 96] == address(MEM[32 + v2[v11] + 96]));
                    v155.word3 = MEM[32 + v2[v11] + 96];
                    require(MEM[32 + v2[v11] + 128] == address(MEM[32 + v2[v11] + 128]));
                    v155.word4 = MEM[32 + v2[v11] + 128];
                    v155.word5 = MEM[32 + v2[v11] + 160];
                    require(MEM[32 + v2[v11] + 192] == uint8(MEM[32 + v2[v11] + 192]));
                    v155.word6 = MEM[32 + v2[v11] + 192];
                    require(MEM[32 + v2[v11] + 224] == address(MEM[32 + v2[v11] + 224]));
                    v155.word7 = MEM[32 + v2[v11] + 224];
                    v156 = @_getPoolAdapter_7289(v155.word4);
                    v157 = v158 = v155.word1;
                    v159 = v160 = v155.word2;
                    v161 = v162 = v155.word7;
                    if (v158 == uint256.max) {
                        v157 = v163 = MEM[v16];
                    }
                    if (!address(v160)) {
                        v159 = v164 = MEM[32 + v16];
                    } else {
                        require(msg.sender == address(v160), Error('Router: wrong sender'));
                    }
                    v165 = v166 = !stor_a;
                    if (!bool(stor_a)) {
                        v165 = bool(address(v162));
                    }
                    if (!v165) {
                        v161 = MEM[v16 + 64];
                    } else {
                        require(msg.sender == address(v162), Error('Router: wrong emergencyTo'));
                    }
                    v155.word7 = address(v161);
                    v155.word2 = address(v159);
                    v155.word1 = v157;
                    v167 = @_checkTo_7265(v22, CHAINID(), address(v161), v155.word3);
                    v155.word3 = address(v167);
                    @_transferToAdapter_7331(v155.word1, v156, v155.word2, v155.word0);
                    v168 = address(v156);
                    MEM[MEM[64]] = 0xcd7bfd5800000000000000000000000000000000000000000000000000000000;
                    MEM[4 + MEM[64]] = address(v155.word0);
                    MEM[4 + MEM[64] + 32] = v155.word1;
                    MEM[4 + MEM[64] + 64] = address(v155.word3);
                    MEM[4 + MEM[64] + 96] = address(v155.word4);
                    MEM[4 + MEM[64] + 128] = v155.word5;
                    MEM[4 + MEM[64] + 160] = uint8(v155.word6);
                    MEM[4 + MEM[64] + 192] = address(v155.word7);
                    v169 = 228 + MEM[64];
                }
            } else {
                require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= uint8.max + 1);
                require(32 + v2[v11] + MEM[v2[v11]] - (32 + v2[v11]) >= uint8.max + 1);
                v155 = v170 = new struct(8);
                require(!((v170 + (uint8.max + 1) < v170) | (v170 + (uint8.max + 1) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
                require(MEM[32 + v2[v11]] == address(MEM[32 + v2[v11]]));
                v170.word0 = MEM[32 + v2[v11]];
                v170.word1 = MEM[32 + v2[v11] + 32];
                require(MEM[32 + v2[v11] + 64] == address(MEM[32 + v2[v11] + 64]));
                v170.word2 = MEM[32 + v2[v11] + 64];
                require(MEM[32 + v2[v11] + 96] == address(MEM[32 + v2[v11] + 96]));
                v170.word3 = MEM[32 + v2[v11] + 96];
                require(MEM[32 + v2[v11] + 128] == address(MEM[32 + v2[v11] + 128]));
                v170.word4 = MEM[32 + v2[v11] + 128];
                v170.word5 = MEM[32 + v2[v11] + 160];
                require(MEM[32 + v2[v11] + 192] == uint8(MEM[32 + v2[v11] + 192]));
                v170.word6 = MEM[32 + v2[v11] + 192];
                require(MEM[32 + v2[v11] + 224] == address(MEM[32 + v2[v11] + 224]));
                v170.word7 = MEM[32 + v2[v11] + 224];
                v171 = @_getPoolAdapter_7289(v170.word4);
                v172 = v173 = v170.word1;
                v174 = v175 = v170.word2;
                v176 = v177 = v170.word7;
                if (v173 == uint256.max) {
                    v172 = v178 = MEM[v16];
                }
                if (!address(v175)) {
                    v174 = v179 = MEM[32 + v16];
                } else {
                    require(msg.sender == address(v175), Error('Router: wrong sender'));
                }
                v180 = v181 = !stor_a;
                if (!bool(stor_a)) {
                    v180 = bool(address(v177));
                }
                if (!v180) {
                    v176 = MEM[v16 + 64];
                } else {
                    require(msg.sender == address(v177), Error('Router: wrong emergencyTo'));
                }
                v170.word7 = address(v176);
                v170.word2 = address(v174);
                v170.word1 = v172;
                v182 = @_checkTo_7265(v22, CHAINID(), address(v176), v170.word3);
                v170.word3 = address(v182);
                @_transferToAdapter_7331(v170.word1, v171, v170.word2, v170.word0);
                v168 = v183 = address(v171);
                MEM[MEM[64]] = 0xdc64ef4500000000000000000000000000000000000000000000000000000000;
                MEM[4 + MEM[64]] = address(v170.word0);
                MEM[4 + MEM[64] + 32] = v170.word1;
                MEM[4 + MEM[64] + 64] = address(v170.word3);
                MEM[4 + MEM[64] + 96] = address(v170.word4);
                MEM[4 + MEM[64] + 128] = v170.word5;
                MEM[4 + MEM[64] + 160] = uint8(v170.word6);
                MEM[4 + MEM[64] + 192] = address(v170.word7);
                v169 = v184 = 228 + MEM[64];
            }
            v185 = v168.call(MEM[MEM[64]:MEM[64] + v570aV0x2632V0x137c - MEM[64]], MEM[MEM[64]:MEM[64] + 32]).gas(msg.gas);
            if (bool(v185)) {
                MEM[64] = MEM[64] + (RETURNDATASIZE() + 31 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                MEM[v16] = MEM[MEM[64]];
                MEM[v16 + 32] = address(MEM[v155 + 96]);
                MEM[v16 + 64] = address(MEM[v155 + 224]);
                if (!(0 - MEM[MEM[64]])) {
                    require(!stor_b_8_8, Error('UnifiedRouterV2: slippage'));
                }
            } else {
                RETURNDATACOPY(0, 0, RETURNDATASIZE());
                revert(0, RETURNDATASIZE());
            }
            v11 = v186 = 2;
        }
        require(v11 <= 2, Panic(33)); // failed convertion to enum type
        require(v11 < operations.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(operations[v11] < msg.data.length - v1 - 31);
        require(msg.data[v1 + operations[v11]] <= uint64.max);
        require(32 + (v1 + operations[v11]) <= msg.data.length - msg.data[v1 + operations[v11]]);
        MEM[32 + MEM[64]] = 'Router: op ';
        CALLDATACOPY(32 + MEM[64] + 11, 32 + (v1 + operations[v11]), msg.data[v1 + operations[v11]]);
        MEM[msg.data[v1 + operations[v11]] + (32 + MEM[64]) + 11] = ' is not supported';
        if (v11 != 0) {
            require(v11 <= 2, Panic(33)); // failed convertion to enum type
            if (v11 == 2) {
                break;
            } else if (!uint64(v187)) {
                require(v11 + 1, Panic(17)); // arithmetic overflow or underflow
                v11 += 1;
            } else {
                v188, /* address */ v189 = _addressBook.router(uint64(v187)).gas(msg.gas);
                require(bool(v188), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                require(v189 == address(v189));
                v13 = v190 = @_getRequestId_5249(v187, v189);
                if (0 != MEM[v26]) {
                    require(v11 < v2.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
                    v2[v11] = v26;
                }
                MEM[36 + MEM[64] + 32] = uint8(v11);
                MEM[36 + MEM[64] + 64] = 128;
                MEM[36 + MEM[64] + 128] = operations.length;
                v191 = v192 = 36 + MEM[64] + 160;
                v193 = v194 = 36 + MEM[64] + (operations.length << 5) + 160;
                v195 = v196 = 0;
                while (v195 < operations.length) {
                    MEM[v191] = v193 - (36 + MEM[64]) - 160;
                    require(msg.data[v0] < msg.data.length - v1 - 31);
                    require(msg.data[v1 + msg.data[v0]] <= uint64.max);
                    require(v1 + msg.data[v0] + 32 <= msg.data.length - msg.data[v1 + msg.data[v0]]);
                    MEM[v193] = msg.data[v1 + msg.data[v0]];
                    CALLDATACOPY(v193 + 32, v1 + msg.data[v0] + 32, msg.data[v1 + msg.data[v0]]);
                    MEM[32 + (msg.data[v1 + msg.data[v0]] + v193)] = 0;
                    v193 = v193 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & msg.data[v1 + msg.data[v0]] + 31) + 32;
                    v191 += 32;
                    v0 += 32;
                    v195 += 1;
                }
                MEM[36 + MEM[64] + 96] = v193 - (36 + MEM[64]);
                MEM[v193] = v2.length;
                v197 = v198 = v193 + 32;
                v199 = v200 = v198 + (v2.length << 5);
                v201 = v202 = v2.data;
                v203 = 0;
                while (v203 < v2.length) {
                    MEM[v197] = v199 - v198;
                    MEM[v199] = MEM[MEM[v201]];
                    v204 = v205 = 0;
                    while (v204 < MEM[MEM[v201]]) {
                        MEM[v204 + (v199 + 32)] = MEM[v204 + (MEM[v201] + 32)];
                        v204 += 32;
                    }
                    MEM[MEM[MEM[v201]] + (v199 + 32)] = 0;
                    v199 = 32 + ((0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 31 + MEM[MEM[v201]]) + v199);
                    v197 += 32;
                    v201 += 32;
                    v203 += 1;
                }
                MEM[MEM[64] + 32] = bytes4(0x6b750d6300000000000000000000000000000000000000000000000000000000) | uint224(v190);
                v206, /* address */ v207 = _addressBook.gateKeeper().gas(msg.gas);
                require(bool(v206), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                require(v207 == address(v207));
                v208 = new uint256[](v199 - MEM[64] - 32);
                v209 = v210 = 0;
                while (v209 < v199 - MEM[64] - 32) {
                    MEM[v209 + v208.data] = MEM[v209 + (MEM[64] + 32)];
                    v209 += 32;
                }
                MEM[v199 - MEM[64] - 32 + v208.data] = 0;
                require(bool((address(v207)).code.size));
                v211 = address(v207).sendData(v208, address(v189), uint64(v187), address(0x0)).gas(msg.gas);
                require(bool(v211), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
                require(v11 < v2.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
                require(MEM[v2[v11]] <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
                v212 = v213 = _startedOps[v190].length >> 1;
                if (!(_startedOps[v190].length & 0x1)) {
                    v212 = v214 = v213 & 0x7f;
                }
                require((_startedOps[v190].length & 0x1) - (v212 < 32), Panic(34)); // access to incorrectly encoded storage byte array
                if (v212 > 31) {
                    v215 = v216 = _startedOps[v190].data;
                    v215 = v217 = v216 + (MEM[v2[v11]] + 31 >> 5);
                    if (MEM[v2[v11]] < 32) {
                    }
                    while (v215 < v216 + (v212 + 31 >> 5)) {
                        STORAGE[v215] = 0;
                        v215 += 1;
                    }
                }
                v218 = v219 = 32;
                if (MEM[v2[v11]] > 31 == 1) {
                    v220 = v221 = 0;
                    v222 = v223 = _startedOps[v190].data;
                    while (v220 < MEM[v2[v11]] & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0) {
                        STORAGE[v222] = MEM[v218 + v2[v11]];
                        v218 += v219;
                        v222 = v222 + 1;
                        v220 += v219;
                    }
                    if (MEM[v2[v11]] & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 < MEM[v2[v11]]) {
                        STORAGE[v222] = ~(uint256.max >> (0xf8 & MEM[v2[v11]] << 3)) & MEM[v218 + v2[v11]];
                    }
                    _startedOps[v190].length = (MEM[v2[v11]] << 1) + 1;
                } else if (!MEM[v2[v11]]) {
                    _startedOps[v190].length = MEM[v2[v11]] << 1 | ~(uint256.max >> (MEM[v2[v11]] << 3)) & 0x0;
                } else {
                    _startedOps[v190].length = MEM[v2[v11]] << 1 | ~(uint256.max >> (MEM[v2[v11]] << 3)) & MEM[v219 + v2[v11]];
                }
            }
        } else {
            v224 = new uint256[](28 + (msg.data[v1 + operations[v11]] + (32 + MEM[64])) - MEM[64] - 32);
            v225 = v226 = 0;
            while (v225 < 28 + (msg.data[v1 + operations[v11]] + (32 + MEM[64])) - MEM[64] - 32) {
                MEM[v225 + v224.data] = MEM[v225 + (MEM[64] + 32)];
                v225 += 32;
            }
            MEM[28 + (msg.data[v1 + operations[v11]] + (32 + MEM[64])) - MEM[64] - 32 + v224.data] = 0;
            revert(Error(v224));
        }
    }
    require(v11 < 3, Panic(33)); // failed convertion to enum type
    emit ComplexOpProcessed(uint64(CHAINID()), requestId, uint64(v13), v13, v11, uint8(v11));
    _@_nonReentrantBefore_716 = 1;
    stor_a = 0;
    _@_emergencyUnlock_6253 = 0;
}

function BURN_UNLOCK_CODE() public nonPayable {
    return keccak256(16981);
}

function UNWRAP_CODE() public nonPayable {
    return keccak256(21879);
}

function allocate_memory_7374() private {
    v0 = new struct(7);
    require(!((v0 + 224 < v0) | (v0 + 224 > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    return v0;
}

function nonces(address varg0) public nonPayable {
    require(msg.data.length - 4 >= 32);
    return _nonces[varg0];
}

function pause() public nonPayable {
    @_checkRole_92(0);
    @_pause_654();
}

function eip712Domain() public nonPayable {
    if (0x4559574100000000000000000000000000000000000000000000000000000004 == uint8.max) {
        v0 = v1 = _eip712Domain.length >> 1;
        if (!(_eip712Domain.length & 0x1)) {
            v0 = v2 = v1 & 0x7f;
        }
        require((_eip712Domain.length & 0x1) - (v0 < 32), Panic(34)); // access to incorrectly encoded storage byte array
        v3 = v4 = new bytes[](v0);
        v5 = v6 = v4.data;
        v7 = v8 = _eip712Domain.length >> 1;
        if (!(_eip712Domain.length & 0x1)) {
            v7 = v9 = v8 & 0x7f;
        }
        require((_eip712Domain.length & 0x1) - (v7 < 32), Panic(34)); // access to incorrectly encoded storage byte array
        if (v7) {
            if (31 < v7) {
                v10 = v11 = _eip712Domain.data;
                while (v6 + v7 > v5) {
                    MEM[v5] = STORAGE[v10];
                    v10 += 1;
                    v5 += 32;
                }
            } else {
                MEM[v6] = _eip712Domain.length >> 8 << 8;
            }
        }
    } else {
        require(uint8(0x4559574100000000000000000000000000000000000000000000000000000004) <= 31, InvalidShortString());
        v3 = v12 = 0x45595741;
        CALLDATACOPY(v12.data, msg.data.length, 32);
    }
    if (0x3100000000000000000000000000000000000000000000000000000000000001 == uint8.max) {
        v13 = v14 = array_2.length >> 1;
        if (!(array_2.length & 0x1)) {
            v13 = v15 = v14 & 0x7f;
        }
        require((array_2.length & 0x1) - (v13 < 32), Panic(34)); // access to incorrectly encoded storage byte array
        v16 = v17 = new bytes[](v13);
        v18 = v19 = v17.data;
        v20 = v21 = array_2.length >> 1;
        if (!(array_2.length & 0x1)) {
            v20 = v22 = v21 & 0x7f;
        }
        require((array_2.length & 0x1) - (v20 < 32), Panic(34)); // access to incorrectly encoded storage byte array
        if (v20) {
            if (31 < v20) {
                v23 = v24 = array_2.data;
                while (v19 + v20 > v18) {
                    MEM[v18] = STORAGE[v23];
                    v23 += 1;
                    v18 += 32;
                }
            } else {
                MEM[v19] = array_2.length >> 8 << 8;
            }
        }
    } else {
        require(uint8(0x3100000000000000000000000000000000000000000000000000000000000001) <= 31, InvalidShortString());
        v16 = v25 = 49;
        CALLDATACOPY(v25.data, msg.data.length, 32);
    }
    v26 = new uint256[](MEM[v3]);
    v27 = v28 = 0;
    while (v27 < MEM[v3]) {
        MEM[v27 + v26.data] = MEM[v27 + (v3 + 32)];
        v27 += 32;
    }
    MEM[MEM[v3] + v26.data] = 0;
    v29 = new uint256[](MEM[v16]);
    v30 = v31 = 0;
    while (v30 < MEM[v16]) {
        MEM[v30 + v29.data] = MEM[v30 + (v16 + 32)];
        v30 += 32;
    }
    MEM[MEM[v16] + v29.data] = 0;
    v32 = new uint256[](0);
    v33 = v34 = MEM[64] + 32;
    v35 = v36 = v32.data;
    v37 = v38 = 0;
    while (v37 < 0) {
        MEM[v35] = MEM[v33];
        v33 += 32;
        v35 += 32;
        v37 += 1;
    }
    return bytes1(0xf00000000000000000000000000000000000000000000000000000000000000), v26, v29, CHAINID(), address(this), 0, v32;
}

function getRoleMember(bytes32 role, uint256 index) public nonPayable {
    require(msg.data.length - 4 >= 64);
    require(index < _getRoleMemberCount[role].length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
    return address(_getRoleMemberCount[role].field0[index]);
}

function _SafeSub(uint256 varg0, uint256 varg1) private {
    require(varg0 - varg1 <= varg0, Panic(17)); // arithmetic overflow or underflow
    return varg0 - varg1;
}

function hasRole(bytes32 role, address account) public nonPayable {
    require(msg.data.length - 4 >= 64);
    return _getRoleAdmin[role].field0[account];
}

function poolAdapter(address varg0) public nonPayable {
    require(msg.data.length - 4 >= 32);
    return _@_getPoolAdapter_7289[varg0];
}

function ADD_CODE() public nonPayable {
    return keccak256(65);
}

function EMERGENCY_UNLOCK_CODE() public nonPayable {
    return keccak256(8525);
}

function DEFAULT_ADMIN_ROLE() public nonPayable {
    return 0;
}

function startedOps(bytes32 varg0) public nonPayable {
    require(msg.data.length - 4 >= 32);
    v0 = v1 = _startedOps[varg0].length >> 1;
    if (!(_startedOps[varg0].length & 0x1)) {
        v0 = v2 = v1 & 0x7f;
    }
    require((_startedOps[varg0].length & 0x1) - (v0 < 32), Panic(34)); // access to incorrectly encoded storage byte array
    v3 = new bytes[](v0);
    v4 = v5 = v3.data;
    v6 = v7 = _startedOps[varg0].length >> 1;
    if (!(_startedOps[varg0].length & 0x1)) {
        v6 = v8 = v7 & 0x7f;
    }
    require((_startedOps[varg0].length & 0x1) - (v6 < 32), Panic(34)); // access to incorrectly encoded storage byte array
    if (v6) {
        if (31 < v6) {
            v9 = v10 = _startedOps[varg0].data;
            while (v5 + v6 > v4) {
                MEM[v4] = STORAGE[v9];
                v9 += 1;
                v4 += 32;
            }
        } else {
            MEM[v5] = _startedOps[varg0].length >> 8 << 8;
        }
    }
    v11 = new bytes[](v3.length);
    v12 = v13 = 0;
    while (v12 < v3.length) {
        v11[v12] = v3[v12];
        v12 += 32;
    }
    v11[v3.length] = 0;
    return v11;
}

function ACCOUNTANT_ROLE() public nonPayable {
    return 0x369da55721ba2b3acddd63aac7d6512c3e5762a78fa01c44f423f97868330c34;
}

function PERMIT_CODE() public nonPayable {
    return keccak256(0x5000000000000000000000000000000000000000000000000000000000000000);
}

function registerComplexOp((string,bool) complexOps_) public nonPayable {
    require(msg.data.length - 4 >= 32);
    require(complexOps_ <= uint64.max);
    require(4 + complexOps_ + 31 < msg.data.length);
    require(complexOps_.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v0 = new uint256[](complexOps_.length);
    require(!((v0 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (complexOps_.length << 5) + 31) < v0) | (v0 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (complexOps_.length << 5) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    v1 = v2 = v0.data;
    require(32 + (4 + complexOps_ + (complexOps_.length << 5)) <= msg.data.length);
    v3 = v4 = complexOps_.data;
    while (v3 < 32 + (4 + complexOps_ + (complexOps_.length << 5))) {
        require(msg.data[v3] <= uint64.max);
        require(64 <= msg.data.length - (4 + complexOps_ + msg.data[v3]) - 32);
        v5 = new struct(2);
        require(!((v5 + 64 < v5) | (v5 + 64 > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
        require(msg.data[4 + complexOps_ + msg.data[v3] + 32] <= uint64.max);
        require(msg.data.length > 4 + complexOps_ + msg.data[v3] + msg.data[4 + complexOps_ + msg.data[v3] + 32] + 63);
        v6 = msg.data[4 + complexOps_ + msg.data[v3] + msg.data[4 + complexOps_ + msg.data[v3] + 32] + 32];
        require(v6 <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
        v7 = new bytes[](v6);
        require(!((v7 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & v6 + 31) + 31) < v7) | (v7 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & v6 + 31) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
        require(4 + complexOps_ + msg.data[v3] + msg.data[4 + complexOps_ + msg.data[v3] + 32] + 64 + v6 <= msg.data.length);
        CALLDATACOPY(v7.data, 4 + complexOps_ + msg.data[v3] + msg.data[4 + complexOps_ + msg.data[v3] + 32] + 64, v6);
        v7[v6] = 0;
        v5.word0 = v7;
        require(msg.data[64 + (4 + complexOps_ + msg.data[v3])] == bool(msg.data[64 + (4 + complexOps_ + msg.data[v3])]));
        v5.word1 = msg.data[64 + (4 + complexOps_ + msg.data[v3])];
        MEM[v1] = v5;
        v1 += 32;
        v3 += 32;
    }
    @_checkRole_92(0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929);
    v8 = v9 = 0;
    while (v8 < v0.length) {
        require(v8 < v0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        v10 = keccak256(MEM[32 + MEM[v4ab1V0x1004aaV0x641[v5073V0xd4aV0x650]]:32 + MEM[v4ab1V0x1004aaV0x641[v5073V0xd4aV0x650]] + MEM[MEM[v4ab1V0x1004aaV0x641[v5073V0xd4aV0x650]]]]);
        require(v8 < v0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        _ops[v10] = MEM[32 + v0[v8]];
        require(v8 < v0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(v8 < v0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        v11 = new uint256[](MEM[MEM[v0[v8]]]);
        v12 = v13 = 0;
        while (v12 < MEM[MEM[v0[v8]]]) {
            MEM[v12 + v11.data] = MEM[v12 + (MEM[v0[v8]] + 32)];
            v12 += 32;
        }
        MEM[MEM[MEM[v0[v8]]] + v11.data] = 0;
        emit ComplexOpSet(v11, v10, bool(MEM[32 + v0[v8]]));
        require(v8 + 1, Panic(17)); // arithmetic overflow or underflow
        v8 += 1;
    }
    exit;
}

function receiveValidatedData(bytes4 selector, address from, uint64 chainIdFrom) public nonPayable {
    require(msg.data.length - 4 >= 96);
    v0, /* address */ v1 = _addressBook.bridge().gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v1 == address(v1));
    require(msg.sender == address(v1), Error('Router: bridge only'));
    v2, /* address */ v3 = _addressBook.router(chainIdFrom).gas(msg.gas);
    require(bool(v2), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v3 == address(v3));
    require(from == address(v3), Error('Router: wrong sender'));
    require(0x6b750d6300000000000000000000000000000000000000000000000000000000 == selector, Error('Router: wrong selector'));
    _@_emergencyUnlock_6253 = chainIdFrom;
    return True;
}

function start(uint256 varg0, uint256 varg1, uint256 varg2, uint256 varg3, uint8 varg4, uint256 varg5, uint256 varg6) public payable {
    require(msg.data.length - 4 >= 224);
    require(varg0 <= uint64.max);
    require(4 + varg0 + 31 < msg.data.length);
    require(varg0.length <= uint64.max);
    v0 = v1 = varg0.data;
    require(4 + varg0 + (varg0.length << 5) + 32 <= msg.data.length);
    require(varg1 <= uint64.max);
    require(4 + varg1 + 31 < msg.data.length);
    require(varg1.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v2 = new uint256[](varg1.length);
    require(!((v2 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (varg1.length << 5) + 31) < v2) | (v2 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (varg1.length << 5) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    v3 = v4 = v2.data;
    require(32 + (4 + varg1 + (varg1.length << 5)) <= msg.data.length);
    v5 = v6 = varg1.data;
    while (v5 < 32 + (4 + varg1 + (varg1.length << 5))) {
        require(msg.data[v5] <= uint64.max);
        require(msg.data.length > 4 + varg1 + msg.data[v5] + 63);
        require(msg.data[4 + varg1 + msg.data[v5] + 32] <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
        v7 = new bytes[](msg.data[4 + varg1 + msg.data[v5] + 32]);
        require(!((v7 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & msg.data[4 + varg1 + msg.data[v5] + 32] + 31) + 31) < v7) | (v7 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & msg.data[4 + varg1 + msg.data[v5] + 32] + 31) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
        require(4 + varg1 + msg.data[v5] + 64 + msg.data[4 + varg1 + msg.data[v5] + 32] <= msg.data.length);
        CALLDATACOPY(v7.data, 4 + varg1 + msg.data[v5] + 64, msg.data[4 + varg1 + msg.data[v5] + 32]);
        v7[msg.data[4 + varg1 + msg.data[v5] + 32]] = 0;
        MEM[v3] = v7;
        v3 += 32;
        v5 += 32;
    }
    require(msg.data.length - 4 - 64 >= 160);
    stor_b_8_8 = 1;
    @_nonReentrantBefore_716();
    require(varg0.length < uint8.max + 1, Error('BaseRouter: wrong params count'));
    require(varg0.length == v2.length, Error('BaseRouter: wrong params'));
    v8 = v9 = 96;
    v10 = v11 = 0;
    while (v10 < varg0.length) {
        require(v10 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(varg0[v10] < msg.data.length - v1 - 31);
        require(msg.data[v1 + varg0[v10]] <= uint64.max);
        require(32 + (v1 + varg0[v10]) <= msg.data.length - msg.data[v1 + varg0[v10]]);
        v12 = v13 = 0;
        while (v12 < MEM[v8]) {
            MEM[v12 + (32 + MEM[64])] = MEM[v12 + (v8 + 32)];
            v12 += 32;
        }
        MEM[MEM[v8] + (32 + MEM[64])] = 0;
        CALLDATACOPY(32 + MEM[64] + MEM[v8], 32 + (v1 + varg0[v10]), msg.data[v1 + varg0[v10]]);
        MEM[msg.data[v1 + varg0[v10]] + (32 + MEM[64] + MEM[v8])] = 0;
        v8 = v14 = MEM[64];
        MEM[v14] = msg.data[v1 + varg0[v10]] + (32 + MEM[64] + MEM[v8]) - v14 - 32;
        require(v10 < v2.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        v15 = v16 = 0;
        while (v15 < MEM[v8]) {
            MEM[v15 + (32 + MEM[64])] = MEM[v15 + (v8 + 32)];
            v15 += 32;
        }
        MEM[MEM[v8] + (32 + MEM[64])] = 0;
        v17 = v18 = 0;
        while (v17 < MEM[v2[v10]]) {
            MEM[v17 + (32 + MEM[64] + MEM[v8])] = MEM[v17 + (v2[v10] + 32)];
            v17 += 32;
        }
        MEM[MEM[v2[v10]] + (32 + MEM[64] + MEM[v8])] = 0;
        v8 = v19 = MEM[64];
        MEM[v19] = MEM[v2[v10]] + (32 + MEM[64] + MEM[v8]) - v19 - 32;
        MEM[64] = MEM[v2[v10]] + (32 + MEM[64] + MEM[v8]);
        require(v10 + 1, Panic(17)); // arithmetic overflow or underflow
        v10 += 1;
    }
    require(1 == _ops[keccak256(MEM[v54fe_0x2 + 32:v54fe_0x2 + 32 + MEM[v54fe_0x2]])], Error('BaseRouter: complex op not registered'));
    _nonces[msg.sender] = _nonces[msg.sender] + 1;
    v20 = new uint256[](180 + (v20.data + MEM[v8]) - MEM[64] - 32);
    MEM[v20.data] = 0xf6ee28a1d07a7f08b92989953ec3452189f9f998ef0cb91641587f4f9a76c83b;
    MEM[v20.data + 32] = bytes20(msg.sender << 96);
    MEM[v20.data + 52] = _nonces[msg.sender];
    MEM[v20.data + 84] = keccak256(MEM[v54fe_0x2 + 32:v54fe_0x2 + 32 + MEM[v54fe_0x2]]);
    v21 = v22 = 0;
    while (v21 < MEM[v8]) {
        MEM[v21 + (v20.data + 116)] = MEM[v21 + (v8 + 32)];
        v21 += 32;
    }
    MEM[MEM[v8] + (v20.data + 116)] = 0;
    MEM[v20.data + MEM[v8] + 116] = varg2;
    MEM[v20.data + MEM[v8] + 148] = varg3;
    MEM[64] = 180 + (v20.data + MEM[v8]);
    v23 = v20.length;
    v24 = v20.data;
    v25 = v26 = address(0xfa43de785dd3cd0ef3dae0dd2b8be3f1b5112d1a) == this;
    if (v26) {
        v25 = CHAINID() == 1;
    }
    if (!v25) {
        v27 = v28 = keccak256(0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f, 0xc2a59fd4499513f5d074d325c5dcf8b1f005e4fbb0493c56f92b05b38e5d3b25, 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6, CHAINID(), this);
    } else {
        v27 = 0x476ecb348ce304be36817caea16087c60ffbfd0f3b88df415312cf22338184f7;
    }
    require(32 >= 32);
    if (varg6 <= 0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0) {
        MEM[MEM[64]] = 0;
        v29 = ecrecover(keccak256('\x19Ethereum Signed Message:\n32', keccak256(6401, v27, keccak256(v20))), varg4, varg5, varg6);
        require(bool(v29), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
        v30 = v31 = MEM[MEM[64] - 32];
        if (address(v31)) {
            v32 = v33 = 0;
        } else {
            v30 = v34 = 0;
            v32 = v35 = 1;
        }
    } else {
        v30 = 0;
        v32 = 3;
    }
    require(v32 <= 4, Panic(33)); // failed convertion to enum type
    if (v32 - 0) {
        require(v32 <= 4, Panic(33)); // failed convertion to enum type
        require(v32 - 1, Error('ECDSA: invalid signature'));
        require(v32 <= 4, Panic(33)); // failed convertion to enum type
        require(v32 - 2, Error('ECDSA: invalid signature length'));
        require(v32 <= 4, Panic(33)); // failed convertion to enum type
        require(v32 - 3, Error("ECDSA: invalid signature 's' value"));
    }
    require(block.timestamp <= varg3, Error('BaseRouter: deadline'));
    require(_getRoleAdmin[0x369da55721ba2b3acddd63aac7d6512c3e5762a78fa01c44f423f97868330c34].field0[address(v30)], Error('BaseRouter: invalid signature from worker'));
    require(msg.value >= varg2, Error('Router: invalid amount'));
    v36, /* uint256 */ v37 = address(v30).call().value(varg2).gas(msg.gas);
    if (RETURNDATASIZE() != 0) {
        v38 = new bytes[](RETURNDATASIZE());
        v37 = v38.data;
        RETURNDATACOPY(v37, 0, RETURNDATASIZE());
    }
    require(v36, Error('Router: failed to send Ether'));
    emit FeePaid(msg.sender, address(v30), varg2);
    v39 = v40 = 0;
    v41 = v42 = 0;
    v39 = v43 = 0;
    require(!_paused, Error('Pausable: paused'));
    v44 = v45 = MEM[64];
    MEM[64] = v45 + 96;
    MEM[v45] = 0;
    MEM[v45 + 32] = 0;
    MEM[v45 + 64] = 0;
    while (v39 < varg0.length) {
        v46 = v47 = bool(stor_a);
        if (stor_a) {
            v46 = v39 == v40;
        }
        require(v39 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(varg0[v39] < msg.data.length - v1 - 31);
        require(msg.data[v1 + varg0[v39]] <= uint64.max);
        require(32 + (v1 + varg0[v39]) <= msg.data.length - msg.data[v1 + varg0[v39]]);
        CALLDATACOPY(v48.data, 32 + (v1 + varg0[v39]), msg.data[v1 + varg0[v39]]);
        MEM[msg.data[v1 + varg0[v39]] + v48.data] = 0;
        v49 = _SafeSub(varg0.length, 1);
        if (v39 < v49) {
            require(1 <= v39 + 1, Panic(17)); // arithmetic overflow or underflow
            require(v39 + 1 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            require(varg0[v39 + 1] < msg.data.length - v1 - 31);
            require(msg.data[v1 + varg0[v39 + 1]] <= uint64.max);
            require(32 + (v1 + varg0[v39 + 1]) <= msg.data.length - msg.data[v1 + varg0[v39 + 1]]);
            CALLDATACOPY(MEM[64], 32 + (v1 + varg0[v39 + 1]), msg.data[v1 + varg0[v39 + 1]]);
            MEM[msg.data[v1 + varg0[v39 + 1]] + MEM[64]] = 0;
            v50 = v51 = keccak256(v52.data);
        } else {
            v50 = v53 = 0;
        }
        require(v39 < v2.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        MEM[MEM[64]] = 0;
        MEM[MEM[64] + 32] = 0;
        MEM[MEM[64] + 64] = 0;
        v44 = new struct(3);
        v54 = v55 = 96;
        v41 = v56 = 0;
        v44.word0 = v56;
        v44.word1 = v56;
        v44.word2 = v56;
        v39 = v57 = 1;
        if (keccak256(0x5000000000000000000000000000000000000000000000000000000000000000) - keccak256(v48.data)) {
            v58 = v59 = keccak256(19533) == keccak256(v48.data);
            if (keccak256(19533) != keccak256(v48.data)) {
                v58 = v60 = keccak256(16981) == keccak256(v48.data);
            }
            if (!v58) {
                v58 = keccak256(16973) == keccak256(v48.data);
            }
            if (!v58) {
                v61 = v62 = keccak256(87) == keccak256(v48.data);
                if (keccak256(87) != keccak256(v48.data)) {
                    v61 = keccak256(21879) == keccak256(v48.data);
                }
                if (!v61) {
                    v63 = v64 = keccak256(8525) == keccak256(v48.data);
                    if (keccak256(8525) != keccak256(v48.data)) {
                        v63 = keccak256(8533) == keccak256(v48.data);
                    }
                    if (!v63) {
                        v39 = v65 = 0;
                    } else {
                        require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= 64);
                        v66 = new struct(2);
                        require(!((v66 + 64 > uint64.max) | (v66 + 64 < v66)), Panic(65)); // failed memory allocation (too much memory)
                        v66.word0 = MEM[32 + v2[v39]];
                        require(MEM[32 + v2[v39] + 32] == uint64(MEM[32 + v2[v39] + 32]));
                        v66.word1 = MEM[32 + v2[v39] + 32];
                        if (0 - bool(v46)) {
                            v67 = v68 = _startedOps[v66.word0].length >> 1;
                            if (!(_startedOps[v66.word0].length & 0x1)) {
                                v67 = v69 = v68 & 0x7f;
                            }
                            require((_startedOps[v66.word0].length & 0x1) - (v67 < 32), Panic(34)); // access to incorrectly encoded storage byte array
                            v70 = new bytes[](v67);
                            v71 = v72 = v70.data;
                            v73 = v74 = _startedOps[v66.word0].length >> 1;
                            if (!(_startedOps[v66.word0].length & 0x1)) {
                                v73 = v75 = v74 & 0x7f;
                            }
                            require((_startedOps[v66.word0].length & 0x1) - (v73 < 32), Panic(34)); // access to incorrectly encoded storage byte array
                            if (v73) {
                                if (31 < v73) {
                                    v76 = v77 = _startedOps[v66.word0].data;
                                    while (v72 + v73 > v71) {
                                        MEM[v71] = STORAGE[v76];
                                        v76 += 1;
                                        v71 += 32;
                                    }
                                } else {
                                    MEM[v72] = _startedOps[v66.word0].length >> 8 << 8;
                                }
                            }
                            require(0 - v70.length, Error('Router: op not started'));
                            require(v70.data + v70.length - v70.data >= 224);
                            v78 = allocate_memory_7374();
                            require(MEM[v70.data] == address(MEM[v70.data]));
                            v78.word0 = MEM[v70.data];
                            v78.word1 = v70[32][32];
                            require(v70[64] == address(v70[64]));
                            v78.word2 = v70[64];
                            require(v70[96] == address(v70[96]));
                            v78.word3 = v70[96];
                            require(v70[128] == uint64(v70[128]));
                            v78.word4 = v70[128];
                            require(v70[160] == uint64(v70[160]));
                            v78.word5 = v70[160];
                            require(v70[192] == address(v70[192]));
                            v78.word6 = v70[192];
                            v79 = v80 = _startedOps[v66.word0].length >> 1;
                            if (!(_startedOps[v66.word0].length & 0x1)) {
                                v79 = v81 = v80 & 0x7f;
                            }
                            require((_startedOps[v66.word0].length & 0x1) - (v79 < 32), Panic(34)); // access to incorrectly encoded storage byte array
                            _startedOps[v66.word0].length = 0;
                            if (31 < v79) {
                                v82 = v83 = _startedOps[v66.word0].data;
                                while (v83 + (31 + v79 >> 5) > v82) {
                                    STORAGE[v82] = 0;
                                    v82 += 1;
                                }
                            }
                            if (keccak256(8525) - keccak256(v48.data)) {
                                v84 = @_emergencyMint_6353(v78);
                                v44.word0 = v84;
                            } else {
                                v85 = @_emergencyUnlock_6253(v78);
                                v44.word0 = v85;
                            }
                        } else {
                            require(_processedOps[v66.word0] <= 2, Panic(33)); // failed convertion to enum type
                            require(_processedOps[v66.word0] - 1, Error('Router: op processed'));
                            _processedOps[v66.word0] = 2;
                            v41 = v86 = v66.word1;
                        }
                    }
                } else {
                    require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= 128);
                    v87 = new struct(4);
                    require(!((v87 + 128 > uint64.max) | (v87 + 128 < v87)), Panic(65)); // failed memory allocation (too much memory)
                    require(MEM[32 + v2[v39]] == address(MEM[32 + v2[v39]]));
                    v87.word0 = MEM[32 + v2[v39]];
                    v87.word1 = MEM[64 + v2[v39]];
                    require(MEM[32 + v2[v39] + 64] == address(MEM[32 + v2[v39] + 64]));
                    v87.word2 = MEM[32 + v2[v39] + 64];
                    require(MEM[32 + v2[v39] + 96] == address(MEM[32 + v2[v39] + 96]));
                    v87.word3 = MEM[32 + v2[v39] + 96];
                    v88 = v89 = v87.word1;
                    v90 = v91 = v87.word2;
                    v92 = v93 = 0;
                    if (v89 == uint256.max) {
                        v88 = v94 = MEM[v44];
                    }
                    if (!address(v91)) {
                        v90 = v95 = MEM[32 + v44];
                    } else {
                        require(msg.sender == address(v91), Error('Router: wrong sender'));
                    }
                    v96 = v97 = !stor_a;
                    if (!bool(stor_a)) {
                        v96 = bool(address(v93));
                    }
                    if (v96) {
                        require(msg.sender == address(v93), Error('Router: wrong emergencyTo'));
                    }
                    v87.word2 = address(v90);
                    v87.word1 = v88;
                    v98 = @_checkTo_7265(v50, CHAINID(), v87.word3, v87.word3);
                    v87.word3 = address(v98);
                    if (keccak256(87) == keccak256(v48.data)) {
                        require(msg.value >= v87.word1, Error('Router: invalid amount'));
                        require(bool((address(v87.word0)).code.size));
                        v99 = address(v87.word0).deposit().value(v87.word1).gas(msg.gas);
                        if (bool(v99)) {
                            MEM[MEM[64] + 36] = address(v87.word3);
                            MEM[MEM[64] + 68] = v87.word1;
                            MEM[MEM[64] + 32] = bytes4(0xa9059cbb00000000000000000000000000000000000000000000000000000000) | uint224(MEM[MEM[64] + 32]);
                            v100 = v101 = 0;
                            while (v100 < 100 + MEM[64] - MEM[64] - 32) {
                                MEM[v100 + MEM[64]] = MEM[v100 + (MEM[64] + 32)];
                                v100 += 32;
                            }
                            MEM[100 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
                            v102 = address(v87.word0).call(MEM[MEM[64]:MEM[64] + 100 + MEM[64] - MEM[64] - 32 + MEM[64] - MEM[64]], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                            if (RETURNDATASIZE() == 0) {
                                v103 = v104 = 96;
                            } else {
                                v103 = v105 = MEM[64];
                                MEM[64] = v105 + (RETURNDATASIZE() + 63 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                                MEM[v105] = RETURNDATASIZE();
                                RETURNDATACOPY(v105 + 32, 0, RETURNDATASIZE());
                            }
                            if (!v102) {
                                require(!MEM[v103], 32 + v103, MEM[v103]);
                                v106 = new bytes[](v107.length);
                                v108 = v109 = 0;
                                while (v108 < v107.length) {
                                    v106[v108] = v107[v108];
                                    v108 += 32;
                                }
                                v106[v107.length][32] = 0;
                                revert(Error(v106, v110, 'SafeERC20: low-level call failed'));
                            } else {
                                if (!(0 - MEM[v103])) {
                                    require((address(v87.word0)).code.size, Error('Address: call to non-contract'));
                                }
                                v111 = v112 = 0 == MEM[v103];
                                if (0 != MEM[v103]) {
                                    require(32 + v103 + MEM[v103] - (32 + v103) >= 32);
                                    v111 = MEM[32 + v103];
                                    require(v111 == bool(v111));
                                }
                                require(v111, Error('SafeERC20: ERC20 operation did not succeed'));
                                v44.word0 = v87.word1;
                                v44.word1 = address(v87.word3);
                                v44.word2 = address(MEM[64 + v44]);
                            }
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    } else {
                        if (this != address(v87.word2)) {
                            MEM[MEM[64] + 36] = address(v87.word2);
                            MEM[MEM[64] + 68] = address(this);
                            MEM[MEM[64] + 100] = v87.word1;
                            MEM[MEM[64] + 32] = bytes4(0x23b872dd00000000000000000000000000000000000000000000000000000000) | uint224(MEM[MEM[64] + 32]);
                            v113 = v114 = 0;
                            while (v113 < 132 + MEM[64] - MEM[64] - 32) {
                                MEM[v113 + MEM[64]] = MEM[v113 + (MEM[64] + 32)];
                                v113 += 32;
                            }
                            MEM[132 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
                            v115 = address(v87.word0).call(MEM[MEM[64]:MEM[64] + 132 + MEM[64] - MEM[64] - 32 + MEM[64] - MEM[64]], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                            if (RETURNDATASIZE() == 0) {
                                v116 = v117 = 96;
                            } else {
                                v116 = v118 = MEM[64];
                                MEM[64] = v118 + (RETURNDATASIZE() + 63 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                                MEM[v118] = RETURNDATASIZE();
                                RETURNDATACOPY(v118 + 32, 0, RETURNDATASIZE());
                            }
                            if (!v115) {
                                require(!MEM[v116], 32 + v116, MEM[v116]);
                                v119 = new bytes[](v120.length);
                                v121 = v122 = 0;
                                while (v121 < v120.length) {
                                    v119[v121] = v120[v121];
                                    v121 += 32;
                                }
                                v119[v120.length][32] = 0;
                                revert(Error(v119, v110, 'SafeERC20: low-level call failed'));
                            } else {
                                if (!(0 - MEM[v116])) {
                                    require((address(v87.word0)).code.size, Error('Address: call to non-contract'));
                                }
                                v123 = v124 = 0 == MEM[v116];
                                if (0 != MEM[v116]) {
                                    require(32 + v116 + MEM[v116] - (32 + v116) >= 32);
                                    v123 = MEM[32 + v116];
                                    require(v123 == bool(v123));
                                }
                                require(v123, Error('SafeERC20: ERC20 operation did not succeed'));
                            }
                        }
                        MEM[MEM[64]] = 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000;
                        MEM[4 + MEM[64]] = v87.word1;
                        require(bool((address(v87.word0)).code.size));
                        v125 = address(v87.word0).call(MEM[MEM[64]:MEM[64] + 36], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                        if (bool(v125)) {
                            v126 = address(v87.word3).call().value(v87.word1).gas(msg.gas);
                            if (RETURNDATASIZE() != 0) {
                                MEM[MEM[64]] = RETURNDATASIZE();
                                RETURNDATACOPY(MEM[64] + 32, 0, RETURNDATASIZE());
                            }
                            require(v126, Error('Router: failed to send ETH'));
                            v44.word0 = v87.word1;
                            v44.word1 = address(v87.word3);
                            v44.word2 = address(MEM[64 + v44]);
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    }
                }
            } else {
                require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= 224);
                v127 = allocate_memory_7374();
                require(MEM[32 + v2[v39]] == address(MEM[32 + v2[v39]]));
                v127.word0 = MEM[32 + v2[v39]];
                v127.word1 = MEM[64 + v2[v39]];
                require(MEM[32 + v2[v39] + 64] == address(MEM[32 + v2[v39] + 64]));
                v127.word2 = MEM[32 + v2[v39] + 64];
                require(MEM[32 + v2[v39] + 96] == address(MEM[32 + v2[v39] + 96]));
                v127.word3 = MEM[32 + v2[v39] + 96];
                require(MEM[32 + v2[v39] + 128] == uint64(MEM[32 + v2[v39] + 128]));
                v127.word4 = MEM[32 + v2[v39] + 128];
                require(MEM[32 + v2[v39] + 160] == uint64(MEM[32 + v2[v39] + 160]));
                v127.word5 = MEM[32 + v2[v39] + 160];
                require(MEM[32 + v2[v39] + 192] == address(MEM[32 + v2[v39] + 192]));
                v127.word6 = MEM[32 + v2[v39] + 192];
                if (0 - bool(v46)) {
                    require(_processedOps[stor_a] <= 2, Panic(33)); // failed convertion to enum type
                    require(_processedOps[stor_a] == 0, Error('Router: op processed'));
                    _processedOps[stor_a] = 1;
                    if (!address(v127.word3)) {
                        v128 = @_checkTo_7265(v50, v127.word4, v127.word6, v127.word3);
                        v127.word3 = address(v128);
                    }
                    if (keccak256(16981) == keccak256(v48.data)) {
                        v129 = v130 = @_unlock_6207(v127);
                    } else {
                        v129 = v131 = @_mint_6293(v127);
                    }
                    v44.word0 = v129;
                    v44.word1 = address(v127.word3);
                    v44.word2 = address(v127.word6);
                } else {
                    v132 = v133 = v127.word1;
                    v134 = v135 = v127.word2;
                    v136 = v137 = v127.word6;
                    if (v133 == uint256.max) {
                        v132 = v138 = MEM[v44];
                    }
                    if (!address(v135)) {
                        v134 = v139 = MEM[32 + v44];
                    } else {
                        require(msg.sender == address(v135), Error('Router: wrong sender'));
                    }
                    v140 = v141 = !stor_a;
                    if (!bool(stor_a)) {
                        v140 = bool(address(v137));
                    }
                    if (!v140) {
                        v136 = MEM[v44 + 64];
                    } else {
                        require(msg.sender == address(v137), Error('Router: wrong emergencyTo'));
                    }
                    v127.word6 = address(v136);
                    v127.word2 = address(v134);
                    v127.word1 = v132;
                    v142 = @_checkTo_7265(v50, v127.word4, address(v136), v127.word3);
                    v127.word3 = address(v142);
                    v143 = v144 = 0;
                    if (keccak256(19533) - keccak256(v48.data)) {
                        v145 = _addressBook.synthesis(uint64(CHAINID())).gas(msg.gas);
                        if (bool(v145)) {
                            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                            require(MEM[MEM[64]] == address(MEM[MEM[64]]));
                            v146 = address(MEM[MEM[64]]).synthBySynth(address(v127.word0)).gas(msg.gas);
                            if (bool(v146)) {
                                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                                v143 = MEM[MEM[64]];
                                require(v143 == address(v143));
                                if (!address(v143)) {
                                    v143 = v147 = v127.word0;
                                } else {
                                    if (address(v127.word2) != address(MEM[MEM[64]])) {
                                        MEM[MEM[64] + 36] = address(v127.word2);
                                        MEM[MEM[64] + 68] = address(MEM[MEM[64]]);
                                        MEM[MEM[64] + 100] = v127.word1;
                                        MEM[MEM[64] + 32] = bytes4(0x23b872dd00000000000000000000000000000000000000000000000000000000) | uint224(MEM[MEM[64] + 32]);
                                        v148 = v149 = 0;
                                        while (v148 < 132 + MEM[64] - MEM[64] - 32) {
                                            MEM[v148 + MEM[64]] = MEM[v148 + (MEM[64] + 32)];
                                            v148 += 32;
                                        }
                                        MEM[132 + MEM[64] - MEM[64] - 32 + MEM[64]] = 0;
                                        v150 = address(v127.word0).call(MEM[MEM[64]:MEM[64] + 132 + MEM[64] - MEM[64] - 32 + MEM[64] - MEM[64]], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                                        if (RETURNDATASIZE() == 0) {
                                            v151 = v152 = 96;
                                        } else {
                                            v151 = v153 = MEM[64];
                                            MEM[64] = v153 + (RETURNDATASIZE() + 63 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                                            MEM[v153] = RETURNDATASIZE();
                                            RETURNDATACOPY(v153 + 32, 0, RETURNDATASIZE());
                                        }
                                        if (!v150) {
                                            require(!MEM[v151], 32 + v151, MEM[v151]);
                                            v154 = new bytes[](v155.length);
                                            v156 = v157 = 0;
                                            while (v156 < v155.length) {
                                                v154[v156] = v155[v156];
                                                v156 += 32;
                                            }
                                            v154[v155.length][32] = 0;
                                            revert(Error(v154, v110, 'SafeERC20: low-level call failed'));
                                        } else {
                                            if (!(0 - MEM[v151])) {
                                                require((address(v127.word0)).code.size, Error('Address: call to non-contract'));
                                            }
                                            v158 = v159 = 0 == MEM[v151];
                                            if (0 != MEM[v151]) {
                                                require(32 + v151 + MEM[v151] - (32 + v151) >= 32);
                                                v158 = MEM[32 + v151];
                                                require(v158 == bool(v158));
                                            }
                                            require(v158, Error('SafeERC20: ERC20 operation did not succeed'));
                                        }
                                    }
                                    v127.word2 = address(MEM[MEM[64]]);
                                }
                                MEM[MEM[64]] = 0xb6ff156a00000000000000000000000000000000000000000000000000000000;
                                MEM[4 + MEM[64]] = address(v127.word0);
                                MEM[4 + MEM[64] + 32] = v127.word1;
                                MEM[4 + MEM[64] + 64] = address(v127.word2);
                                MEM[4 + MEM[64] + 96] = address(v127.word3);
                                MEM[4 + MEM[64] + 128] = uint64(v127.word4);
                                require(bool((address(MEM[MEM[64]])).code.size));
                                v160 = address(MEM[MEM[64]]).call(MEM[MEM[64]:MEM[64] + 164], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
                                if (!bool(v160)) {
                                    RETURNDATACOPY(0, 0, RETURNDATASIZE());
                                    revert(0, RETURNDATASIZE());
                                }
                            } else {
                                RETURNDATACOPY(0, 0, RETURNDATASIZE());
                                revert(0, RETURNDATASIZE());
                            }
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    } else {
                        @_lock_6169(v127);
                    }
                    v41 = v161 = v127.word4;
                    MEM[32 + MEM[64]] = 0x4c4d000000000000000000000000000000000000000000000000000000000000;
                    if (keccak256(MEM[32 + MEM[64]:32 + MEM[64] + 2]) == keccak256(v48.data)) {
                        v127.word5 = uint64(CHAINID());
                    } else {
                        v162 = address(v143).originalToken().gas(msg.gas);
                        if (bool(v162)) {
                            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                            require(MEM[MEM[64]] == address(MEM[MEM[64]]));
                            v127.word0 = address(MEM[MEM[64]]);
                            v163 = address(v143).chainIdFrom().gas(msg.gas);
                            if (bool(v163)) {
                                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                                require(MEM[MEM[64]] == uint64(MEM[MEM[64]]));
                                v127.word5 = uint64(MEM[MEM[64]]);
                            } else {
                                RETURNDATACOPY(0, 0, RETURNDATASIZE());
                                revert(0, RETURNDATASIZE());
                            }
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    }
                    MEM[32 + MEM[64]] = address(v127.word0);
                    MEM[32 + MEM[64] + 32] = v127.word1;
                    MEM[32 + MEM[64] + 64] = address(v127.word2);
                    MEM[32 + MEM[64] + 96] = address(v127.word3);
                    MEM[32 + MEM[64] + 128] = uint64(v127.word4);
                    MEM[32 + MEM[64] + 160] = uint64(v127.word5);
                    MEM[32 + MEM[64] + 192] = address(v127.word6);
                    v54 = MEM[64];
                    MEM[v54] = 224;
                }
            }
        } else {
            require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= 224);
            v164 = allocate_memory_7374();
            require(MEM[32 + v2[v39]] == address(MEM[32 + v2[v39]]));
            v164.word0 = MEM[32 + v2[v39]];
            require(MEM[32 + v2[v39] + 32] == address(MEM[32 + v2[v39] + 32]));
            v164.word1 = MEM[32 + v2[v39] + 32];
            v164.word2 = MEM[32 + v2[v39] + 64];
            v164.word3 = MEM[32 + v2[v39] + 96];
            require(MEM[32 + v2[v39] + 128] == uint8(MEM[32 + v2[v39] + 128]));
            v164.word4 = MEM[32 + v2[v39] + 128];
            v164.word5 = MEM[192 + v2[v39]];
            v164.word6 = MEM[224 + v2[v39]];
            require(bool((address(v164.word0)).code.size));
            v165 = address(v164.word0).permit(address(v164.word1), this, v164.word2, v164.word3, uint8(v164.word4), v164.word5, v164.word6).gas(msg.gas);
            if (!bool(v165)) {
                RETURNDATACOPY(0, 0, RETURNDATASIZE());
                revert(0, RETURNDATASIZE());
            }
        }
        require(v166 <= 2, Panic(33)); // failed convertion to enum type
        if (!(v166 - 0)) {
            v39 = v167 = 1;
            if (keccak256(65) - keccak256(v48.data)) {
                if (keccak256(0x5200000000000000000000000000000000000000000000000000000000000000) - keccak256(v48.data)) {
                    if (keccak256(83) - keccak256(v48.data)) {
                        v39 = v168 = 0;
                    } else {
                        require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= 288);
                        v169 = new struct(9);
                        require(!((v169 + 288 < v169) | (v169 + 288 > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
                        require(MEM[32 + v2[v39]] == address(MEM[32 + v2[v39]]));
                        v169.word0 = MEM[32 + v2[v39]];
                        v169.word1 = MEM[32 + v2[v39] + 32];
                        require(MEM[32 + v2[v39] + 64] == address(MEM[32 + v2[v39] + 64]));
                        v169.word2 = MEM[32 + v2[v39] + 64];
                        require(MEM[32 + v2[v39] + 96] == address(MEM[32 + v2[v39] + 96]));
                        v169.word3 = MEM[32 + v2[v39] + 96];
                        require(MEM[32 + v2[v39] + 128] == address(MEM[32 + v2[v39] + 128]));
                        v169.word4 = MEM[32 + v2[v39] + 128];
                        v169.word5 = MEM[32 + v2[v39] + 160];
                        require(MEM[32 + v2[v39] + 192] == uint8(MEM[32 + v2[v39] + 192]));
                        v169.word6 = MEM[32 + v2[v39] + 192];
                        require(MEM[32 + v2[v39] + 224] == uint8(MEM[32 + v2[v39] + 224]));
                        v169.word7 = MEM[32 + v2[v39] + 224];
                        require(MEM[32 + v2[v39] + (uint8.max + 1)] == address(MEM[32 + v2[v39] + (uint8.max + 1)]));
                        v169.word8 = MEM[32 + v2[v39] + (uint8.max + 1)];
                        v170 = @_getPoolAdapter_7289(v169.word4);
                        v171 = v172 = v169.word1;
                        v173 = v174 = v169.word2;
                        v175 = v176 = v169.word8;
                        if (v172 == uint256.max) {
                            v171 = v177 = MEM[v44];
                        }
                        if (!address(v174)) {
                            v173 = v178 = MEM[32 + v44];
                        } else {
                            require(msg.sender == address(v174), Error('Router: wrong sender'));
                        }
                        v179 = v180 = !stor_a;
                        if (!bool(stor_a)) {
                            v179 = bool(address(v176));
                        }
                        if (!v179) {
                            v175 = MEM[v44 + 64];
                        } else {
                            require(msg.sender == address(v176), Error('Router: wrong emergencyTo'));
                        }
                        v169.word8 = address(v175);
                        v169.word2 = address(v173);
                        v169.word1 = v171;
                        v181 = @_checkTo_7265(v50, CHAINID(), address(v175), v169.word3);
                        v169.word3 = address(v181);
                        @_transferToAdapter_7331(v169.word1, v170, v169.word2, v169.word0);
                        v182 = address(v170).swap(address(v169.word0), v169.word1, address(v169.word3), address(v169.word4), v169.word5, uint8(v169.word6), uint8(v169.word7), address(v169.word8)).gas(msg.gas);
                        if (bool(v182)) {
                            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                            MEM[v44] = MEM[MEM[64]];
                            MEM[v44 + 32] = address(v169.word3);
                            MEM[v44 + 64] = address(v169.word8);
                            if (!(0 - MEM[MEM[64]])) {
                                require(!stor_b_8_8, Error('UnifiedRouterV2: slippage'));
                            }
                        } else {
                            RETURNDATACOPY(0, 0, RETURNDATASIZE());
                            revert(0, RETURNDATASIZE());
                        }
                    }
                } else {
                    require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= uint8.max + 1);
                    require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= uint8.max + 1);
                    v183 = new struct(8);
                    require(!((v183 + (uint8.max + 1) < v183) | (v183 + (uint8.max + 1) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
                    require(MEM[32 + v2[v39]] == address(MEM[32 + v2[v39]]));
                    v183.word0 = MEM[32 + v2[v39]];
                    v183.word1 = MEM[32 + v2[v39] + 32];
                    require(MEM[32 + v2[v39] + 64] == address(MEM[32 + v2[v39] + 64]));
                    v183.word2 = MEM[32 + v2[v39] + 64];
                    require(MEM[32 + v2[v39] + 96] == address(MEM[32 + v2[v39] + 96]));
                    v183.word3 = MEM[32 + v2[v39] + 96];
                    require(MEM[32 + v2[v39] + 128] == address(MEM[32 + v2[v39] + 128]));
                    v183.word4 = MEM[32 + v2[v39] + 128];
                    v183.word5 = MEM[32 + v2[v39] + 160];
                    require(MEM[32 + v2[v39] + 192] == uint8(MEM[32 + v2[v39] + 192]));
                    v183.word6 = MEM[32 + v2[v39] + 192];
                    require(MEM[32 + v2[v39] + 224] == address(MEM[32 + v2[v39] + 224]));
                    v183.word7 = MEM[32 + v2[v39] + 224];
                    v184 = @_getPoolAdapter_7289(v183.word4);
                    v185 = v186 = v183.word1;
                    v187 = v188 = v183.word2;
                    v189 = v190 = v183.word7;
                    if (v186 == uint256.max) {
                        v185 = v191 = MEM[v44];
                    }
                    if (!address(v188)) {
                        v187 = v192 = MEM[32 + v44];
                    } else {
                        require(msg.sender == address(v188), Error('Router: wrong sender'));
                    }
                    v193 = v194 = !stor_a;
                    if (!bool(stor_a)) {
                        v193 = bool(address(v190));
                    }
                    if (!v193) {
                        v189 = MEM[v44 + 64];
                    } else {
                        require(msg.sender == address(v190), Error('Router: wrong emergencyTo'));
                    }
                    v183.word7 = address(v189);
                    v183.word2 = address(v187);
                    v183.word1 = v185;
                    v195 = @_checkTo_7265(v50, CHAINID(), address(v189), v183.word3);
                    v183.word3 = address(v195);
                    @_transferToAdapter_7331(v183.word1, v184, v183.word2, v183.word0);
                    v196 = address(v184);
                    MEM[MEM[64]] = 0xcd7bfd5800000000000000000000000000000000000000000000000000000000;
                    MEM[4 + MEM[64]] = address(v183.word0);
                    MEM[4 + MEM[64] + 32] = v183.word1;
                    MEM[4 + MEM[64] + 64] = address(v183.word3);
                    MEM[4 + MEM[64] + 96] = address(v183.word4);
                    MEM[4 + MEM[64] + 128] = v183.word5;
                    MEM[4 + MEM[64] + 160] = uint8(v183.word6);
                    MEM[4 + MEM[64] + 192] = address(v183.word7);
                    v197 = 228 + MEM[64];
                }
            } else {
                require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= uint8.max + 1);
                require(32 + v2[v39] + MEM[v2[v39]] - (32 + v2[v39]) >= uint8.max + 1);
                v183 = v198 = new struct(8);
                require(!((v198 + (uint8.max + 1) < v198) | (v198 + (uint8.max + 1) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
                require(MEM[32 + v2[v39]] == address(MEM[32 + v2[v39]]));
                v198.word0 = MEM[32 + v2[v39]];
                v198.word1 = MEM[32 + v2[v39] + 32];
                require(MEM[32 + v2[v39] + 64] == address(MEM[32 + v2[v39] + 64]));
                v198.word2 = MEM[32 + v2[v39] + 64];
                require(MEM[32 + v2[v39] + 96] == address(MEM[32 + v2[v39] + 96]));
                v198.word3 = MEM[32 + v2[v39] + 96];
                require(MEM[32 + v2[v39] + 128] == address(MEM[32 + v2[v39] + 128]));
                v198.word4 = MEM[32 + v2[v39] + 128];
                v198.word5 = MEM[32 + v2[v39] + 160];
                require(MEM[32 + v2[v39] + 192] == uint8(MEM[32 + v2[v39] + 192]));
                v198.word6 = MEM[32 + v2[v39] + 192];
                require(MEM[32 + v2[v39] + 224] == address(MEM[32 + v2[v39] + 224]));
                v198.word7 = MEM[32 + v2[v39] + 224];
                v199 = @_getPoolAdapter_7289(v198.word4);
                v200 = v201 = v198.word1;
                v202 = v203 = v198.word2;
                v204 = v205 = v198.word7;
                if (v201 == uint256.max) {
                    v200 = v206 = MEM[v44];
                }
                if (!address(v203)) {
                    v202 = v207 = MEM[32 + v44];
                } else {
                    require(msg.sender == address(v203), Error('Router: wrong sender'));
                }
                v208 = v209 = !stor_a;
                if (!bool(stor_a)) {
                    v208 = bool(address(v205));
                }
                if (!v208) {
                    v204 = MEM[v44 + 64];
                } else {
                    require(msg.sender == address(v205), Error('Router: wrong emergencyTo'));
                }
                v198.word7 = address(v204);
                v198.word2 = address(v202);
                v198.word1 = v200;
                v210 = @_checkTo_7265(v50, CHAINID(), address(v204), v198.word3);
                v198.word3 = address(v210);
                @_transferToAdapter_7331(v198.word1, v199, v198.word2, v198.word0);
                v196 = v211 = address(v199);
                MEM[MEM[64]] = 0xdc64ef4500000000000000000000000000000000000000000000000000000000;
                MEM[4 + MEM[64]] = address(v198.word0);
                MEM[4 + MEM[64] + 32] = v198.word1;
                MEM[4 + MEM[64] + 64] = address(v198.word3);
                MEM[4 + MEM[64] + 96] = address(v198.word4);
                MEM[4 + MEM[64] + 128] = v198.word5;
                MEM[4 + MEM[64] + 160] = uint8(v198.word6);
                MEM[4 + MEM[64] + 192] = address(v198.word7);
                v197 = v212 = 228 + MEM[64];
            }
            v213 = v196.call(MEM[MEM[64]:MEM[64] + v570aV0x2632V0x15e2 - MEM[64]], MEM[MEM[64]:MEM[64] + 32]).gas(msg.gas);
            if (bool(v213)) {
                MEM[64] = MEM[64] + (RETURNDATASIZE() + 31 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                MEM[v44] = MEM[MEM[64]];
                MEM[v44 + 32] = address(MEM[v183 + 96]);
                MEM[v44 + 64] = address(MEM[v183 + 224]);
                if (!(0 - MEM[MEM[64]])) {
                    require(!stor_b_8_8, Error('UnifiedRouterV2: slippage'));
                }
            } else {
                RETURNDATACOPY(0, 0, RETURNDATASIZE());
                revert(0, RETURNDATASIZE());
            }
            v39 = v214 = 2;
        }
        require(v39 <= 2, Panic(33)); // failed convertion to enum type
        require(v39 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(varg0[v39] < msg.data.length - v1 - 31);
        require(msg.data[v1 + varg0[v39]] <= uint64.max);
        require(32 + (v1 + varg0[v39]) <= msg.data.length - msg.data[v1 + varg0[v39]]);
        MEM[32 + MEM[64]] = 'Router: op ';
        CALLDATACOPY(32 + MEM[64] + 11, 32 + (v1 + varg0[v39]), msg.data[v1 + varg0[v39]]);
        MEM[msg.data[v1 + varg0[v39]] + (32 + MEM[64]) + 11] = ' is not supported';
        if (v39 != 0) {
            require(v39 <= 2, Panic(33)); // failed convertion to enum type
            if (v39 == 2) {
                break;
            } else if (!uint64(v215)) {
                require(v39 + 1, Panic(17)); // arithmetic overflow or underflow
                v39 += 1;
            } else {
                v216, /* address */ v217 = _addressBook.router(uint64(v215)).gas(msg.gas);
                require(bool(v216), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                require(v217 == address(v217));
                v41 = v218 = @_getRequestId_5249(v215, v217);
                if (0 != MEM[v54]) {
                    require(v39 < v2.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
                    v2[v39] = v54;
                }
                MEM[36 + MEM[64] + 32] = uint8(v39);
                MEM[36 + MEM[64] + 64] = 128;
                MEM[36 + MEM[64] + 128] = varg0.length;
                v219 = v220 = 36 + MEM[64] + 160;
                v221 = v222 = 36 + MEM[64] + (varg0.length << 5) + 160;
                v223 = v224 = 0;
                while (v223 < varg0.length) {
                    MEM[v219] = v221 - (36 + MEM[64]) - 160;
                    require(msg.data[v0] < msg.data.length - v1 - 31);
                    require(msg.data[v1 + msg.data[v0]] <= uint64.max);
                    require(v1 + msg.data[v0] + 32 <= msg.data.length - msg.data[v1 + msg.data[v0]]);
                    MEM[v221] = msg.data[v1 + msg.data[v0]];
                    CALLDATACOPY(v221 + 32, v1 + msg.data[v0] + 32, msg.data[v1 + msg.data[v0]]);
                    MEM[32 + (msg.data[v1 + msg.data[v0]] + v221)] = 0;
                    v221 = v221 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & msg.data[v1 + msg.data[v0]] + 31) + 32;
                    v219 += 32;
                    v0 += 32;
                    v223 += 1;
                }
                MEM[36 + MEM[64] + 96] = v221 - (36 + MEM[64]);
                MEM[v221] = v2.length;
                v225 = v226 = v221 + 32;
                v227 = v228 = v226 + (v2.length << 5);
                v229 = v230 = v2.data;
                v231 = 0;
                while (v231 < v2.length) {
                    MEM[v225] = v227 - v226;
                    MEM[v227] = MEM[MEM[v229]];
                    v232 = v233 = 0;
                    while (v232 < MEM[MEM[v229]]) {
                        MEM[v232 + (v227 + 32)] = MEM[v232 + (MEM[v229] + 32)];
                        v232 += 32;
                    }
                    MEM[MEM[MEM[v229]] + (v227 + 32)] = 0;
                    v227 = 32 + ((0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 31 + MEM[MEM[v229]]) + v227);
                    v225 += 32;
                    v229 += 32;
                    v231 += 1;
                }
                MEM[MEM[64] + 32] = bytes4(0x6b750d6300000000000000000000000000000000000000000000000000000000) | uint224(v218);
                v234, /* address */ v235 = _addressBook.gateKeeper().gas(msg.gas);
                require(bool(v234), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
                require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
                require(v235 == address(v235));
                v236 = new uint256[](v227 - MEM[64] - 32);
                v237 = v238 = 0;
                while (v237 < v227 - MEM[64] - 32) {
                    MEM[v237 + v236.data] = MEM[v237 + (MEM[64] + 32)];
                    v237 += 32;
                }
                MEM[v227 - MEM[64] - 32 + v236.data] = 0;
                require(bool((address(v235)).code.size));
                v239 = address(v235).sendData(v236, address(v217), uint64(v215), address(0x0)).gas(msg.gas);
                require(bool(v239), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
                require(v39 < v2.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
                require(MEM[v2[v39]] <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
                v240 = v241 = _startedOps[v218].length >> 1;
                if (!(_startedOps[v218].length & 0x1)) {
                    v240 = v242 = v241 & 0x7f;
                }
                require((_startedOps[v218].length & 0x1) - (v240 < 32), Panic(34)); // access to incorrectly encoded storage byte array
                if (v240 > 31) {
                    v243 = v244 = _startedOps[v218].data;
                    v243 = v245 = v244 + (MEM[v2[v39]] + 31 >> 5);
                    if (MEM[v2[v39]] < 32) {
                    }
                    while (v243 < v244 + (v240 + 31 >> 5)) {
                        STORAGE[v243] = 0;
                        v243 += 1;
                    }
                }
                v246 = v247 = 32;
                if (MEM[v2[v39]] > 31 == 1) {
                    v248 = v249 = 0;
                    v250 = v251 = _startedOps[v218].data;
                    while (v248 < MEM[v2[v39]] & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0) {
                        STORAGE[v250] = MEM[v246 + v2[v39]];
                        v246 += v247;
                        v250 = v250 + 1;
                        v248 += v247;
                    }
                    if (MEM[v2[v39]] & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 < MEM[v2[v39]]) {
                        STORAGE[v250] = ~(uint256.max >> (0xf8 & MEM[v2[v39]] << 3)) & MEM[v246 + v2[v39]];
                    }
                    _startedOps[v218].length = (MEM[v2[v39]] << 1) + 1;
                } else if (!MEM[v2[v39]]) {
                    _startedOps[v218].length = MEM[v2[v39]] << 1 | ~(uint256.max >> (MEM[v2[v39]] << 3)) & 0x0;
                } else {
                    _startedOps[v218].length = MEM[v2[v39]] << 1 | ~(uint256.max >> (MEM[v2[v39]] << 3)) & MEM[v247 + v2[v39]];
                }
            }
        } else {
            v252 = new uint256[](28 + (msg.data[v1 + varg0[v39]] + (32 + MEM[64])) - MEM[64] - 32);
            v253 = v254 = 0;
            while (v253 < 28 + (msg.data[v1 + varg0[v39]] + (32 + MEM[64])) - MEM[64] - 32) {
                MEM[v253 + v252.data] = MEM[v253 + (MEM[64] + 32)];
                v253 += 32;
            }
            MEM[28 + (msg.data[v1 + varg0[v39]] + (32 + MEM[64])) - MEM[64] - 32 + v252.data] = 0;
            revert(Error(v252));
        }
    }
    require(v39 < 3, Panic(33)); // failed convertion to enum type
    emit ComplexOpProcessed(uint64(CHAINID()), 0, uint64(v41), v41, v39, uint8(v39));
    _@_nonReentrantBefore_716 = 1;
    stor_b_8_8 = 0;
}

function setPoolAdapter(address pool_, address poolAdapter_) public nonPayable {
    require(msg.data.length - 4 >= 64);
    @_checkRole_92(0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929);
    require(pool_, Error('UnifiedRouterV2: zero address'));
    _@_getPoolAdapter_7289[pool_] = poolAdapter_;
}

function SWAP_CODE() public nonPayable {
    return keccak256(83);
}

function getRoleMemberCount(bytes32 role) public nonPayable {
    require(msg.data.length - 4 >= 32);
    return _getRoleMemberCount[role].length;
}

function revokeRole(bytes32 role, address account) public nonPayable {
    require(msg.data.length - 4 >= 64);
    @_checkRole_92(_getRoleAdmin[role].field1);
    @_revokeRole_439(account, role);
}

function addressBook() public nonPayable {
    return _addressBook;
}

function OPERATOR_ROLE() public nonPayable {
    return 0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;
}

function processedOps(bytes32 varg0) public nonPayable {
    require(msg.data.length - 4 >= 32);
    require(_processedOps[varg0] < 3, Panic(33)); // failed convertion to enum type
    return _processedOps[varg0];
}

// Note: The function selector is not present in the original solidity code.
// However, we display it for the sake of completeness.

function __function_selector__( function_selector) public payable {
    MEM[64] = 128;
    if (msg.data.length < 4) {
        require(!msg.data.length);
        receive();
    } else {
        v0 = function_selector >> 224;
        if (0x8456cb59 > v0) {
            if (0x3e7e25c1 > v0) {
                if (0x2b385bcf > v0) {
                    if (0x1ffc9a7 == v0) {
                        supportsInterface(bytes4);
                    } else if (0xb3448a8 == v0) {
                        setAddressBook(address);
                    } else if (0xe03e490 == v0) {
                        castToAddress(bytes32);
                    } else if (0xff53ba7 == v0) {
                        EMERGENCY_MINT_CODE();
                    } else {
                        require(0x248a9ca3 == v0);
                        getRoleAdmin(bytes32);
                    }
                } else if (0x2b385bcf == v0) {
                    WRAP_CODE();
                } else if (0x2d07ae69 == v0) {
                    REMOVE_CODE();
                } else if (0x2ee63e44 == v0) {
                    LOCK_MINT_CODE();
                } else if (0x2f2ff15d == v0) {
                    grantRole(bytes32,address);
                } else {
                    require(0x36568abe == v0);
                    renounceRole(bytes32,address);
                }
            } else if (0x692a34f4 > v0) {
                if (0x3e7e25c1 == v0) {
                    castToBytes32(address);
                } else if (0x3f4ba83a == v0) {
                    unpause();
                } else if (0x54fd4d50 == v0) {
                    version();
                } else if (0x5c975abb == v0) {
                    paused();
                } else {
                    require(0x6869cb96 == v0);
                    BURN_MINT_CODE();
                }
            } else if (0x692a34f4 == v0) {
                ops(bytes32);
            } else if (0x6b750d63 == v0) {
                resume(bytes32,uint8,string[],bytes[]);
            } else if (0x76a3fb3e == v0) {
                BURN_UNLOCK_CODE();
            } else if (0x778c89b9 == v0) {
                UNWRAP_CODE();
            } else {
                require(0x7ecebe00 == v0);
                nonces(address);
            }
        } else if (0xad351f9f > v0) {
            if (0x9ba520ad > v0) {
                if (0x8456cb59 == v0) {
                    pause();
                } else if (0x84b0196e == v0) {
                    eip712Domain();
                } else if (0x9010d07c == v0) {
                    getRoleMember(bytes32,uint256);
                } else if (0x91d14854 == v0) {
                    hasRole(bytes32,address);
                } else {
                    require(0x95ad709a == v0);
                    poolAdapter(address);
                }
            } else if (0x9ba520ad == v0) {
                ADD_CODE();
            } else if (0x9bb68c75 == v0) {
                EMERGENCY_UNLOCK_CODE();
            } else if (0xa217fddf == v0) {
                DEFAULT_ADMIN_ROLE();
            } else if (0xa785ac5a == v0) {
                startedOps(bytes32);
            } else {
                require(0xab1efbab == v0);
                ACCOUNTANT_ROLE();
            }
        } else if (0xbeadbe32 > v0) {
            if (0xad351f9f == v0) {
                PERMIT_CODE();
            } else if (0xb2e1df72 == v0) {
                registerComplexOp((string,bool)[]);
            } else if (0xb4ccca0d == v0) {
                receiveValidatedData(bytes4,address,uint64);
            } else if (0xba677db7 == v0) {
                start(string[],bytes[],(uint256,uint256,uint8,bytes32,bytes32));
            } else {
                require(0xbcf4f0a6 == v0);
                setPoolAdapter(address,address);
            }
        } else if (0xbeadbe32 == v0) {
            SWAP_CODE();
        } else if (0xca15c873 == v0) {
            getRoleMemberCount(bytes32);
        } else if (0xd547741f == v0) {
            revokeRole(bytes32,address);
        } else if (0xf5887cdd == v0) {
            addressBook();
        } else if (0xf5b541a6 == v0) {
            OPERATOR_ROLE();
        } else {
            require(0xf87cf42b == v0);
            processedOps(bytes32);
        }
    }
}
