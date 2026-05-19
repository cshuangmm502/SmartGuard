// Decompiled by library.dedaub.com
// 2024.04.21 01:16 UTC
// Compiled using the solidity compiler version 0.4.7<=v<0.5.9


// Data structures and variables inferred from the use of storage instructions
mapping (uint256 => uint256) _balanceOf; // STORAGE[0x0]
mapping (uint256 => mapping (uint256 => uint256)) _allowance; // STORAGE[0x1]
uint256 _totalSupply; // STORAGE[0x2]
uint256[] _name; // STORAGE[0x3]
uint256[] _symbol; // STORAGE[0x4]
uint256 stor_7; // STORAGE[0x7]
uint8 _decimals; // STORAGE[0x5] bytes 0 to 0
address owner_5_1_20; // STORAGE[0x5] bytes 1 to 20
address _changeDCRMOwner; // STORAGE[0x6] bytes 0 to 19


// Events
LogSwapout(address, uint256, string);
LogChangeDCRMOwner(address, address, uint256);
Approval(address, address, uint256);
Transfer(address, address, uint256);

function name() public payable { 
    v0 = new bytes[]((_name.length & (!(_name.length & 0x1) << 8) + ~0) >> 1);
    v1 = v2 = v0.data;
    if ((_name.length & (!(_name.length & 0x1) << 8) + ~0) >> 1) {
        if (31 < (_name.length & (!(_name.length & 0x1) << 8) + ~0) >> 1) {
            v3 = v4 = _name.data;
            do {
                MEM[v1] = STORAGE[v3];
                v3 += 1;
                v1 += 32;
            } while (v2 + ((_name.length & (!(_name.length & 0x1) << 8) + ~0) >> 1) <= v1);
        } else {
            MEM[v2] = _name.length >> 8 << 8;
        }
    }
    v5 = new bytes[](v0.length);
    v6 = 0;
    while (v6 < v0.length) {
        v5[v6] = v0[v6];
        v6 += 32;
    }
    v7 = v0.length + v5.data;
    if (0x1f & v0.length) {
        MEM[v7 - (0x1f & v0.length)] = ~(256 ** (32 - (0x1f & v0.length)) - 1) & MEM[v7 - (0x1f & v0.length)];
    }
    return v5;
}

function approve(address spender, uint256 amount) public payable { 
    require(msg.data.length - 4 >= 64);
    0xa54(amount, spender, msg.sender);
    return True;
}

function totalSupply() public payable { 
    return _totalSupply;
}

function transferFrom(address sender, address recipient, uint256 amount) public payable { 
    require(msg.data.length - 4 >= 96);
    0xb4a(amount, recipient, sender);
    v0 = _SafeSub('ERC20: transfer amount exceeds allowance', amount, _allowance[sender][msg.sender]);
    0xa54(v0, msg.sender, sender);
    return True;
}

function decimals() public payable { 
    return _decimals;
}

function increaseAllowance(address spender, uint256 addedValue) public payable { 
    require(msg.data.length - 4 >= 64);
    require(addedValue + _allowance[msg.sender][spender] >= _allowance[msg.sender][spender], Error('SafeMath: addition overflow'));
    0xa54(addedValue + _allowance[msg.sender][spender], spender, msg.sender);
    return True;
}

function balanceOf(address account) public payable { 
    require(msg.data.length - 4 >= 32);
    return _balanceOf[account];
}

function owner() public payable { 
    v0 = 0x60b();
    return address(v0);
}

function function_selector() public payable { 
    revert();
}

function symbol() public payable { 
    v0 = new bytes[]((_symbol.length & (!(_symbol.length & 0x1) << 8) + ~0) >> 1);
    v1 = v2 = v0.data;
    if ((_symbol.length & (!(_symbol.length & 0x1) << 8) + ~0) >> 1) {
        if (31 < (_symbol.length & (!(_symbol.length & 0x1) << 8) + ~0) >> 1) {
            v3 = v4 = _symbol.data;
            do {
                MEM[v1] = STORAGE[v3];
                v3 += 1;
                v1 += 32;
            } while (v2 + ((_symbol.length & (!(_symbol.length & 0x1) << 8) + ~0) >> 1) <= v1);
        } else {
            MEM[v2] = _symbol.length >> 8 << 8;
        }
    }
    v5 = new bytes[](v0.length);
    v6 = 0;
    while (v6 < v0.length) {
        v5[v6] = v0[v6];
        v6 += 32;
    }
    v7 = v0.length + v5.data;
    if (0x1f & v0.length) {
        MEM[v7 - (0x1f & v0.length)] = ~(256 ** (32 - (0x1f & v0.length)) - 1) & MEM[v7 - (0x1f & v0.length)];
    }
    return v5;
}

