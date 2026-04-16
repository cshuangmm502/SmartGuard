contract Contract {

  uint256 paused; // 0x0
  mapping (uint256 => ?) roleAdmin;
  uint256 _chainID; // 0x2
  uint256 _relayerThreshold; // 0x3
  uint256 _totalRelayers; // 0x4
  uint256 _totalOperators; // 0x5
  uint256 _totalProposals; // 0x6
  uint256 _fee; // 0x7
  uint256 _expiry; // 0x8
  uint256 _wtokenAddress; // 0x9
  mapping (uint256 => ?) _depositCounts;
  mapping (uint256 => ?) _specialFee;
  mapping (uint256 => ?) _resourceIDToHandlerAddress;
  mapping (uint256 => ?) map_d;
  mapping (uint256 => ?) _proposals;
  mapping (uint256 => ?) _hasVotedOnProposal;

  function __function_selector__(uint256 function_selector) public {
    M64 = 0x80;
    if ((msg.data.length() < 0x4)) {
      ()();
    } else {
      v12 = (0xe0 >> function_selector);
      if ((0x80ae1c28 > v12)) {
        if ((0x4b0b919d > v12)) {
          if ((0x2f2ff15d > v12)) {
            if ((0x5e2ca17 == v12)) {
              deposit(uint8,bytes32,bytes)();
            } else {
              if ((0x83132c4 == v12)) {
                getFee(uint8)();
              } else {
                if ((0x17f03ce5 == v12)) {
                  cancelProposal(uint8,uint64,bytes32)();
                } else {
                  if ((0x1a5ae9ad == v12)) {
                    _specialFee(uint8)();
                  } else {
                    if ((0x1ff013f1 == v12)) {
                      voteProposal(uint8,uint64,bytes32,bytes32)();
                    } else {
                      require((0x248a9ca3 == v12) == 0)
                      getRoleAdmin(bytes32)();
                    }
                  }
                }
              }
            }
          } else {
            if ((0x2f2ff15d == v12)) {
              grantRole(bytes32,address)();
            } else {
              if ((0x320b9006 == v12)) {
                adminRemoveOperator(address)();
              } else {
                if ((0x36568abe == v12)) {
                  renounceRole(bytes32,address)();
                } else {
                  if ((0x3ee7094a == v12)) {
                    _depositRecords(uint64,uint8)();
                  } else {
                    if ((0x4454b20d == v12)) {
                      executeProposal(uint8,uint64,bytes,bytes32)();
                    } else {
                      require((0x4603ae38 == v12) == 0)
                      transferFunds(address[],uint256[])();
                    }
                  }
                }
              }
            }
          }
        } else {
          if ((0x5c975abb > v12)) {
            if ((0x4b0b919d == v12)) {
              _depositCounts(uint8)();
            } else {
              if ((0x4e056005 == v12)) {
                adminChangeRelayerThreshold(uint256)();
              } else {
                if ((0x50598719 == v12)) {
                  _proposals(uint72,bytes32)();
                } else {
                  if ((0x53ec4105 == v12)) {
                    _wtokenAddress()();
                  } else {
                    if ((0x541d5548 == v12)) {
                      isRelayer(address)();
                    } else {
                      require((0x5a1ad87c == v12) == 0)
                      adminSetGenericResource(address,bytes32,address,bytes4,uint256,bytes4)();
                    }
                  }
                }
              }
            }
          } else {
            if ((0x6d70f7ae > v12)) {
              if ((0x5c975abb == v12)) {
                paused()();
              } else {
                if ((0x5e1fab0f == v12)) {
                  renounceAdmin(address)();
                } else {
                  require((0x69a8c246 == v12) == 0)
                  adminChangeSpecialFee(uint256,uint8)();
                }
              }
            } else {
              if ((0x6d70f7ae == v12)) {
                isOperator(address)();
              } else {
                if ((0x780cf004 == v12)) {
                  adminWithdraw(address,address,address,uint256)();
                } else {
                  if ((0x7febe63f == v12)) {
                    _hasVotedOnProposal(uint72,bytes32,address)();
                  } else {
                    require((0x802aabe8 == v12) == 0)
                    _totalRelayers()();
                  }
                }
              }
            }
          }
        }
      } else {
        if ((0xbeab7131 > v12)) {
          if ((0x926d7d7f > v12)) {
            if ((0x80ae1c28 == v12)) {
              adminPauseTransfers()();
            } else {
              if ((0x84db809f == v12)) {
                _resourceIDToHandlerAddress(bytes32)();
              } else {
                if ((0x8c0c2631 == v12)) {
                  adminSetBurnable(address,address)();
                } else {
                  if ((0x9010d07c == v12)) {
                    getRoleMember(bytes32,uint256)();
                  } else {
                    if ((0x91c404ac == v12)) {
                      adminChangeFee(uint256)();
                    } else {
                      require((0x91d14854 == v12) == 0)
                      hasRole(bytes32,address)();
                    }
                  }
                }
              }
            }
          } else {
            if ((0x926d7d7f == v12)) {
              RELAYER_ROLE()();
            } else {
              if ((0x95b15e98 == v12)) {
                adminUpdateBridgeAddress(address,address)();
              } else {
                if ((0x9d5773e0 == v12)) {
                  _totalProposals()();
                } else {
                  if ((0x9d82dd63 == v12)) {
                    adminRemoveRelayer(address)();
                  } else {
                    if ((0xa217fddf == v12)) {
                      DEFAULT_ADMIN_ROLE()();
                    } else {
                      require((0xa9cf69fa == v12) == 0)
                      getProposal(uint8,uint64,bytes32)();
                    }
                  }
                }
              }
            }
          }
        } else {
          if ((0xd547741f > v12)) {
            if ((0xbeab7131 == v12)) {
              _chainID()();
            } else {
              if ((0xc5b37c22 == v12)) {
                _fee()();
              } else {
                if ((0xc5ec8970 == v12)) {
                  _expiry()();
                } else {
                  if ((0xca15c873 == v12)) {
                    getRoleMemberCount(bytes32)();
                  } else {
                    if ((0xcb10f215 == v12)) {
                      adminSetResource(address,bytes32,address)();
                    } else {
                      require((0xcdb0f73a == v12) == 0)
                      adminAddRelayer(address)();
                    }
                  }
                }
              }
            }
          } else {
            if ((0xf5b541a6 > v12)) {
              if ((0xd547741f == v12)) {
                revokeRole(bytes32,address)();
              } else {
                if ((0xd7a9cd79 == v12)) {
                  _relayerThreshold()();
                } else {
                  require((0xf179637c == v12) == 0)
                  depositETH(uint8,bytes32,bytes)();
                }
              }
            } else {
              if ((0xf5b541a6 == v12)) {
                OPERATOR_ROLE()();
              } else {
                if ((0xf69bd044 == v12)) {
                  _totalOperators()();
                } else {
                  if ((0xfebce92c == v12)) {
                    adminAddOperator(address)();
                  } else {
                    require((0xffaac0eb == v12) == 0)
                    adminUnpauseTransfers()();
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  function renounceRole_impl(uint256 v106farg0, uint256 v106farg1, uint256 v106farg2) private {
    v1fddV106f = msg.sender;
    v108a = address(v106farg0);
  }

  function hasRole_impl(uint256 v174carg0, uint256 v174carg1, uint256 v174carg2) private {
    M0 = v174carg1;
    M32 = 0x1;
    v175b = 0x1714;
    v218cV174c = address(v174carg0);
    M0 = v218cV174c;
    M32 = keccak256(0, 64) + 1;
    return(STORAGE[keccak256(0x0, 0x40)]) // to v174carg2;
  }

  function revokeRole_impl(uint256 v1ae4arg0, uint256 v1ae4arg1, uint256 v1ae4arg2) private {
    M32 = 0x1;
    v1af6 = roleAdmin[v1ae4arg1][0x2];
    v1ae46d0_0 = hasRole_impl(msg.sender, v1af6, 0x1b02);
  }

  function deposit_impl(uint256 v1ed8arg0) private {
    if (!uint8(paused)) {
      return() // to v1ed8arg0;
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x10;
      MEM[M64 + 68] = 0x5061757361626c653a2070617573656400000000000000000000000000000000;
      v305c = M64 + 100;
      throw();
    }
  }

  function getFee_impl(uint256 v1efbarg0, uint256 v1efbarg1) private {
    v1eff = uint8(v1efbarg0);
    M32 = 0xb;
    va571efb_0 = _specialFee[v1eff];
    if (!va571efb_0) {
      va571efb_0 = _fee;
      GOTO 0xa57;
    }
    return(va571efb_0) // to v1efbarg1;
  }

  function cancelProposal_impl(uint256 v1f6farg0, uint256 v1f6farg1, uint256 v1f6farg2) private {
    M64 = M64 + 64;
    MEM[M64] = 0x1e;
    MEM[M64 + 32] = 0x536166654d6174683a207375627472616374696f6e206f766572666c6f770000;
    v21e4 = (v1f6farg0 > v1f6farg1);
  }

  function executeProposal_impl(uint256 v1fb1arg0) private {
    MEM[M64] = 0x52454c415945525f524f4c450000000000000000000000000000000000000000;
    v2b3bV1fb1 = M64 + 12;
    v1fb11f52_0 = hasRole_impl(msg.sender, keccak256(M64, 0xc), 0x1fc0);
  }

  function adminChangeRelayerThreshold_impl(uint256 v204farg0) private {
    v2059_0 = hasRole_impl(msg.sender, 0x0, 0x205a);
  }

  function 0x2076(uint256 v2076arg0, uint256 v2076arg1, uint256 v2076arg2) private {
    M32 = 0x1;
    v2085 = 0x2094;
    v2222V2076 = 0x1714;
    v222fV2076 = address(v2076arg0);
    M0 = v222fV2076;
    M32 = keccak256(0, 64) + 1;
  }

  function adminPauseTransfers_impl(uint256 v20e5arg0) private {
    v2105_0 = hasRole_impl(msg.sender, 0x0, 0x20f0);
  }

  function deposit() public {
  }

  function getFee(uint8 varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v28e0V2ef = 0x1714;
    require((varg0 == varg0) == 0)
    va53_0V2fe = getFee_impl(varg0, 0xa54);
    MEM[M64] = va53_0V2fe;
    v2ba0V3032e3 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function cancelProposal(uint8 varg0, uint64 varg1, bytes32 varg2) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x60) == 0)
    v294aV325 = 0x2953;
    require((varg0 == varg0) == 0)
    v2956V325 = 0x2962;
    require((varg1 == varg1) == 0)
    v1f53_0Va5c = hasRole_impl(msg.sender, 0x0, 0x1f30);
    v1f53_0Va5c = hasRole_impl(msg.sender, 0x0, 0x1f30)
    if (!v1f53_0Va5c) {
      MEM[M64] = 0x52454c415945525f524f4c450000000000000000000000000000000000000000;
      v2b3bV1f36Va5c = M64 + 12;
      v1f53_0Va5c = hasRole_impl(msg.sender, keccak256(M64, 0xc), 0x1f53);
    }
    if (v1f53_0Va5c) {
      M32 = 0xe;
      M32 = keccak256(0x0, 0x40);
      require(!(uint8(_proposals[varg2][0x4]) > 0x4) == 0)
      if (!(uint8(_proposals[varg2][0x4]) == 0x4)) {
        vade_0 = cancelProposal_impl(_proposals[varg2][0x5], block.number, 0xadf);
        if ((vade_0 > _expiry)) {
          _proposals[varg2][0x4] = (0x4 | (~0xff & _proposals[varg2][0x4]));
          M0 = M0;
          v36f1 = 0x803c5a12f6bde629cea32e63d4b92d1b560816a6fb72e939d3c89e1cab650417;
          MEM[M64] = _proposals[varg2];
          MEM[M64 + 32] = _proposals[varg2][0x1];
          v2bfbVafc = M64 + 64;
          log(M64, 0x40, v36f1, varg0, varg1, 0x4);
          exit();
        } else {
          MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
          MEM[M64 + 4] = 0x20;
          MEM[M64 + 36] = 0x20;
          MEM[M64 + 68] = 0x50726f706f73616c206e6f7420617420657870697279207468726573686f6c64;
          v904319_0 = M64 + 100;
          GOTO 0x904;
        }
      } else {
        MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
        MEM[M64 + 4] = 0x20;
        MEM[M64 + 36] = 0x1a;
        MEM[M64 + 68] = 0x50726f706f73616c20616c72656164792063616e63656c6c6564000000000000;
        v904319_0 = M64 + 100;
      }
      throw();
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x1e;
      MEM[M64 + 68] = 0x73656e646572206973206e6f742072656c61796572206f722061646d696e0000;
      v2dc0Va5c = M64 + 100;
      throw();
    }
  }

  function _specialFee(uint8 varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v28e0V345 = 0x1714;
    require((varg0 == varg0) == 0)
    M32 = 0xb;
    MEM[M64] = _specialFee[varg0];
    v2ba0V303339 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function () public {
    throw();
  }

  function voteProposal(uint8 varg0, uint64 varg1, bytes32 varg2, bytes32 varg3) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x80) == 0)
    v2988 = 0x2991;
    require((varg0 == varg0) == 0)
    require((varg1 == varg1) == 0)
    executeProposal_impl(0xb69);
    deposit_impl(0xb71);
    vb90V374 = 0x1;
    M32 = 0xe;
    M32 = keccak256(0x0, 0x40);
    M0 = varg2;
    M32 = 0xc;
    if (address(STORAGE[keccak256(0x0, 0x40)])) {
      require(!(uint8(_proposals[vb90V374][0x4]) > 0x4) == 0)
      if (!(uint8(_proposals[vb90V374][0x4]) > 0x1)) {
        M0 = 0x1;
        M32 = 0xf;
        M0 = varg3;
        M32 = keccak256(0x0, 0x40);
        M0 = msg.sender;
        M32 = keccak256(0x0, 0x40);
        if (!uint8(STORAGE[keccak256(0x0, 0x40)])) {
          require(!(uint8(_proposals[vb90V374][0x4]) > 0x4) == 0)
          if (uint8(_proposals[vb90V374][0x4])) {
            vdf7_0V374 = cancelProposal_impl(_proposals[vb90V374][0x5], block.number, 0xdf8);
            if (!(vdf7_0V374 > _expiry)) {
              if ((varg3 == _proposals[vb90V374][0x1])) {
                _proposals[vb90V374][0x2] = (_proposals[vb90V374][0x2] + 0x1);
                STORAGE[(keccak256(0x0, 0x20) + _proposals[vb90V374][0x2])] = (msg.sender | (~0xffffffffffffffffffffffffffffffffffffffff & STORAGE[(keccak256(0x0, 0x20) + _proposals[vb90V374][0x2])]));
              } else {
                MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
                MEM[M64 + 4] = 0x20;
                MEM[M64 + 36] = 0x11;
                MEM[M64 + 68] = 0x6461746168617368206d69736d61746368000000000000000000000000000000;
                v904b61_0V374 = M64 + 100;
                GOTO 0x904;
              }
            } else {
              vdda_4V374 = 0x4;
              _proposals[vb90V374][vdda_4V374] = (vdda_4V374 | (~0xff & _proposals[vb90V374][vdda_4V374]));
            }
          } else {
            _totalProposals = _totalProposals + 1;
            M64 = M64 + 192;
            MEM[M64] = varg2;
            MEM[M64 + 32] = varg3;
            MEM[M64] = 0x1;
            M64 = M64 + 64;
            CALLDATACOPY(M64 + 32, msg.data.length(), 0x20);
            MEM[M64 + 64] = M64;
            MEM[M64] = 0x0;
            M64 = M64 + 32;
            MEM[M64 + 96] = M64;
            MEM[M64 + 128] = 0x1;
            MEM[M64 + 160] = block.number;
            vce7V374 = 0x1;
            M32 = 0xe;
            M32 = keccak256(0x0, 0x40);
            _proposals[vce7V374] = MEM[M64];
            _proposals[vce7V374][0x1] = MEM[M64 + 32];
            v246e_2Vc74V374 = (MEM[M64 + 64] + 0x20);
            _proposals[vce7V374][0x2] = MEM[MEM[M64 + 64]];
            v246e_1Vc74V374 = keccak256(0x0, 0x20);
            if (MEM[MEM[M64 + 64]]) {
              while (true) {
                if (!((v246e_2Vc74V374 + (0x20 * MEM[MEM[M64 + 64]])) > v2465_2Vc74V374)) break;
                STORAGE[v246e_1Vc74V374] = (address(MEM[v246e_2Vc74V374]) | (~0xffffffffffffffffffffffffffffffffffffffff & STORAGE[v246e_1Vc74V374]));
                v246e_2Vc74V374 = v246e_2Vc74V374 + 32;
                v246e_1Vc74V374 = v246e_1Vc74V374 + 1;
                GOTO 0x2465;
              }
            }
            v249cVc74V374 = 0x2441;
            v24f9V249aVc74V374 = 0x1538;
            while (true) {
              if (!((v246e_1Vc74V374 + _proposals[vce7V374][0x2]) > v24fe_0V249aVc74V374)) break;
              STORAGE[v2507_0V249aVc74V374] = (~0xffffffffffffffffffffffffffffffffffffffff & STORAGE[v2507_0V249aVc74V374]);
              v2507_0V249aVc74V374 = v2507_0V249aVc74V374 + 1;
              GOTO 0x24fe;
            }
            v246e_2Vd1dV374 = (MEM[M64 + 96] + 0x20);
            _proposals[vce7V374][0x3] = MEM[MEM[M64 + 96]];
            v246e_1Vd1dV374 = keccak256(0x0, 0x20);
            if (MEM[MEM[M64 + 96]]) {
              while (true) {
                if (!((v246e_2Vd1dV374 + (0x20 * MEM[MEM[M64 + 96]])) > v2465_2Vd1dV374)) break;
                STORAGE[v246e_1Vd1dV374] = (address(MEM[v246e_2Vd1dV374]) | (~0xffffffffffffffffffffffffffffffffffffffff & STORAGE[v246e_1Vd1dV374]));
                v246e_2Vd1dV374 = v246e_2Vd1dV374 + 32;
                v246e_1Vd1dV374 = v246e_1Vd1dV374 + 1;
                GOTO 0x2465;
              }
            }
            v249cVd1dV374 = 0x2441;
            v24f9V249aVd1dV374 = 0x1538;
            while (true) {
              if (!((v246e_1Vd1dV374 + _proposals[vce7V374][0x3]) > v24fe_0V249aVd1dV374)) break;
              STORAGE[v2507_0V249aVd1dV374] = (~0xffffffffffffffffffffffffffffffffffffffff & STORAGE[v2507_0V249aVd1dV374]);
              v2507_0V249aVd1dV374 = v2507_0V249aVd1dV374 + 1;
              GOTO 0x24fe;
            }
            require(!(MEM[M64 + 128] > 0x4) == 0)
            _proposals[vce7V374][0x4] = ((MEM[M64 + 128] * 0x1) | (~0xff & _proposals[vce7V374][0x4]));
            _proposals[vce7V374][0x5] = MEM[M64 + 160];
            require((0x0 < _proposals[vb90V374][0x2]) == 0)
            STORAGE[keccak256(0, 32)] = (address(msg.sender) | (~0xffffffffffffffffffffffffffffffffffffffff & STORAGE[keccak256(0, 32)]));
            vdda_4V374 = 0x1;
          }
          M0 = M0;
          v36f6V374 = 0x803c5a12f6bde629cea32e63d4b92d1b560816a6fb72e939d3c89e1cab650417;
          MEM[M64] = varg2;
          MEM[M64 + 32] = varg3;
          v2bfbVdadV374 = M64 + 64;
          log(M64, 0x40, v36f6V374, varg0, varg1, vdda_4V374);
          GOTO 0xe5d;
          require(!(uint8(_proposals[vb90V374][0x4]) > 0x4) == 0)
          if (!(uint8(_proposals[vb90V374][0x4]) == 0x4)) {
            M0 = 0x1;
            M32 = 0xf;
            M0 = varg3;
            M32 = keccak256(0x0, 0x40);
            M0 = msg.sender;
            M32 = keccak256(0x0, 0x40);
            STORAGE[keccak256(0x0, 0x40)] = (0x1 | (~0xff & STORAGE[keccak256(0x0, 0x40)]));
            require(!(uint8(_proposals[vb90V374][0x4]) > 0x4) == 0)
            MEM[M64] = varg2;
            v2ba0VebeV374 = M64 + 32;
            log(M64, 0x20, 0x25f8daaa4635a7729927ba3f5b3d59cc3320aca7c32c9db4e7ca7b9574343640, varg0, varg1, uint8(_proposals[vb90V374][0x4]));
            vf1b_0V374 = !(_relayerThreshold > 0x1);
            vf1b_0V374 = !(_relayerThreshold > 0x1)
            if ((_relayerThreshold > 0x1)) {
              vf1b_0V374 = !(_proposals[vb90V374][0x2] < _relayerThreshold);
            }
            if (vf1b_0V374) {
              _proposals[vb90V374][0x4] = (0x2 | (~0xff & _proposals[vb90V374][0x4]));
              M0 = M0;
              v36fbV374 = 0x803c5a12f6bde629cea32e63d4b92d1b560816a6fb72e939d3c89e1cab650417;
              MEM[M64] = varg2;
              MEM[M64 + 32] = varg3;
              v2bfbVf21V374 = M64 + 64;
              log(M64, 0x40, v36fbV374, varg0, varg1, 0x2);
            }
          }
          exit();
        } else {
          MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
          MEM[M64 + 4] = 0x20;
          MEM[M64 + 36] = 0x15;
          MEM[M64 + 68] = 0x72656c6179657220616c726561647920766f7465640000000000000000000000;
          v904b61_0V374 = M64 + 100;
          GOTO 0x904;
        }
      } else {
        MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
        MEM[M64 + 4] = 0x20;
        MEM[M64 + 36] = 0x2a;
        MEM[M64 + 68] = 0x70726f706f73616c20616c7265616479207061737365642f6578656375746564;
        MEM[M64 + 100] = 0x2f63616e63656c6c656400000000000000000000000000000000000000000000;
        v904b61_0V374 = M64 + 132;
        GOTO 0x904;
      }
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x19;
      MEM[M64 + 68] = 0x6e6f2068616e646c657220666f72207265736f75726365494400000000000000;
      v904b61_0V374 = M64 + 100;
    }
    throw();
  }

  function getRoleAdmin(bytes32 varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    M32 = 0x1;
    MEM[M64] = roleAdmin[varg0][0x2];
    v2ba0V303379 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function grantRole(bytes32 varg0, address varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    v27feV3a5 = 0x2637;
    require((varg1 == varg1) == 0)
    grantRole_impl(varg1, varg0, 0x2e1);
    exit();
  }

  function adminRemoveOperator(address varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v25dfV3c5 = 0x25e7;
    require((varg0 == varg0) == 0)
    adminChangeRelayerThreshold_impl(0xfd8);
    MEM[M64] = 0x4f50455241544f525f524f4c4500000000000000000000000000000000000000;
    v2b23Vfd8 = M64 + 13;
    v3b9ff4_0 = hasRole_impl(varg0, keccak256(M64, 0xd), 0xff5);
    v3b9ff4_0 = hasRole_impl(varg0, keccak256(M64, 0xd), 0xff5)
    if (v3b9ff4_0) {
      MEM[M64] = 0x4f50455241544f525f524f4c4500000000000000000000000000000000000000;
      v2b23V1011 = M64 + 13;
      revokeRole_impl(varg0, keccak256(M64, 0xd), 0x102e);
      log(M64, 0x0, 0x80c0b871b97b595b16a7741c1b06fed0c6f6f558639f18ccbce50724325dc40d, varg0);
      _totalOperators = (~0x0 + _totalOperators);
      exit();
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x20;
      MEM[M64 + 68] = 0x6164647220646f65736e27742068617665206f70657261746f7220726f6c6521;
      v329a = M64 + 100;
      throw();
    }
  }

  function renounceRole(bytes32 varg0, address varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    v27feV3e5 = 0x2637;
    require((varg1 == varg1) == 0)
    renounceRole_impl(varg1, varg0, 0x2e1);
    exit();
  }

  function _depositRecords(uint64 varg0, uint8 varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    v2863V405 = 0x286c;
    require((varg0 == varg0) == 0)
    v286fV405 = 0x287b;
    require((varg1 == varg1) == 0)
    M32 = 0xd;
    M0 = varg0;
    M32 = keccak256(0x0, 0x40);
    M0 = varg1;
    v10e5V414 = ((STORAGE[keccak256(0x0, 0x40)] & (~0x0 + (0x100 * !(STORAGE[keccak256(0x0, 0x40)] & 0x1)))) / 0x2);
    M64 = M64 + 32*v10e5V414 + 1055/32;
    MEM[M64] = v10e5V414;
    v1130_0V414 = M64 + 32;
    if (v10e5V414) {
      if ((0x1f < v10e5V414)) {
        v1130_1V414 = keccak256(0x0, 0x20);
        while (true) {
          MEM[v1130_0V414] = STORAGE[v1130_1V414];
          v1130_1V414 = v1130_1V414 + 1;
          v1130_0V414 = v1130_0V414 + 32;
          if ((v10e5V414 + v1130_0V414 > v1130_0V414)) break;
        }
      } else {
        MEM[v1130_0V414] = ((STORAGE[keccak256(0x0, 0x40)] / 0x100) * 0x100);
        GOTO 0x114d;
      }
    }
    MEM[M64] = 0x20;
    v2ca0V419 = 0x1714;
    v2ca6V419 = M64 + 32;
    v2a9f_0V419 = 0x0;
    MEM[v2ca6V419] = MEM[M64];
    while (true) {
      if (!(v2a9f_0V419 < MEM[M64])) break;
      MEM[v2aa8_0V419 + v2ca6V419 + 32] = MEM[M64 + v2aa8_0V419 + 32];
      v2a9f_0V419 = v2aa8_0V419 + 32;
      GOTO 0x2a9f;
    }
    if ((v2abb_0V419 > MEM[M64])) {
      MEM[((v2ca6V419 + MEM[M64]) + 0x20)] = v2a9f_0V419;
    }
    v2adbV419 = (0x20 + ((~0x1f & (0x1f + MEM[M64])) + v2ca6V419));
    return(MEM[M64:M64 + -M64 + v2adbV419]);
  }

  function executeProposal(uint8 varg0, uint64 varg1, bytes varg2, bytes32 varg3) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x80) == 0)
    v29d9 = 0x29e2;
    require((varg0 == varg0) == 0)
    v29e5 = 0x29f1;
    require((varg1 == varg1) == 0)
    require(!varg2 == 0)
    v2a0c = 0x2a17;
    v2a12 = varg2 + 4;
    require((v2a12 + 31 <= msg.data.length()) == 0)
    require(!(msg.data[v2a12] > 0xffffffffffffffff) == 0)
    require(!(((v2a12 + msg.data[v2a12]) + 0x20) > msg.data.length()) == 0)
    executeProposal_impl(0x115d);
    deposit_impl(0x1165);
    M32 = 0xc;
    MEM[M64 + 32] = ((0x60 << address(_resourceIDToHandlerAddress[varg3])) & ~0xffffffffffffffffffffffff);
    CALLDATACOPY(M64 + 52, v2a12 + 32, msg.data[v2a12]);
    v2b04 = (0x14 + (msg.data[v2a12] + M64 + 32));
    MEM[v2b04] = 0x0;
    MEM[M64] = (-M64 + v2b04 + ~0x1f);
    M64 = v2b04;
    v11cf = 0x1;
    M32 = 0xe;
    M32 = keccak256(0x0, 0x40);
    require(!(uint8(_proposals[v11cf][0x4]) > 0x4) == 0)
    if (!(uint8(_proposals[v11cf][0x4]) == 0x0)) {
      require(!(uint8(_proposals[v11cf][0x4]) > 0x4) == 0)
      if ((uint8(_proposals[v11cf][0x4]) == 0x2)) {
        if ((keccak256(M64 + 32, MEM[M64]) == _proposals[v11cf][0x1])) {
          _proposals[v11cf][0x4] = (0x3 | (~0xff & _proposals[v11cf][0x4]));
          M32 = 0xc;
          MEM[M64] = 0xe248cff200000000000000000000000000000000000000000000000000000000;
          MEM[M64 + 4] = _proposals[v11cf];
          MEM[M64 + 36] = 0x40;
          v2c34V126e = 0x2c41;
          v2c3aV126e = M64 + 68;
          MEM[v2c3aV126e] = msg.data[v2a12];
          CALLDATACOPY(v2c3aV126e + 32, v2a12 + 32, msg.data[v2a12]);
          MEM[((v2c3aV126e + msg.data[v2a12]) + 0x20)] = 0x0;
          v2a8dV2c27V126e = ((v2c3aV126e + ((msg.data[v2a12] + 0x1f) & ~0x1f)) + 0x20);
          require(isContract(address(_resourceIDToHandlerAddress[_proposals[v11cf]])) == 0)
          if (address(_resourceIDToHandlerAddress[_proposals[v11cf]]).call(MEM[M64 : M64 + -M64 + v2a8dV2c27V126e]).gas(msg.gas)) {
            require(!(uint8(_proposals[v11cf][0x4]) > 0x4) == 0)
            M0 = M0;
            v3700 = 0x803c5a12f6bde629cea32e63d4b92d1b560816a6fb72e939d3c89e1cab650417;
            MEM[M64] = _proposals[v11cf][0x0];
            MEM[M64 + 32] = _proposals[v11cf][0x1];
            v2bfbV1304 = M64 + 64;
            log(M64, 0x40, v3700, varg0, varg1, uint8(_proposals[v11cf][0x4]));
            exit();
          } else {
            RETURNDATACOPY(0x0, 0x0, RETURNDATASIZE);
            throw();
          }
        } else {
          MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
          MEM[M64 + 4] = 0x20;
          MEM[M64 + 36] = 0x1b;
          MEM[M64 + 68] = 0x6461746120646f65736e2774206d617463682064617461686173680000000000;
          v904426_0 = M64 + 100;
          GOTO 0x904;
        }
      } else {
        MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
        MEM[M64 + 4] = 0x20;
        MEM[M64 + 36] = 0x1c;
        MEM[M64 + 68] = 0x70726f706f73616c20616c7265616479207472616e7366657272656400000000;
        v904426_0 = M64 + 100;
        GOTO 0x904;
      }
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x16;
      MEM[M64 + 68] = 0x70726f706f73616c206973206e6f742061637469766500000000000000000000;
      v904426_0 = M64 + 100;
    }
    throw();
  }

  function transferFunds(address[] varg0, uint256[] varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    require(!varg0 == 0)
    v276eV452 = 0x2779;
    v2774V452 = varg0 + 4;
    require((v2774V452 + 31 <= msg.data.length()) == 0)
    v2530V276dV452 = msg.data[v2774V452];
    require(!(v2530V276dV452 > 0xffffffffffffffff) == 0)
    v2547V276dV452 = v2774V452 + 32;
    require(!(32*v2530V276dV452 + v2774V452 + 32 > msg.data.length()) == 0)
    require(!varg1 == 0)
    v2793V452 = 0x279e;
    v2799V452 = varg1 + 4;
    require((v2799V452 + 31 <= msg.data.length()) == 0)
    v2530V2791V452 = msg.data[v2799V452];
    require(!(v2530V2791V452 > 0xffffffffffffffff) == 0)
    v2547V2791V452 = v2799V452 + 32;
    require(!(32*v2530V2791V452 + v2799V452 + 32 > msg.data.length()) == 0)
    adminChangeRelayerThreshold_impl(0x1355);
    v1361_0V461 = 0x0;
    while (true) {
      if (!(v1358_0V461 < v2530V276dV452)) break;
      if ((v1361_0V461 < v2530V276dV452)) {
        if (!(2*v2547V276dV452 + 32 <= 0x20)) {
          v25deV136cV461 = msg.data[32*v136c_0V461 + v2547V276dV452];
          v25dfV136cV461 = 0x25e7;
          if ((v25deV136cV461 == address(v25deV136cV461))) {
            if ((v1381_1V461 < v2530V2791V452)) {
              if (address(v25deV136cV461).call(MEM[M64 : M64 + 0x0]).value(msg.data[32*v1399_0V461 + v2547V2791V452]).gas((!msg.data[32*v1399_0V461 + v2547V2791V452] * 0x8fc))) {
                v1361_0V461 = v13cb_1V461 + 1;
                GOTO 0x1358;
              }
              RETURNDATACOPY(0x0, 0x0, RETURNDATASIZE);
              throw();
            }
            throw();
          }
          throw();
        }
        throw();
      }
    }
    throw();
    exit();
  }

  function _depositCounts(uint8 varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v28e0V472 = 0x1714;
    require((varg0 == varg0) == 0)
    M32 = 0xa;
    MEM[M64] = uint64(uint64(_depositCounts[varg0]));
    v33d8 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminChangeRelayerThreshold(uint256 varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    adminChangeRelayerThreshold_impl(0x13fe);
    _relayerThreshold = varg0;
    log(M64, 0x0, 0xa20d6b84cd798a24038be305eff8a45ca82ef54a2aa2082005d8e14c0a4746c8, varg0);
    exit();
  }

  function _proposals(uint72 varg0, bytes32 varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    v2899 = 0x28a1;
    require((varg0 == varg0) == 0)
    M32 = 0xe;
    M32 = keccak256(0x0, 0x40);
    MEM[M64] = _proposals[varg1];
    MEM[M64 + 32] = _proposals[varg1][0x1];
    v2c0c = M64 + 128;
    v2c0d = 0x2c15;
    require((uint8(_proposals[varg1][0x4]) < 0x5) == 0)
    MEM[M64 + 64] = uint8(_proposals[varg1][0x4]);
    MEM[M64 + 96] = _proposals[varg1][0x5];
    return(MEM[M64:M64 + 0x80]);
  }

  function _wtokenAddress() public {
    require(!msg.value == 0)
    MEM[M64] = address(address(_wtokenAddress));
    v2b4fV4f84e3 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function isRelayer(address varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v25dfV511 = 0x25e7;
    require((varg0 == varg0) == 0)
    MEM[M64] = 0x52454c415945525f524f4c450000000000000000000000000000000000000000;
    v2b3bV1478V520 = M64 + 12;
    v14781496_0V520 = hasRole_impl(varg0, keccak256(M64, 0xc), 0xa54);
    MEM[M64] = v14781496_0V520;
    v5052b97 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminSetGenericResource(address varg0, bytes32 varg1, address varg2, bytes4 varg3, uint256 varg4, bytes4 varg5) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0xc0) == 0)
    v26eeV53e = 0x26f6;
    require((varg0 == varg0) == 0)
    v2705V53e = 0x270d;
    require((varg2 == varg2) == 0)
    v2715V53e = 0x271d;
    require((varg3 == (varg3 & ~0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) == 0)
    v272cV53e = 0x2734;
    require((varg5 == (varg5 & ~0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) == 0)
    adminChangeRelayerThreshold_impl(0x149f);
    M0 = varg1;
    M32 = 0xc;
    STORAGE[keccak256(0x0, 0x40)] = (varg0 | (~0xffffffffffffffffffffffffffffffffffffffff & STORAGE[keccak256(0x0, 0x40)]));
    MEM[M64] = 0xde319d9900000000000000000000000000000000000000000000000000000000;
    MEM[M64 + 4] = varg1;
    MEM[M64 + 36] = varg2;
    MEM[M64 + 68] = (~0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff & varg3);
    MEM[M64 + 100] = varg4;
    MEM[M64 + 132] = (~0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff & varg5);
    v2bedV54d = M64 + 164;
    require(isContract(varg0) == 0)
    if (varg0.call(MEM[M64 : M64 + 0xa4]).gas(msg.gas)) {
      exit();
    } else {
      RETURNDATACOPY(0x0, 0x0, RETURNDATASIZE);
      throw();
    }
  }

  function paused() public {
    require(!msg.value == 0)
    MEM[M64] = uint8(paused);
    v5522b97 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function renounceAdmin(address varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v25dfV573 = 0x25e7;
    require((varg0 == varg0) == 0)
    adminChangeRelayerThreshold_impl(0x1543);
    grantRole_impl(varg0, 0x0, 0x154e);
    renounceRole_impl(msg.sender, 0x0, 0x1559);
    exit();
  }

  function adminChangeSpecialFee(uint256 varg0, uint8 varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    require((varg1 == varg1) == 0)
    adminPauseTransfers_impl(0x1564);
    M32 = 0xb;
    if (!(_specialFee[varg1] == varg0)) {
      M32 = 0xb;
      _specialFee[varg1] = varg0;
      exit();
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x29;
      MEM[M64 + 68] = 0x43757272656e74207370656369616c2066656520657175616c7320746f207468;
      MEM[M64 + 100] = 0x65206e6577206665650000000000000000000000000000000000000000000000;
      v310a = M64 + 132;
      throw();
    }
  }

  function isOperator(address varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v25dfV5b3 = 0x25e7;
    require((varg0 == varg0) == 0)
    MEM[M64] = 0x4f50455241544f525f524f4c4500000000000000000000000000000000000000;
    v2b23V15acV5c2 = M64 + 13;
    v15ac1496_0V5c2 = hasRole_impl(varg0, keccak256(M64, 0xd), 0xa54);
    MEM[M64] = v15ac1496_0V5c2;
    v5a72b97 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminWithdraw(address varg0, address varg1, address varg2, uint256 varg3) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x80) == 0)
    v265a = 0x2662;
    require((varg0 == varg0) == 0)
    v266a = 0x2672;
    require((varg1 == varg1) == 0)
    v267a = 0x2682;
    require((varg2 == varg2) == 0)
    adminChangeRelayerThreshold_impl(0x15c5);
    MEM[M64] = 0xd9caed1200000000000000000000000000000000000000000000000000000000;
    MEM[M64 + 4] = varg1;
    MEM[M64 + 36] = varg2;
    MEM[M64 + 68] = varg3;
    v2b73V5e2 = M64 + 100;
    require(isContract(varg0) == 0)
    if (varg0.call(MEM[M64 : M64 + 0x64]).gas(msg.gas)) {
      exit();
    } else {
      RETURNDATACOPY(0x0, 0x0, RETURNDATASIZE);
      throw();
    }
  }

  function _hasVotedOnProposal(uint72 varg0, bytes32 varg1, address varg2) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x60) == 0)
    v28c6V5f3 = 0x26b1;
    require((varg0 == varg0) == 0)
    v28af26c0V5f3 = 0x26c8;
    require((varg2 == varg2) == 0)
    M32 = 0xf;
    M32 = keccak256(0x0, 0x40);
    M32 = keccak256(0x0, 0x40);
    MEM[M64] = uint8(_hasVotedOnProposal[varg1]);
    v5e72b97 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function _totalRelayers() public {
    require(!msg.value == 0)
    MEM[M64] = _totalRelayers;
    v2ba0V303607 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminPauseTransfers() public {
    require(!msg.value == 0)
    adminPauseTransfers_impl(0x1664);
    deposit_impl(0x2129);
    paused = (0x1 | (~0xff & paused));
    MEM[M64] = address(msg.sender);
    v2b4fV2129V1664V628 = M64 + 32;
    log(M64, 0x20, 0x62e78cea01bee320cd4e420270b5ea74000d11b0c9f74754ebdbfc544b05a258);
    exit();
  }

  function _resourceIDToHandlerAddress(bytes32 varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    M32 = 0xc;
    MEM[M64] = address(address(_resourceIDToHandlerAddress[varg0]));
    v2b4fV4f8631 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminSetBurnable(address varg0, address varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    v261fV65d = 0x2627;
    require((varg0 == varg0) == 0)
    v262fV65d = 0x2637;
    require((varg1 == varg1) == 0)
    adminChangeRelayerThreshold_impl(0x1691);
    MEM[M64] = 0x7b7ed9900000000000000000000000000000000000000000000000000000000;
    MEM[M64 + 4] = varg1;
    v2b4fV1691V66c = M64 + 36;
    require(isContract(varg0) == 0)
    if (varg0.call(MEM[M64 : M64 + 0x24]).gas(msg.gas)) {
      exit();
    } else {
      RETURNDATACOPY(0x0, 0x0, RETURNDATASIZE);
      throw();
    }
  }

  function getRoleMember(bytes32 varg0, uint256 varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    M32 = 0x1;
    if ((varg1 < roleAdmin[varg0])) {
      require((varg1 < roleAdmin[varg0][0x0]) == 0)
      MEM[M64] = address(STORAGE[varg1 + keccak256(0, 32)]);
      v2b4fV4f8671 = M64 + 32;
      return(MEM[M64:M64 + 0x20]);
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x22;
      MEM[M64 + 68] = 0x456e756d657261626c655365743a20696e646578206f7574206f6620626f756e;
      MEM[M64 + 100] = 0x6473000000000000000000000000000000000000000000000000000000000000;
      v2d52V16f6V68c = M64 + 132;
      throw();
    }
  }

  function adminChangeFee(uint256 varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    adminChangeRelayerThreshold_impl(0x1725);
    if (!(_fee == varg0)) {
      _fee = varg0;
      exit();
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x1f;
      MEM[M64 + 68] = 0x43757272656e742066656520697320657175616c20746f206e65772066656500;
      v3265 = M64 + 100;
      throw();
    }
  }

  function hasRole(bytes32 varg0, address varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    v27feV6bd = 0x2637;
    require((varg1 == varg1) == 0)
    v6b16d0_0 = hasRole_impl(varg1, varg0, 0x525);
    MEM[M64] = v6b16d0_0;
    v6b12b97 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function RELAYER_ROLE() public {
    require(!msg.value == 0)
    MEM[M64] = 0x52454c415945525f524f4c450000000000000000000000000000000000000000;
    v2b3bV176aV6dd = M64 + 12;
    MEM[M64] = keccak256(M64, 0xc);
    v2ba0V3036d1 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminUpdateBridgeAddress(address varg0, address varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    v261fV6f2 = 0x2627;
    require((varg0 == varg0) == 0)
    v262fV6f2 = 0x2637;
    require((varg1 == varg1) == 0)
    adminChangeRelayerThreshold_impl(0x1789);
    MEM[M64] = 0x645c8a4b00000000000000000000000000000000000000000000000000000000;
    MEM[M64 + 4] = varg1;
    v2b4fV1789V701 = M64 + 36;
    require(isContract(varg0) == 0)
    if (varg0.call(MEM[M64 : M64 + 0x24]).gas(msg.gas)) {
      exit();
    } else {
      RETURNDATACOPY(0x0, 0x0, RETURNDATASIZE);
      throw();
    }
  }

  function _totalProposals() public {
    require(!msg.value == 0)
    MEM[M64] = _totalProposals;
    v2ba0V303706 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminRemoveRelayer(address varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v25dfV727 = 0x25e7;
    require((varg0 == varg0) == 0)
    adminChangeRelayerThreshold_impl(0x17c5);
    MEM[M64] = 0x52454c415945525f524f4c450000000000000000000000000000000000000000;
    v2b3bV17c5 = M64 + 12;
    v71bff4_0 = hasRole_impl(varg0, keccak256(M64, 0xc), 0x17d4);
    v71bff4_0 = hasRole_impl(varg0, keccak256(M64, 0xc), 0x17d4)
    if (v71bff4_0) {
      MEM[M64] = 0x52454c415945525f524f4c450000000000000000000000000000000000000000;
      v2b3bV17f0 = M64 + 12;
      revokeRole_impl(varg0, keccak256(M64, 0xc), 0x17ff);
      log(M64, 0x0, 0x10e1f7ce9fd7d1b90a66d13a2ab3cb8dd7f29f3f8d520b143b063ccfbab6906b, varg0);
      _totalRelayers = (~0x0 + _totalRelayers);
      exit();
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x1f;
      MEM[M64 + 68] = 0x6164647220646f65736e277420686176652072656c6179657220726f6c652100;
      v2ea3 = M64 + 100;
      throw();
    }
  }

  function DEFAULT_ADMIN_ROLE() public {
    require(!msg.value == 0)
    MEM[M64] = 0x0;
    v2ba0V30373b = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function getProposal(uint8 varg0, uint64 varg1, bytes32 varg2) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x60) == 0)
    v294aV75c = 0x2953;
    require((varg0 == varg0) == 0)
    v2956V75c = 0x2962;
    require((varg1 == varg1) == 0)
    M64 = M64 + 192;
    MEM[M64] = 0x0;
    MEM[M64 + 32] = 0x0;
    MEM[M64 + 64] = 0x60;
    MEM[M64 + 96] = 0x60;
    MEM[M64 + 128] = 0x0;
    MEM[M64 + 160] = 0x0;
    M32 = 0xe;
    M32 = keccak256(0x0, 0x40);
    M64 = M64 + 192;
    MEM[M64] = _proposals[varg2];
    MEM[M64 + 32] = _proposals[varg2][0x1];
    M64 = (0x20 + (M64 + (0x20 * _proposals[varg2][0x2])));
    MEM[M64] = _proposals[varg2][0x2];
    v18d2_0 = M64 + 32;
    if (_proposals[varg2][0x2]) {
      v18d2_1 = keccak256(0x0, 0x20);
      while (true) {
        MEM[v18d2_0] = address(STORAGE[v18d2_1]);
        v18d2_1 = v18d2_1 + 1;
        v18d2_0 = v18d2_0 + 32;
        if (((v18d2_0 + (0x20 * _proposals[varg2][0x2])) > v18d2_0)) break;
      }
    }
    MEM[M64 + 64] = M64;
    M64 = (M64 + (0x20 + (0x20 * _proposals[varg2][0x3])));
    MEM[M64] = _proposals[varg2][0x3];
    v1934_0 = M64 + 32;
    if (_proposals[varg2][0x3]) {
      v1934_1 = keccak256(0x0, 0x20);
      while (true) {
        MEM[v1934_0] = address(STORAGE[v1934_1]);
        v1934_1 = v1934_1 + 1;
        v1934_0 = v1934_0 + 32;
        if (((v1934_0 + (0x20 * _proposals[varg2][0x3])) > v1934_0)) break;
      }
    }
    MEM[M64 + 96] = M64;
    require(!(uint8(_proposals[varg2][0x4]) > 0x4) == 0)
    require(!(uint8(_proposals[varg2][0x4]) > 0x4) == 0)
    MEM[M64 + 128] = uint8(_proposals[varg2][0x4]);
    MEM[M64 + 160] = _proposals[varg2][0x5];
    MEM[M64] = 0x20;
    MEM[M64 + 32] = MEM[M64];
    MEM[M64 + 64] = MEM[M64 + 32];
    v336a = MEM[M64 + 64];
    MEM[M64 + 96] = 0xc0;
    v3372 = 0x337e;
    v3378 = M64 + 224;
    v2a45_0V334e = 0x0;
    MEM[v3378] = MEM[v336a];
    v2a45_6V334e = v3378 + 32;
    v2a45_1V334e = v336a + 32;
    while (true) {
      if (!(v2a3c_0V334e < MEM[v336a])) break;
      MEM[v2a45_6V334e] = address(MEM[v2a45_1V334e]);
      v2a45_6V334e = v2a45_6V334e + 32;
      v2a45_1V334e = v2a45_1V334e + 32;
      v2a45_0V334e = v2a45_0V334e + 1;
      GOTO 0x2a3c;
    }
    v3383 = MEM[M64 + 96];
    MEM[M64 + 128] = (~0x1f + -M64 + v2a61_6V334e);
    v3392 = 0x339b;
    v2a45_0V337e = 0x0;
    MEM[v2a61_6V334e] = MEM[v3383];
    v2a45_6V337e = v2a61_6V334e + 32;
    v2a45_1V337e = v3383 + 32;
    while (true) {
      if (!(v2a3c_0V337e < MEM[v3383])) break;
      MEM[v2a45_6V337e] = address(MEM[v2a45_1V337e]);
      v2a45_6V337e = v2a45_6V337e + 32;
      v2a45_1V337e = v2a45_1V337e + 32;
      v2a45_0V337e = v2a45_0V337e + 1;
      GOTO 0x2a3c;
    }
    v33a3 = 0x33ab;
    require((MEM[M64 + 128] < 0x5) == 0)
    MEM[M64 + 160] = MEM[M64 + 128];
    MEM[M64 + 192] = MEM[M64 + 160];
    return(MEM[M64:M64 + -M64 + v2a61_6V337e]);
  }

  function _chainID() public {
    require(!msg.value == 0)
    MEM[M64] = uint8(uint8(_chainID));
    v33e6 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function _fee() public {
    require(!msg.value == 0)
    MEM[M64] = _fee;
    v2ba0V30379f = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function _expiry() public {
    require(!msg.value == 0)
    MEM[M64] = _expiry;
    v2ba0V3037b4 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function getRoleMemberCount(bytes32 varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    M0 = varg0;
    M32 = 0x1;
    v19baV7e4 = 0xa54;
    MEM[M64] = STORAGE[keccak256(0x0, 0x40)];
    v2ba0V3037c9 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminSetResource(address varg0, bytes32 varg1, address varg2) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x60) == 0)
    v26a9V7f5 = 0x26b1;
    require((varg0 == varg0) == 0)
    v269226c0V7f5 = 0x26c8;
    require((varg2 == varg2) == 0)
    adminChangeRelayerThreshold_impl(0x19ca);
    M0 = varg1;
    M32 = 0xc;
    STORAGE[keccak256(0x0, 0x40)] = (varg0 | (~0xffffffffffffffffffffffffffffffffffffffff & STORAGE[keccak256(0x0, 0x40)]));
    MEM[M64] = 0xb8fa373600000000000000000000000000000000000000000000000000000000;
    MEM[M64 + 4] = varg1;
    MEM[M64 + 36] = varg2;
    v2bb7V804 = M64 + 68;
    require(isContract(varg0) == 0)
    if (varg0.call(MEM[M64 : M64 + 0x44]).gas(msg.gas)) {
      exit();
    } else {
      RETURNDATACOPY(0x0, 0x0, RETURNDATASIZE);
      throw();
    }
  }

  function adminAddRelayer(address varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v25dfV815 = 0x25e7;
    require((varg0 == varg0) == 0)
    adminChangeRelayerThreshold_impl(0x1a5b);
    MEM[M64] = 0x52454c415945525f524f4c450000000000000000000000000000000000000000;
    v2b3bV1a5b = M64 + 12;
    v809ff4_0 = hasRole_impl(varg0, keccak256(M64, 0xc), 0x1a6a);
    if (!v809ff4_0) {
      MEM[M64] = 0x52454c415945525f524f4c450000000000000000000000000000000000000000;
      v2b3bV1a87 = M64 + 12;
      grantRole_impl(varg0, keccak256(M64, 0xc), 0x1aa4);
      log(M64, 0x0, 0x3580ee9f53a62b7cb409a2cb56f9be87747dd15017afc5cef6eef321e4fb2c5, varg0);
      _totalRelayers = _totalRelayers + 1;
      exit();
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x1e;
      MEM[M64 + 68] = 0x6164647220616c7265616479206861732072656c6179657220726f6c65210000;
      v30c1 = M64 + 100;
      throw();
    }
  }

  function revokeRole(bytes32 varg0, address varg1) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x40) == 0)
    v27feV835 = 0x2637;
    require((varg1 == varg1) == 0)
    revokeRole_impl(varg1, varg0, 0x2e1);
    exit();
  }

  function _relayerThreshold() public {
    require(!msg.value == 0)
    MEM[M64] = _relayerThreshold;
    v2ba0V303849 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function depositETH() public {
  }

  function OPERATOR_ROLE() public {
    require(!msg.value == 0)
    MEM[M64] = 0x4f50455241544f525f524f4c4500000000000000000000000000000000000000;
    v2b23V1e33V87d = M64 + 13;
    MEM[M64] = keccak256(M64, 0xd);
    v2ba0V303871 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function _totalOperators() public {
    require(!msg.value == 0)
    MEM[M64] = _totalOperators;
    v2ba0V303886 = M64 + 32;
    return(MEM[M64:M64 + 0x20]);
  }

  function adminAddOperator(address varg0) public {
    require(!msg.value == 0)
    require(!((msg.data.length() - 0x4) <= 0x20) == 0)
    v25dfV8a7 = 0x25e7;
    require((varg0 == varg0) == 0)
    adminChangeRelayerThreshold_impl(0x1e4d);
    MEM[M64] = 0x4f50455241544f525f524f4c4500000000000000000000000000000000000000;
    v2b23V1e4d = M64 + 13;
    v89bff4_0 = hasRole_impl(varg0, keccak256(M64, 0xd), 0x1e5c);
    if (!v89bff4_0) {
      MEM[M64] = 0x4f50455241544f525f524f4c4500000000000000000000000000000000000000;
      v2b23V1e79 = M64 + 13;
      grantRole_impl(varg0, keccak256(M64, 0xd), 0x1e88);
      log(M64, 0x0, 0xac6fa858e9350a46cec16539926e0fde25b7629f84b5a72bffaae4df888ae86d, varg0);
      _totalOperators = _totalOperators + 1;
      exit();
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x1f;
      MEM[M64 + 68] = 0x6164647220616c726561647920686173206f70657261746f7220726f6c652100;
      v3141 = M64 + 100;
      throw();
    }
  }

  function adminUnpauseTransfers() public {
    require(!msg.value == 0)
    adminPauseTransfers_impl(0x1ed0);
    v219dV1ed0V8c7 = 0x21a4;
    if (uint8(paused)) {
      paused = (~0xff & paused);
      v21b2V1ed0V8c7 = 0x5db9ee0a495bf2e6ff9c91a7834c1ba4fdd244a5e8aa4e537bd38aeae4b073aa;
      MEM[M64] = address(msg.sender);
      v2b4fV21a4V1ed0V8c7 = M64 + 32;
      log(M64, 0x20, v21b2V1ed0V8c7);
      exit();
    } else {
      MEM[M64] = 0x8c379a000000000000000000000000000000000000000000000000000000000;
      MEM[M64 + 4] = 0x20;
      MEM[M64 + 36] = 0x14;
      MEM[M64 + 68] = 0x5061757361626c653a206e6f7420706175736564000000000000000000000000;
      v2e6cV219cV1ed0V8c7 = M64 + 100;
      throw();
    }
  }

  function grantRole_impl(uint256 vf88arg0, uint256 vf88arg1, uint256 vf88arg2) private {
    M32 = 0x1;
    vf9a = roleAdmin[vf88arg1][0x2];
    vf886d0_0 = hasRole_impl(msg.sender, vf9a, 0xfa6);
  }

}