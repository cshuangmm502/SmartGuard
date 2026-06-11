// Decompiled by library.dedaub.com
// 2026.05.20 02:40 UTC
// Compiled using the solidity compiler version 0.8.3


// Data structures and variables inferred from the use of storage instructions
mapping (address => mapping (address => uint256)) _vaultAllowance; // STORAGE[0x1]
address _rUNE; // STORAGE[0x0] bytes 0 to 19


// Events
Deposit(address, address, uint256, string);
VaultTransfer(address, address, (address, uint256)[], string);
TransferOut(address, address, address, uint256, string);

function batchTransferOut(address[] recipients, (address,uint256) coins, [] memos) public payable { 
    v0 = v1 = 0;
    require(msg.data.length - 4 >= 96, v1, v1);
    require(recipients <= uint64.max, v1, v1);
    require(4 + recipients + 31 < msg.data.length, v1, v1);
    require(recipients.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v2 = new address[](recipients.length);
    require(!((v2 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (recipients.length << 5) + 31) < v2) | (v2 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (recipients.length << 5) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    v3 = v4 = v2.data;
    v5 = v6 = recipients.data;
    require(4 + recipients + (recipients.length << 5) + 32 <= msg.data.length, v1, v1);
    while (v0 < recipients.length) {
        require(msg.data[v5] == address(msg.data[v5]));
        MEM[v3] = msg.data[v5];
        v0 += 1;
        v3 += 32;
        v5 += 32;
    }
    require(coins <= uint64.max, v1, v1);
    v7 = 0;
    require(4 + coins + 31 < msg.data.length, v7, v7);
    require(coins.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v8 = new uint256[](coins.length);
    require(!((v8 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (coins.length << 5) + 31) < v8) | (v8 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (coins.length << 5) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    v9 = v10 = v8.data;
    v11 = v12 = coins.data;
    require(4 + coins + (coins.length << 6) + 32 <= msg.data.length, v7, v7);
    while (v7 < coins.length) {
        require(msg.data.length - v11 >= 64, v7, v7);
        v13 = new struct(2);
        require(!((v13 + 64 < v13) | (v13 + 64 > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
        require(msg.data[v11] == address(msg.data[v11]));
        v13.word0 = msg.data[v11];
        v13.word1 = msg.data[32 + v11];
        MEM[v9] = v13;
        v9 += 32;
        v11 = v11 + 64;
        v7 += 1;
    }
    require(memos <= uint64.max);
    v14 = 0;
    require(4 + memos + 31 < msg.data.length, v14, v14);
    require(memos.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v15 = new uint256[](memos.length);
    require(!((v15 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (memos.length << 5) + 31) < v15) | (v15 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (memos.length << 5) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    v16 = v17 = v15.data;
    v18 = v19 = memos.data;
    while (v14 < memos.length) {
        require(4 + memos + msg.data[v18] + 32 + 31 < msg.data.length);
        v20 = msg.data[4 + memos + msg.data[v18] + 32];
        require(v20 <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
        v21 = new bytes[](v20);
        require(!((v21 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & v20 + 31) + 31) < v21) | (v21 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & v20 + 31) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
        require(4 + memos + msg.data[v18] + 32 + v20 + 32 <= msg.data.length);
        CALLDATACOPY(v21.data, 4 + memos + msg.data[v18] + 32 + 32, v20);
        v21[v20] = 0;
        MEM[v16] = v21;
        v16 += 32;
        v18 += 32;
        v14 += 1;
    }
    v22 = v23 = 0;
    while (v22 < v8.length) {
        require(v22 < v2.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(v22 < v8.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(v22 < v8.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        v24 = v25 = MEM[32 + v8[v22]];
        require(v22 < v15.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        if (address(MEM[v8[v22]])) {
            v26 = _SafeSub(_vaultAllowance[msg.sender][address(MEM[v8[v22]])], v25);
            _vaultAllowance[msg.sender][address(MEM[v8[v22]])] = v26;
            MEM[MEM[64] + 68] = v25;
            MEM[MEM[64] + 32] = 0xa9059cbb00000000000000000000000000000000000000000000000000000000 | uint224(address(v2[v22]));
            v27 = v28 = 0;
            while (v27 < 68) {
                MEM[v27 + MEM[64]] = MEM[v27 + (MEM[64] + 32)];
                v27 += 32;
            }
            if (v27 > 68) {
                MEM[68 + MEM[64]] = 0;
            }
            v29 = address(MEM[v8[v22]]).call(MEM[MEM[64]:MEM[64] + 68 + MEM[64] - MEM[64]], MEM[MEM[64]:MEM[64]]).gas(msg.gas);
            if (RETURNDATASIZE() != 0) {
                MEM[64] = MEM[64] + (RETURNDATASIZE() + 63 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                MEM[MEM[64]] = RETURNDATASIZE();
                RETURNDATACOPY(MEM[64] + 32, 0, RETURNDATASIZE());
            }
        } else {
            v24 = msg.value;
            v30 = address(v2[v22]).call().value(v24).gas(msg.gas);
            if (RETURNDATASIZE() != 0) {
                MEM[64] = MEM[64] + (RETURNDATASIZE() + 63 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
                MEM[MEM[64]] = RETURNDATASIZE();
                RETURNDATACOPY(MEM[64] + 32, 0, RETURNDATASIZE());
            }
        }
        MEM[MEM[64]] = address(MEM[v8[v22]]);
        MEM[MEM[64] + 32] = v24;
        MEM[MEM[64] + 64] = 96;
        MEM[MEM[64] + 96] = MEM[v15[v22]];
        v31 = v32 = 0;
        while (v31 < MEM[v15[v22]]) {
            MEM[v31 + (MEM[64] + 96 + 32)] = MEM[v31 + (v15[v22] + 32)];
            v31 += 32;
        }
        if (v31 > MEM[v15[v22]]) {
            MEM[MEM[v15[v22]] + (MEM[64] + 96 + 32)] = 0;
        }
        emit TransferOut(msg.sender, address(v2[v22]));
        v22 = 0x118a(v22);
    }
    exit;
}

function _SafeAdd(uint256 varg0, uint256 varg1) private { 
    require(varg0 <= ~varg1, Panic(17)); // arithmetic overflow or underflow
    return varg0 + varg1;
}

function _SafeSub(uint256 varg0, uint256 varg1) private { 
    require(varg0 >= varg1, Panic(17)); // arithmetic overflow or underflow
    return varg0 - varg1;
}

function 0x118a(uint256 varg0) private { 
    require(varg0 != uint256.max, Panic(17)); // arithmetic overflow or underflow
    return 1 + varg0;
}

function transferOut(address to, address asset, uint256 amount, string memo) public payable { 
    require(msg.data.length - 4 >= 128);
    require(memo <= uint64.max);
    require(4 + memo + 31 < msg.data.length);
    require(memo.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v0 = new bytes[](memo.length);
    require(!((v0 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & memo.length + 31) + 31) < v0) | (v0 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & memo.length + 31) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    require(4 + memo + memo.length + 32 <= msg.data.length);
    CALLDATACOPY(v0.data, memo.data, memo.length);
    v0[memo.length] = 0;
    if (asset) {
        v1 = _SafeSub(_vaultAllowance[msg.sender][asset], amount);
        _vaultAllowance[msg.sender][asset] = v1;
        v2 = v3 = 0;
        while (v2 < 68) {
            MEM[v2 + MEM[64]] = MEM[v2 + (MEM[64] + 32)];
            v2 += 32;
        }
        if (v2 > 68) {
            MEM[68 + MEM[64]] = 0;
        }
        v4, /* uint256 */ v5 = asset.transfer(to, amount).gas(msg.gas);
        if (RETURNDATASIZE() != 0) {
            v6 = new bytes[](RETURNDATASIZE());
            RETURNDATACOPY(v6.data, 0, RETURNDATASIZE());
        }
    } else {
        v7 = v8 = msg.value;
        v9, /* uint256 */ v10 = to.call().value(v8).gas(msg.gas);
        if (RETURNDATASIZE() != 0) {
            v11 = new bytes[](RETURNDATASIZE());
            RETURNDATACOPY(v11.data, 0, RETURNDATASIZE());
        }
    }
    v12 = new bytes[](v0.length);
    v13 = v14 = 0;
    while (v13 < v0.length) {
        v12[v13] = v0[v13];
        v13 += 32;
    }
    if (v13 > v0.length) {
        v12[v0.length] = 0;
    }
    emit TransferOut(msg.sender, to, asset, v7, v12);
}

function RUNE() public nonPayable { 
    return _rUNE;
}

function fallback() public payable { 
    revert();
}

function vaultAllowance(address vault, address token) public nonPayable { 
    require(msg.data.length - 4 >= 64);
    return _vaultAllowance[vault][token];
}

function 0x884(bytes varg0, uint256 varg1, address varg2, address varg3, address varg4) private { 
    v0 = _SafeSub(_vaultAllowance[msg.sender][varg2], varg1);
    _vaultAllowance[msg.sender][varg2] = v0;
    require(bool(varg2.code.size));
    v1, /* bool */ v2 = varg2.approve(varg4, varg1).gas(msg.gas);
    require(bool(v1), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    require(v2 == bool(v2));
    v3 = new bytes[](varg0.length);
    v4 = v5 = 0;
    while (v4 < varg0.length) {
        v3[v4] = varg0[v4];
        v4 += 32;
    }
    if (v4 > varg0.length) {
        v3[varg0.length] = 0;
    }
    require(bool(varg4.code.size));
    v6 = varg4.deposit(varg3, varg2, varg1, v3).gas(msg.gas);
    require(bool(v6), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    return ;
}

function 0x9aa(uint256 varg0, address varg1) private { 
    require(bool(varg1.code.size));
    v0, /* uint256 */ v1 = varg1.balanceOf(this).gas(msg.gas);
    require(bool(v0), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    v2 = v3 = 0;
    while (v2 < 100) {
        MEM[v2 + MEM[64]] = MEM[v2 + (MEM[64] + 32)];
        v2 += 32;
    }
    if (v2 > 100) {
        MEM[100 + MEM[64]] = 0;
    }
    v4 = v5, /* uint256 */ v6, /* uint256 */ v7 = varg1.transferFrom(msg.sender, this, varg0).gas(msg.gas);
    if (RETURNDATASIZE() == 0) {
        v8 = v9 = 96;
    } else {
        v8 = v10 = new bytes[](RETURNDATASIZE());
        v6 = v10.data;
        RETURNDATACOPY(v6, 0, RETURNDATASIZE());
    }
    if (v5) {
        v4 = v11 = !MEM[v8];
        if (MEM[v8]) {
            require(v7 + MEM[v8] - v7 >= 32);
            v4 = MEM[v7];
            require(v4 == bool(v4));
        }
    }
    require(v4);
    require(bool(varg1.code.size));
    v12, /* uint256 */ v13 = varg1.balanceOf(this).gas(msg.gas);
    require(bool(v12), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
    require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
    v14 = _SafeSub(v13, v1);
    return v14;
}

function transferAllowance(address router, address newVault, address asset, uint256 amount, string memo) public nonPayable { 
    require(msg.data.length - 4 >= 160);
    require(memo <= uint64.max);
    require(4 + memo + 31 < msg.data.length);
    require(memo.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v0 = new bytes[](memo.length);
    require(!((v0 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & memo.length + 31) + 31) < v0) | (v0 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & memo.length + 31) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    require(4 + memo + memo.length + 32 <= msg.data.length);
    CALLDATACOPY(v0.data, memo.data, memo.length);
    v0[memo.length] = 0;
    if (this != router) {
        0x884(v0, amount, asset, newVault, router);
    } else {
        v1 = _SafeSub(_vaultAllowance[msg.sender][asset], amount);
        _vaultAllowance[msg.sender][asset] = v1;
        v2 = _SafeAdd(_vaultAllowance[newVault][asset], amount);
        _vaultAllowance[newVault][asset] = v2;
        v3 = new bytes[](v0.length);
        v4 = v5 = 0;
        while (v4 < v0.length) {
            v3[v4] = v0[v4];
            v4 += 32;
        }
        if (v4 > v0.length) {
            v3[v0.length] = 0;
        }
        emit 0x5b90458f953d3fcb2d7fb25616a2fddeca749d0c47cc5c9832d0266b5346eea(msg.sender, newVault, asset, amount, v3);
    }
}

function deposit(address vault, address asset, uint256 amount, string memo) public payable { 
    require(msg.data.length - 4 >= 128);
    require(memo <= uint64.max);
    require(4 + memo + 31 < msg.data.length);
    require(memo.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v0 = new bytes[](memo.length);
    require(!((v0 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & memo.length + 31) + 31) < v0) | (v0 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & memo.length + 31) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    require(4 + memo + memo.length + 32 <= msg.data.length);
    CALLDATACOPY(v0.data, memo.data, memo.length);
    v0[memo.length] = 0;
    if (asset) {
        if (_rUNE != asset) {
            v1 = v2 = 0x9aa(amount, asset);
            v3 = _SafeAdd(_vaultAllowance[vault][asset], v2);
            _vaultAllowance[vault][asset] = v3;
        } else {
            require(bool(_rUNE.code.size));
            v4, /* bool */ v5 = _rUNE.transferTo(this, amount).gas(msg.gas);
            require(bool(v4), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
            require(v5 == bool(v5));
            require(bool(_rUNE.code.size));
            v6 = _rUNE.burn(amount).gas(msg.gas);
            require(bool(v6), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
        }
    } else {
        v1 = v7 = msg.value;
        v8, /* uint256 */ v9 = vault.call().value(v7).gas(msg.gas);
        if (RETURNDATASIZE() != 0) {
            v10 = new bytes[](RETURNDATASIZE());
            v9 = v10.data;
            RETURNDATACOPY(v9, 0, RETURNDATASIZE());
        }
    }
    v11 = new bytes[](v0.length);
    v12 = v13 = 0;
    while (v12 < v0.length) {
        v11[v12] = v0[v12];
        v12 += 32;
    }
    if (v12 > v0.length) {
        v11[v0.length] = 0;
    }
    emit Deposit(vault, asset, v1, v11);
}

function returnVaultAssets(address router, address asgard, (address,uint256) coins, [] memo) public payable { 
    require(msg.data.length - 4 >= 128);
    require(coins <= uint64.max);
    v0 = 0;
    require(4 + coins + 31 < msg.data.length, v0, v0);
    require(coins.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v1 = new uint256[](coins.length);
    require(!((v1 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (coins.length << 5) + 31) < v1) | (v1 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (coins.length << 5) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    v2 = v3 = v1.data;
    v4 = v5 = coins.data;
    require(4 + coins + (coins.length << 6) + 32 <= msg.data.length, v0, v0);
    while (v0 < coins.length) {
        require(msg.data.length - v4 >= 64, v0, v0);
        v6 = new struct(2);
        require(!((v6 + 64 < v6) | (v6 + 64 > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
        require(msg.data[v4] == address(msg.data[v4]));
        v6.word0 = msg.data[v4];
        v6.word1 = msg.data[32 + v4];
        MEM[v2] = v6;
        v2 += 32;
        v4 = v4 + 64;
        v0 += 1;
    }
    require(memo <= uint64.max);
    require(4 + memo + 31 < msg.data.length);
    require(memo.length <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v7 = new bytes[](memo.length);
    require(!((v7 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & memo.length + 31) + 31) < v7) | (v7 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & 32 + (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 & memo.length + 31) + 31) > uint64.max)), Panic(65)); // failed memory allocation (too much memory)
    require(4 + memo + memo.length + 32 <= msg.data.length);
    CALLDATACOPY(v7.data, memo.data, memo.length);
    v7[memo.length] = 0;
    if (this != router) {
        v8 = v9 = 0;
        while (v8 < v1.length) {
            require(v8 < v1.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            require(v8 < v1.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            v10 = _SafeSub(_vaultAllowance[msg.sender][address(MEM[v1[v8]])], MEM[32 + v1[v8]]);
            _vaultAllowance[msg.sender][address(MEM[v1[v8]])] = v10;
            require(bool((address(MEM[v1[v8]])).code.size));
            v11, /* bool */ v12 = address(MEM[v1[v8]]).approve(router, MEM[32 + v1[v8]]).gas(msg.gas);
            require(bool(v11), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
            require(MEM[64] + RETURNDATASIZE() - MEM[64] >= 32);
            require(v12 == bool(v12));
            v13 = new bytes[](v7.length);
            v14 = v15 = 0;
            while (v14 < v7.length) {
                v13[v14] = v7[v14];
                v14 += 32;
            }
            if (v14 > v7.length) {
                v13[v7.length] = 0;
            }
            require(bool(router.code.size));
            v16 = router.deposit(asgard, address(MEM[v1[v8]]), MEM[32 + v1[v8]], v13).gas(msg.gas);
            require(bool(v16), 0, RETURNDATASIZE()); // checks call status, propagates error data on error
            v8 = 0x118a(v8);
        }
    } else {
        v17 = v18 = 0;
        while (v17 < v1.length) {
            require(v17 < v1.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            require(v17 < v1.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            v19 = _SafeSub(_vaultAllowance[msg.sender][address(MEM[v1[v17]])], MEM[32 + v1[v17]]);
            _vaultAllowance[msg.sender][address(MEM[v1[v17]])] = v19;
            v20 = _SafeAdd(_vaultAllowance[asgard][address(MEM[v1[v17]])], MEM[32 + v1[v17]]);
            _vaultAllowance[asgard][address(MEM[v1[v17]])] = v20;
            v17 = 0x118a(v17);
        }
        v21 = new uint256[](v1.length);
        v22 = v23 = 0;
        v24 = v25 = v21.data;
        v26 = v27 = v1.data;
        while (v22 < v1.length) {
            MEM[v24] = address(MEM[MEM[v26]]);
            MEM[v24 + 32] = MEM[32 + MEM[v26]];
            v24 += 64;
            v26 += 32;
            v22 += 1;
        }
        v24 = new bytes[](v7.length);
        v28 = v29 = 0;
        while (v28 < v7.length) {
            v24[v28] = v7[v28];
            v28 += 32;
        }
        if (v28 > v7.length) {
            v24[v7.length] = 0;
        }
        emit VaultTransfer(msg.sender, asgard, v21, v24);
    }
    v30, /* uint256 */ v31 = asgard.call().value(msg.value).gas(msg.gas);
    if (RETURNDATASIZE() != 0) {
        v32 = new bytes[](RETURNDATASIZE());
        RETURNDATACOPY(v32.data, 0, RETURNDATASIZE());
    }
}

// Note: The function selector is not present in the original solidity code.
// However, we display it for the sake of completeness.

function __function_selector__( function_selector) public payable { 
    MEM[64] = 128;
    if (msg.data.length < 4) {
        fallback();
    } else if (0x2923e82e > function_selector >> 224) {
        if (0x3b6a673 == function_selector >> 224) {
            vaultAllowance(address,address);
        } else if (0x1b738b32 == function_selector >> 224) {
            transferAllowance(address,address,address,uint256,string);
        } else {
            require(0x1fece7b4 == function_selector >> 224);
            deposit(address,address,uint256,string);
        }
    } else if (0x2923e82e == function_selector >> 224) {
        returnVaultAssets(address,address,(address,uint256)[],string);
    } else if (0x48f1651d == function_selector >> 224) {
        batchTransferOut(address[],(address,uint256)[],string[]);
    } else if (0x574da717 == function_selector >> 224) {
        transferOut(address,address,uint256,string);
    } else {
        require(0x93e4eaa9 == function_selector >> 224);
        RUNE();
    }
}
