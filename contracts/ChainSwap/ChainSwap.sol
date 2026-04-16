// Decompiled by library.dedaub.com
// 2026.01.21 09:04 UTC
// Compiled using the solidity compiler version 0.6.12


// Data structures and variables inferred from the use of storage instructions
bool stor_0_0_0; // STORAGE[0x0] bytes 0 to 0
bool ___TokenMapped_init; // STORAGE[0x0] bytes 1 to 1
bytes32 _dOMAIN_SEPARATOR; // STORAGE[0x65]
uint256 _mainChainId; // STORAGE[0x67]
mapping (address => uint256) _authQuotaOf; // STORAGE[0x6a]
mapping (uint256 => mapping (address => uint256)) _sentCount; // STORAGE[0x6b]
mapping (uint256 => mapping (address => mapping (uint256 => uint256))) _sent; // STORAGE[0x6c]
mapping (uint256 => mapping (address => mapping (uint256 => uint256))) _received; // STORAGE[0x6d]
address _factory; // STORAGE[0x66] bytes 0 to 19
address _token; // STORAGE[0x68] bytes 0 to 19
address _creator; // STORAGE[0x69] bytes 0 to 19


// Events
Send(address, uint256, address, uint256, uint256);
IncreaseAuthQuota(address, uint256, uint256);
Authorize(uint256, address, uint256, uint256, address);
Receive(uint256, address, uint256, uint256);
ChargeFee(address, address, uint256);
DecreaseAuthQuota(address, uint256, uint256);

function 0x1348(address varg0, address varg1) private { 
    v0 = v1 = ___TokenMapped_init;
    if (!v1) {
        v0 = this.code.size == 0;
    }
    if (!v0) {
        v0 = v2 = !stor_0_0_0;
    }
    require(v0, Error('Contract instance has already been initialized'));
    if (!___TokenMapped_init) {
        ___TokenMapped_init = 1;
        stor_0_0_0 = 1;
    }
    _factory = varg1;
    _mainChainId = CHAINID();
    _token = varg0;
    _creator = 0;
    require(bool(_token.code.size));
    v3, /* uint256 */ v4 = _token.name().gas(msg.gas);
    require(bool(v3), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    RETURNDATACOPY(v4, 0, RETURNDATASIZE());
    require(v4 + RETURNDATASIZE() - v4 >= 32);
    require(MEM[v4] <= uint64.max);
    require(v4 + MEM[v4] + 31 < v4 + RETURNDATASIZE());
    v5 = MEM[v4 + MEM[v4]];
    require(v5 <= uint64.max);
    v6 = new bytes[](v5);
    require(!((v6 + ((v5 + 31 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0) + 32) > uint64.max) | (v6 + ((v5 + 31 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0) + 32) < v6)));
    require(v4 + MEM[v4] + 32 + v5 <= v4 + RETURNDATASIZE());
    v7 = v8 = 0;
    while (v7 < v5) {
        v6[v7] = MEM[v4 + MEM[v4] + 32 + v7];
        v7 = v7 + 32;
    }
    if (v7 > v5) {
        v6[v5] = 0;
    }
    v9 = v6.length;
    v10 = v6.data;
    _dOMAIN_SEPARATOR = keccak256(0x8cad95687ba82c2ce50e74f7b754645e5117c3a5bec8151c0726d5857980a866, keccak256(v6), CHAINID(), address(this));
    if (___TokenMapped_init) {
        return ;
    } else {
        ___TokenMapped_init = 0;
        return ;
    }
}

function creator() public nonPayable { 
    return _creator;
}

function authQuotaOf(address signatory) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 32);
    return _authQuotaOf[signatory];
}