function decreaseAllowance(address spender, uint256 subtractedValue) public payable { 
    require(msg.data.length - 4 >= 64);
    v0 = _SafeSub('ERC20: decreased allowance below zero', subtractedValue, _allowance[msg.sender][spender]);
    0xa54(v0, spender, msg.sender);
    return True;
}

function transfer(address recipient, uint256 amount) public payable { 
    require(msg.data.length - 4 >= 64);
    0xb4a(amount, recipient, msg.sender);
    return True;
}

function Swapout(uint256 amount, string bindaddr) public payable { 
    require(msg.data.length - 4 >= 64);
    require(bindaddr <= 0x100000000);
    require(bindaddr.data <= 4 + (msg.data.length - 4));
    require(!((bindaddr.length > 0x100000000) | (bindaddr.data + bindaddr.length > 4 + (msg.data.length - 4))));
    v0 = new bytes[](bindaddr.length);
    CALLDATACOPY(v0.data, bindaddr.data, bindaddr.length);
    v0[bindaddr.length] = 0;
    require(v0.length >= 26, Error('address length is too short'));
    assert(0 < v0.length);
    v1 = v0.data;
    v2 = v0.data;
    assert(1 < v0.length);
    assert(2 < v0.length);
    assert(3 < v0.length);
    v3 = v4 = bytes1(v0[0] >> 248 << 248) == 0x4c00000000000000000000000000000000000000000000000000000000000000;
    if (bytes1(v0[0] >> 248 << 248) != 0x4c00000000000000000000000000000000000000000000000000000000000000) {
        v3 = bytes1(v0[0] >> 248 << 248) == 0x4d00000000000000000000000000000000000000000000000000000000000000;
    }
    if (!v3) {
        v5 = v6 = bytes1(v0[3] >> 248 << 248) == 0x3100000000000000000000000000000000000000000000000000000000000000;
        if (v6) {
            v5 = v7 = bytes1(v0[0] >> 248 << 248) == 0x6c00000000000000000000000000000000000000000000000000000000000000;
        }
        if (v5) {
            v5 = v8 = bytes1(v0[1] >> 248 << 248) == 0x7400000000000000000000000000000000000000000000000000000000000000;
        }
        if (v5) {
            v5 = bytes1(v0[2] >> 248 << 248) == 0x6300000000000000000000000000000000000000000000000000000000000000;
        }
        require(v5, Error('unsupported address leading symbol'));
        v9 = v10 = 43 == v0.length;
        if (43 != v0.length) {
            v9 = 63 == v0.length;
        }
        require(bool(v9), Error('segwit address length is not 43 or 63'));
    } else {
        require(v0.length <= 34, Error('mainnet address length is too long'));
    }
    require(bool(address(msg.sender)), Error('ERC20: burn from the zero address'));
    v11 = _SafeSub('ERC20: burn amount exceeds balance', amount, _balanceOf[msg.sender]);
    _balanceOf[msg.sender] = v11;
    v12 = _SafeSub('SafeMath: subtraction overflow', amount, _totalSupply);
    _totalSupply = v12;
    MEM[MEM[64]] = amount;
    emit Transfer(msg.sender, 0, amount);
    MEM[MEM[64]] = amount;
    v13 = new bytes[](v0.length);
    v14 = v15 = 0;
    while (v14 < v0.length) {
        v13[v14] = v0[v14];
        v14 += 32;
    }
    v16 = v17 = v0.length + v13.data;
    if (0x1f & v0.length) {
        MEM[v17 - (0x1f & v0.length)] = ~(256 ** (32 - (0x1f & v0.length)) - 1) & MEM[v17 - (0x1f & v0.length)];
    }
    emit LogSwapout(msg.sender, amount, v13);
    MEM[MEM[64]] = True;
    return True;
}

function changeDCRMOwner(address newOwner) public payable { 
    require(msg.data.length - 4 >= 32);
    v0 = 0x60b();
    require(msg.sender == address(v0), Error('only owner'));
    require(bool(address(address(newOwner))), Error('new owner is the zero address'));
    v1 = 0x60b();
    owner_5_1_20 = v1;
    _changeDCRMOwner = newOwner;
    stor_7 = 13300 + block.number;
    emit LogChangeDCRMOwner(address((address(v1) << 8 | ~0xffffffffffffffffffffffffffffffffffffffff00 & STORAGE[0x5]) >> 8), _changeDCRMOwner, 13300 + block.number);
    return True;
}

