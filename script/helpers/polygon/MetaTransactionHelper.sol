// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../../../lib/forge-std/src/Script.sol";
import "../../utils/Signature.sol";
import "./IPolygonBridge.sol";

library MetaTransactionHelper {
    // from forge-std/src/Base.sol
    address private constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
    VmSafe private constant vm = VmSafe(VM_ADDRESS);

    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256(bytes("EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"));

    bytes32 private constant META_TRANSACTION_TYPEHASH =
        keccak256(bytes("MetaTransaction(uint256 nonce,address from,bytes functionSignature)"));

    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 salt;
    }

    /*
     * Meta transaction structure.
     * No point of including value field here as if user is doing value transfer then he has the funds to pay for gas
     * He should call the desired function directly in that case.
     */
    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function getDomainSeparatorData(IPolygonBridge _bridge) public view returns (EIP712Domain memory) {
        return EIP712Domain({
            name: "RootChainManager",
            version: _bridge.ERC712_VERSION(),
            verifyingContract: address(_bridge),
            salt: bytes32(_bridge.getChainId())
        });
    }

    /**
     * Accept message hash and returns hash message in EIP712 compatible form
     * So that it can be used to recover signer from signature signed using EIP712 formatted data
     * https://eips.ethereum.org/EIPS/eip-712
     * "\\x19" makes the encoding deterministic
     * "\\x01" is the version byte to make it compatible to EIP-191
     */
    function toTypedMessageHash(EIP712Domain memory domain, bytes32 messageHash) internal pure returns (bytes32) {
        bytes32 domainSeperator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(domain.name)),
                keccak256(bytes(domain.version)),
                domain.verifyingContract,
                domain.salt
            )
        );

        return keccak256(abi.encodePacked("\x19\x01", domainSeperator, messageHash));
    }

    function hashMetaTransaction(MetaTransaction memory metaTx) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(META_TRANSACTION_TYPEHASH, metaTx.nonce, metaTx.from, keccak256(metaTx.functionSignature))
        );
    }

    function metaTransactionAsMessage(
        EIP712Domain memory domain,
        uint256 nonce,
        address userAddress,
        bytes memory functionSignature
    )
        public
        pure
        returns (bytes32)
    {
        MetaTransaction memory metaTx =
            MetaTransaction({nonce: nonce, from: userAddress, functionSignature: functionSignature});

        return toTypedMessageHash(domain, hashMetaTransaction(metaTx));
    }

    function outputSignedData(address _from, bytes memory _functionSignature) internal view {
        console.log("****** Meta Transaction data ******");
        console.log("From:", _from);
        console.log("FunctionSignature:", vm.toString(_functionSignature));
    }

    function signMetaTransaction(
        IPolygonBridge _bridge,
        address _from,
        bytes memory _functionSignature
    )
        public
        returns (SignatureHelper.sigVRS memory)
    {
        EIP712Domain memory domain = getDomainSeparatorData(_bridge);

        uint256 nonce = _bridge.getNonce(_from);

        bytes32 digest = metaTransactionAsMessage(domain, nonce, _from, _functionSignature);
        bytes32 pk = vm.envBytes32("SIGNER");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(pk), digest);

        outputSignedData(_from, _functionSignature);

        return SignatureHelper.signatureVRSToStruct(v, r, s);
    }
}