function 0x172c() private { 
    require(bool(_factory.code.size));
    v0, /* uint256 */ v1 = _factory.getConfig(0x6665650000000000000000000000000000000000000000000000000000000000).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    MEM[64] = MEM[64] + (RETURNDATASIZE() + 31 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(msg.value >= v1, Error('fee is too low'));
    require(bool(_factory.code.size));
    v2, /* uint256 */ v3 = _factory.getConfig('feeTo').gas(msg.gas);
    require(bool(v2), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    MEM[64] = MEM[64] + (RETURNDATASIZE() + 31 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    if (address(v3) == address(0x0)) {
        v3 = v4 = _factory;
    }
    v5 = address(v3).call().value(msg.value).gas(!msg.value * 2300);
    require(bool(v5), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    emit ChargeFee(msg.sender, address(v3), msg.value);
    return ;
}

function 0x1a19(uint256 varg0, address varg1) private { 
    v0 = 0x2037(_token);
    require(v0, Error('SafeERC20: call to non-contract'));
    v1 = v2 = 0;
    while (v1 < 100) {
        MEM[MEM[64] + v1] = MEM[MEM[64] + 32 + v1];
        v1 = v1 + 32;
    }
    if (v1 > 100) {
        MEM[MEM[64] + 100] = 0;
    }
    v3, /* uint256 */ v4, /* uint256 */ v5 = _token.transferFrom(varg1, address(this), varg0).gas(msg.gas);
    if (RETURNDATASIZE() == 0) {
        v6 = v7 = 96;
    } else {
        v6 = v8 = new bytes[](RETURNDATASIZE());
        RETURNDATACOPY(v8.data, 0, RETURNDATASIZE());
    }
    require(v3, Error('SafeERC20: low-level call failed'));
    if (MEM[v6] > 0) {
        require(v5 + MEM[v6] - v5 >= 32);
        require(MEM[v5] == bool(MEM[v5]));
        require(MEM[v5], Error('SafeERC20: ERC20 operation did not succeed'));
    }
    return ;
}

function mainChainId() public nonPayable { 
    return _mainChainId;
}

function 0x1a83() private { 
    v0 = v1 = ___TokenMapped_init;
    if (!v1) {
        v0 = this.code.size == 0;
    }
    if (!v0) {
        v0 = v2 = !stor_0_0_0;
    }
    require(v0, Error('Contract instance has already been initialized'));
    if (!___TokenMapped_init) {
        ___TokenMapped_init = 1;
        stor_0_0_0 = 1;
    }
    if (___TokenMapped_init) {
        return ;
    } else {
        ___TokenMapped_init = 0;
        return ;
    }
}

function _SafeAdd(uint256 varg0, uint256 varg1) private { 
    require(varg1 + varg0 >= varg1, Error('SafeMath: addition overflow'));
    return varg1 + varg0;
}

function 0x1cb8(uint256 varg0, address varg1) private { 
    v0 = 0x2037(_token);
    require(v0, Error('SafeERC20: call to non-contract'));
    v1 = v2 = 0;
    while (v1 < 68) {
        MEM[MEM[64] + v1] = MEM[MEM[64] + 32 + v1];
        v1 = v1 + 32;
    }
    if (v1 > 68) {
        MEM[MEM[64] + 68] = 0;
    }
    v3, /* uint256 */ v4, /* uint256 */ v5 = _token.transfer(varg1, varg0).gas(msg.gas);
    if (RETURNDATASIZE() == 0) {
        v6 = v7 = 96;
    } else {
        v6 = v8 = new bytes[](RETURNDATASIZE());
        RETURNDATACOPY(v8.data, 0, RETURNDATASIZE());
    }
    require(v3, Error('SafeERC20: low-level call failed'));
    if (MEM[v6] > 0) {
        require(v5 + MEM[v6] - v5 >= 32);
        require(MEM[v5] == bool(MEM[v5]));
        require(MEM[v5], Error('SafeERC20: ERC20 operation did not succeed'));
    }
    return ;
}

function increaseAuthQuotas(address[] signatories, uint256[] increments) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 64);
    require(signatories <= uint64.max);
    require(4 + signatories + 31 < 4 + (msg.data.length - 4));
    require(signatories.length <= uint64.max);
    v0 = new address[](signatories.length);
    require(!((v0 + ((signatories.length << 5) + 32) > uint64.max) | (v0 + ((signatories.length << 5) + 32) < v0)));
    v1 = v2 = signatories.data;
    v3 = v4 = v0.data;
    require(v2 + (signatories.length << 5) <= 4 + (msg.data.length - 4));
    v5 = v6 = 0;
    while (v5 < signatories.length) {
        require(msg.data[v1] == address(msg.data[v1]));
        MEM[v3] = msg.data[v1];
        v3 = v3 + 32;
        v1 = v1 + 32;
        v5 = v5 + 1;
    }
    require(increments <= uint64.max);
    require(4 + increments + 31 < 4 + (msg.data.length - 4));
    require(increments.length <= uint64.max);
    v7 = new uint256[](increments.length);
    require(!((v7 + ((increments.length << 5) + 32) > uint64.max) | (v7 + ((increments.length << 5) + 32) < v7)));
    v8 = v9 = increments.data;
    v10 = v11 = v7.data;
    require(v9 + (increments.length << 5) <= 4 + (msg.data.length - 4));
    v12 = v13 = 0;
    while (v12 < increments.length) {
        require(msg.data[v8] == msg.data[v8]);
        MEM[v10] = msg.data[v8];
        v10 = v10 + 32;
        v8 = v8 + 32;
        v12 = v12 + 1;
    }
    require(v0.length == v7.length, Error('two array lenth not equal'));
    require(v0.length <= uint64.max);
    v14 = new uint256[](v0.length);
    if (v0.length) {
        CALLDATACOPY(v14.data, msg.data.length, v0.length << 5);
    }
    v15 = v16 = 0;
    while (v15 < v0.length) {
        assert(v15 < v0.length);
        assert(v15 < v7.length);
        require(msg.sender == _factory, Error('Only called by Factory'));
        v17 = _SafeAdd(v7[v15], _authQuotaOf[address(v0[v15])]);
        _authQuotaOf[address(v0[v15])] = v17;
        emit IncreaseAuthQuota(address(v0[v15]), v7[v15], v17);
        assert(v15 < v14.length);
        v14[v15] = v17;
        v15 += 1;
    }
    v18 = new uint256[](v14.length);
    v19 = v20 = v18.data;
    v21 = v22 = v14.data;
    v23 = v24 = 0;
    while (v23 < v14.length) {
        MEM[v19] = MEM[v21];
        v19 = v19 + 32;
        v21 = v21 + 32;
        v23 = v23 + 1;
    }
    return v18;
}

function _SafeSub(uint256 varg0, uint256 varg1) private { 
    if (varg0 <= varg1) {
        return varg1 - varg0;
    } else {
        v0 = new bytes[](v1.length);
        v2 = v3 = 0;
        while (v2 < v1.length) {
            v0[v2] = v1[v2];
            v2 = v2 + 32;
        }
        if (v2 > v1.length) {
            v0[v1.length] = 0;
        }
        revert(Error(v0, v4, 'SafeMath: subtraction overflow'));
    }
}

function 0x2037(uint256 varg0) private { 
    if (EXTCODEHASH(varg0) == 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470) {
        return EXTCODEHASH(varg0) != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    } else {
        return EXTCODEHASH(varg0) != 0;
    }
}

function DOMAIN_TYPEHASH() public nonPayable { 
    return 0x8cad95687ba82c2ce50e74f7b754645e5117c3a5bec8151c0726d5857980a866;
}

function received(uint256 varg0, address varg1, uint256 varg2) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 96);
    return _received[varg0][varg1][varg2];
}

