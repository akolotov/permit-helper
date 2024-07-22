// SPDX-License-Identifier: UNLICENSED

import "../../lib/forge-std/src/Script.sol";

pragma solidity ^0.8.13;

library SignatureHelper {
    // from forge-std/src/Base.sol
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
    VmSafe internal constant vm = VmSafe(VM_ADDRESS);

    struct sigVRS {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function signatureStringToBytes(string memory _sig) public pure returns (bytes memory) {
        return vm.parseBytes(_sig);
    }

    function signatureStringToStruct(string memory _sig) public pure returns (sigVRS memory) {
        bytes memory sig = signatureStringToBytes(_sig);

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := and(mload(add(sig, 65)), 255)
        }

        return sigVRS({v: v, r: r, s: s});
    }

    function signatureVRSToStruct(uint8 _v, bytes32 _r, bytes32 _s) public pure returns (sigVRS memory) {
        return sigVRS({v: _v, r: _r, s: _s});
    }

    function outputSignature(sigVRS memory _sig) internal pure {
        console.log("Sig -> v:", _sig.v);
        console.log("Sig -> r:", vm.toString(_sig.r));
        console.log("Sig -> s:", vm.toString(_sig.s));
    }
}