function allowance(address owner, address spender) public payable { 
    require(msg.data.length - 4 >= 64);
    return _allowance[owner][spender];
}

function Swapin(bytes32 txhash, address account, uint256 amount) public payable { 
    require(msg.data.length - 4 >= 96);
    v0 = 0x60b();
    require(msg.sender == address(v0), Error('only owner'));
    require(bool(address(address(account))), Error('ERC20: mint to the zero address'));
    require(amount + _totalSupply >= _totalSupply, Error('SafeMath: addition overflow'));
    _totalSupply += amount;
    require(amount + _balanceOf[account] >= _balanceOf[account], Error('SafeMath: addition overflow'));
    _balanceOf[account] += amount;
    emit Transfer(0, account, amount);
    emit 0x5d0634fe981be85c22e2942a880821b70095d84e152c3ea3c17a4e4250d9d61(txhash, account, amount);
    return True;
}

function 0x60b() private { 
    if (block.number < stor_7) {
        return owner_5_1_20;
    } else {
        return _changeDCRMOwner;
    }
}

function 0xa54(uint256 varg0, address varg1, address varg2) private { 
    require(bool(address(varg2)), Error('ERC20: approve from the zero address'));
    require(bool(address(varg1)), Error('ERC20: approve to the zero address'));
    _allowance[varg2][varg1] = varg0;
    emit Approval(varg2, varg1, varg0);
    return ;
}

function 0xb4a(uint256 varg0, address varg1, address varg2) private { 
    require(bool(address(varg2)), Error('ERC20: transfer from the zero address'));
    require(bool(address(varg1)), Error('ERC20: transfer to the zero address'));
    v0 = _SafeSub('ERC20: transfer amount exceeds balance', varg0, _balanceOf[varg2]);
    _balanceOf[varg2] = v0;
    require(varg0 + _balanceOf[varg1] >= _balanceOf[varg1], Error('SafeMath: addition overflow'));
    _balanceOf[varg1] += varg0;
    emit Transfer(varg2, varg1, varg0);
    return ;
}

function _SafeSub(bytes varg0, uint256 varg1, uint256 varg2) private { 
    if (varg1 <= varg2) {
        return varg2 - varg1;
    } else {
        v0 = new bytes[](varg0.length);
        v1 = v2 = 0;
        while (v1 < varg0.length) {
            v0[v1] = varg0[v1];
            v1 += 32;
        }
        v3 = v4 = varg0.length + v0.data;
        if (0x1f & varg0.length) {
            MEM[v4 - (0x1f & varg0.length)] = ~(256 ** (32 - (0x1f & varg0.length)) - 1) & MEM[v4 - (0x1f & varg0.length)];
        }
        revert(Error(v0));
    }
}

// Note: The function selector is not present in the original solidity code.
// However, we display it for the sake of completeness.

function function_selector( function_selector) public payable { 
    MEM[64] = 128;
    require(!msg.value);
    if (msg.data.length < 4) {
        fallback();
    } else if (0x8da5cb5b > function_selector >> 224) {
        if (0x23b872dd > function_selector >> 224) {
            if (0x6fdde03 == function_selector >> 224) {
                name();
            } else if (0x95ea7b3 == function_selector >> 224) {
                approve(address,uint256);
            } else {
                require(0x18160ddd == function_selector >> 224);
                totalSupply();
            }
        } else if (0x23b872dd == function_selector >> 224) {
            transferFrom(address,address,uint256);
        } else if (0x313ce567 == function_selector >> 224) {
            decimals();
        } else if (0x39509351 == function_selector >> 224) {
            increaseAllowance(address,uint256);
        } else {
            require(0x70a08231 == function_selector >> 224);
            balanceOf(address);
        }
    } else if (0xad54056d > function_selector >> 224) {
        if (0x8da5cb5b == function_selector >> 224) {
            owner();
        } else if (0x95d89b41 == function_selector >> 224) {
            symbol();
        } else if (0xa457c2d7 == function_selector >> 224) {
            decreaseAllowance(address,uint256);
        } else {
            require(0xa9059cbb == function_selector >> 224);
            transfer(address,uint256);
        }
    } else if (0xad54056d == function_selector >> 224) {
        Swapout(uint256,string);
    } else if (0xb524f3a5 == function_selector >> 224) {
        changeDCRMOwner(address);
    } else if (0xdd62ed3e == function_selector >> 224) {
        allowance(address,address);
    } else {
        require(0xec126c77 == function_selector >> 224);
        Swapin(bytes32,address,uint256);
    }
}