function sendFrom(address from, uint256 toChainId, address to, uint256 volume) public payable { 
    require(4 + (msg.data.length - 4) - 4 >= 128);
    v0 = 0x705(volume, to, toChainId, from);
    return v0;
}

function DOMAIN_SEPARATOR() public nonPayable { 
    return _dOMAIN_SEPARATOR;
}

function __TokenMapped_init(address factory_, address token_) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 64);
    v0 = v1 = ___TokenMapped_init;
    if (!v1) {
        v0 = this.code.size == 0;
    }
    if (!v0) {
        v0 = v2 = !stor_0_0_0;
    }
    require(v0, Error('Contract instance has already been initialized'));
    if (!___TokenMapped_init) {
        ___TokenMapped_init = 1;
        stor_0_0_0 = 1;
    }
    0x1a83();
    0x1348(token_, factory_);
    if (!___TokenMapped_init) {
        ___TokenMapped_init = 0;
    }
}

function needApprove() public nonPayable { 
    return True;
}

function decreaseAuthQuota(address signatory, uint256 decrement) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 64);
    require(msg.sender == _factory, Error('Only called by Factory'));
    v0 = _authQuotaOf[signatory];
    if (v0 < decrement) {
    }
    v1 = _SafeSub(v0, _authQuotaOf[signatory]);
    _authQuotaOf[signatory] = v1;
    emit DecreaseAuthQuota(signatory, v0, v1);
    return v1;
}

function sent(uint256 varg0, address varg1, uint256 varg2) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 96);
    return _sent[varg0][varg1][varg2];
}

function increaseAuthQuota(address signatory, uint256 increment) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 64);
    require(msg.sender == _factory, Error('Only called by Factory'));
    v0 = _SafeAdd(increment, _authQuotaOf[signatory]);
    _authQuotaOf[signatory] = v0;
    emit IncreaseAuthQuota(signatory, increment, v0);
    return v0;
}

function send(uint256 toChainId, address to, uint256 volume) public payable { 
    require(4 + (msg.data.length - 4) - 4 >= 96);
    v0 = 0x705(volume, to, toChainId, msg.sender);
    return v0;
}

function RECEIVE_TYPEHASH() public nonPayable { 
    return 0x8452bf83368fd24f930388bb8032e83547faee72dbe22b73045150c5e682d662;
}

function decreaseAuthQuotas(address[] signatories, uint256[] decrements) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 64);
    require(signatories <= uint64.max);
    require(4 + signatories + 31 < 4 + (msg.data.length - 4));
    require(signatories.length <= uint64.max);
    v0 = new address[](signatories.length);
    require(!((v0 + ((signatories.length << 5) + 32) > uint64.max) | (v0 + ((signatories.length << 5) + 32) < v0)));
    v1 = v2 = signatories.data;
    v3 = v4 = v0.data;
    require(v2 + (signatories.length << 5) <= 4 + (msg.data.length - 4));
    v5 = v6 = 0;
    while (v5 < signatories.length) {
        require(msg.data[v1] == address(msg.data[v1]));
        MEM[v3] = msg.data[v1];
        v3 = v3 + 32;
        v1 = v1 + 32;
        v5 = v5 + 1;
    }
    require(decrements <= uint64.max);
    require(4 + decrements + 31 < 4 + (msg.data.length - 4));
    require(decrements.length <= uint64.max);
    v7 = new uint256[](decrements.length);
    require(!((v7 + ((decrements.length << 5) + 32) > uint64.max) | (v7 + ((decrements.length << 5) + 32) < v7)));
    v8 = v9 = decrements.data;
    v10 = v11 = v7.data;
    require(v9 + (decrements.length << 5) <= 4 + (msg.data.length - 4));
    v12 = v13 = 0;
    while (v12 < decrements.length) {
        require(msg.data[v8] == msg.data[v8]);
        MEM[v10] = msg.data[v8];
        v10 = v10 + 32;
        v8 = v8 + 32;
        v12 = v12 + 1;
    }
    require(v0.length == v7.length, Error('two array lenth not equal'));
    require(v0.length <= uint64.max);
    v14 = new uint256[](v0.length);
    if (v0.length) {
        CALLDATACOPY(v14.data, msg.data.length, v0.length << 5);
    }
    v15 = v16 = 0;
    while (v15 < v0.length) {
        assert(v15 < v0.length);
        assert(v15 < v7.length);
        v17 = v18 = v7[v15];
        require(msg.sender == _factory, Error('Only called by Factory'));
        v17 = _authQuotaOf[address(v0[v15])];
        if (v17 < v18) {
        }
        v19 = _SafeSub(v17, _authQuotaOf[address(v0[v15])]);
        _authQuotaOf[address(v0[v15])] = v19;
        emit DecreaseAuthQuota(address(v0[v15]), v17, v19);
        assert(v15 < v14.length);
        v14[v15] = v19;
        v15 += 1;
    }
    v20 = new uint256[](v14.length);
    v21 = v22 = v20.data;
    v23 = v24 = v14.data;
    v25 = v26 = 0;
    while (v25 < v14.length) {
        MEM[v21] = MEM[v23];
        v21 = v21 + 32;
        v23 = v23 + 32;
        v25 = v25 + 1;
    }
    return v20;
}

function receive(uint256 fromChainId, address to, uint256 nonce, uint256 volume, (address,uint8,bytes32,bytes32) signatures) public payable { 
    require(4 + (msg.data.length - 4) - 4 >= 160);
    require(signatures <= uint64.max);
    require(4 + signatures + 31 < 4 + (msg.data.length - 4));
    require(signatures.length <= uint64.max);
    v0 = new uint256[](signatures.length);
    require(!((v0 + ((signatures.length << 5) + 32) > uint64.max) | (v0 + ((signatures.length << 5) + 32) < v0)));
    v1 = v2 = signatures.data;
    v3 = v4 = v0.data;
    require(v2 + (signatures.length << 7) <= 4 + (msg.data.length - 4));
    v5 = v6 = 0;
    while (v5 < signatures.length) {
        require(4 + (msg.data.length - 4) - v1 >= 128);
        v7 = new struct(4);
        require(!((v7 + 128 > uint64.max) | (v7 + 128 < v7)));
        require(msg.data[v1] == address(msg.data[v1]));
        v7.word0 = msg.data[v1];
        require(msg.data[v1 + 32] == uint8(msg.data[v1 + 32]));
        v7.word1 = msg.data[v1 + 32];
        require(msg.data[v1 + 64] == msg.data[v1 + 64]);
        v7.word2 = msg.data[v1 + 64];
        require(msg.data[v1 + 96] == msg.data[v1 + 96]);
        v7.word3 = msg.data[v1 + 96];
        MEM[v3] = v7;
        v3 = v3 + 32;
        v1 = v1 + 128;
        v5 = v5 + 1;
    }
    0x172c();
    require(_received[fromChainId][to][nonce] == 0, Error('withdrawn already'));
    require(bool(_factory.code.size));
    v8, /* uint256 */ v9 = _factory.getConfig('minSignatures').gas(msg.gas);
    require(bool(v8), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    MEM[64] = MEM[64] + (RETURNDATASIZE() + 31 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v0.length >= v9, Error('too few signatures'));
    v10 = v11 = 0;
    while (v10 < v0.length) {
        v12 = v13 = 0;
        while (v12 < v10) {
            assert(v12 < v0.length);
            assert(v10 < v0.length);
            require(address(MEM[v0[v10]]) != address(MEM[v0[v12]]), Error('repetitive signatory'));
            v12 += 1;
        }
        assert(v10 < v0.length);
        assert(v10 < v0.length);
        assert(v10 < v0.length);
        assert(v10 < v0.length);
        MEM[MEM[64]] = 0;
        v14, /* address */ v15 = ecrecover(keccak256(0x1901000000000000000000000000000000000000000000000000000000000000, _dOMAIN_SEPARATOR, keccak256(0x8452bf83368fd24f930388bb8032e83547faee72dbe22b73045150c5e682d662, fromChainId, to, nonce, volume, address(MEM[v0[v10]]))), uint8(MEM[32 + v0[v10]]), MEM[64 + v0[v10]], MEM[96 + v0[v10]]);
        require(bool(v14), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
        require(address(v15) != address(0x0), Error('invalid signature'));
        assert(v10 < v0.length);
        require(address(v15) == address(MEM[v0[v10]]), Error('unauthorized'));
        assert(v10 < v0.length);
        v16 = _SafeSub(volume, _authQuotaOf[address(MEM[v0[v10]])]);
        _authQuotaOf[address(MEM[v0[v10]])] = v16;
        emit DecreaseAuthQuota(address(MEM[v0[v10]]), volume, v16);
        emit Authorize(to, nonce, address(v15), fromChainId, volume);
        v10 += 1;
    }
    _received[fromChainId][to][nonce] = volume;
    0x1cb8(volume, to);
    emit Receive(fromChainId, to, nonce, volume);
}

function __TokenMapped_init_unchained(address factory_, address token_) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 64);
    0x1348(token_, factory_);
}

function factory() public nonPayable { 
    return _factory;
}

function totalMapped() public nonPayable { 
    require(bool(_token.code.size));
    v0, /* uint256 */ v1 = _token.balanceOf(address(this)).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    MEM[64] = MEM[64] + (RETURNDATASIZE() + 31 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    return v1;
}

function token() public nonPayable { 
    return _token;
}

function sentCount(uint256 varg0, address varg1) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 64);
    return _sentCount[varg0][varg1];
}

function fallback() public payable { 
    revert();
}

function 0x705(uint256 varg0, address varg1, uint256 varg2, uint256 varg3) private { 
    0x172c();
    0x1a19(varg0, varg3);
    v0 = _sentCount[varg2][varg1];
    _sentCount[varg2][varg1] = 1 + v0;
    _sent[varg2][varg1][v0] = varg0;
    emit Send(address(varg3), varg2, varg1, v0, varg0);
    return v0;
}

// Note: The function selector is not present in the original solidity code.
// However, we display it for the sake of completeness.

function __function_selector__( function_selector) public payable { 
    MEM[64] = 128;
    if (msg.data.length < 4) {
        fallback();
    } else if (0x75986b50 > function_selector >> 224) {
        if (0x2186ff4e > function_selector >> 224) {
            if (0x2d05d3f == function_selector >> 224) {
                creator();
            } else if (0xc0f261e == function_selector >> 224) {
                authQuotaOf(address);
            } else if (0xf45ad43 == function_selector >> 224) {
                mainChainId();
            } else if (0x1e86c2ac == function_selector >> 224) {
                increaseAuthQuotas(address[],uint256[]);
            } else {
                require(0x20606b70 == function_selector >> 224);
                DOMAIN_TYPEHASH();
            }
        } else if (0x2186ff4e == function_selector >> 224) {
            received(uint256,address,uint256);
        } else if (0x2c4a952b == function_selector >> 224) {
            sendFrom(address,uint256,address,uint256);
        } else if (0x3644e515 == function_selector >> 224) {
            DOMAIN_SEPARATOR();
        } else if (0x370d60ae == function_selector >> 224) {
            __TokenMapped_init(address,address);
        } else if (0x5d3b5f80 == function_selector >> 224) {
            needApprove();
        } else {
            require(0x6489aba5 == function_selector >> 224);
            decreaseAuthQuota(address,uint256);
        }
    } else if (0xa653d60c > function_selector >> 224) {
        if (0x75986b50 == function_selector >> 224) {
            sent(uint256,address,uint256);
        } else if (0x7a62f5c6 == function_selector >> 224) {
            increaseAuthQuota(address,uint256);
        } else if (0x81b34f15 == function_selector >> 224) {
            send(uint256,address,uint256);
        } else if (0x82900934 == function_selector >> 224) {
            RECEIVE_TYPEHASH();
        } else {
            require(0xa25d7c86 == function_selector >> 224);
            decreaseAuthQuotas(address[],uint256[]);
        }
    } else if (0xa653d60c == function_selector >> 224) {
        receive(uint256,address,uint256,uint256,(address,uint8,bytes32,bytes32)[]);
    } else if (0xaf4b4379 == function_selector >> 224) {
        __TokenMapped_init_unchained(address,address);
    } else if (0xc45a0155 == function_selector >> 224) {
        factory();
    } else if (0xdc51b6ac == function_selector >> 224) {
        totalMapped();
    } else if (0xfc0c546a == function_selector >> 224) {
        token();
    } else {
        require(0xfe57a691 == function_selector >> 224);
        sentCount(uint256,address);
    }
}
