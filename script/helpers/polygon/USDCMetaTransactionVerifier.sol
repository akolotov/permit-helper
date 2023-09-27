// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../../Env.s.sol";
import "../../utils/Signature.sol";
import "./IPolygonBridge.sol";
import "./MetaTransactionHelper.sol";

library USDCMetaTransactionVerifier {
    function verify() internal {
        IPolygonBridge bridge = IPolygonBridge(polygon_bridge);
        bytes memory functionSignature = abi.encodeCall(bridge.depositFor, (sender, usdc_addr, abi.encode(value)));

        SignatureHelper.sigVRS memory sig;
        if (keccak256(bytes(bridge_metatx_signature)) == keccak256("0x...")) {
            sig = MetaTransactionHelper.signMetaTransaction(bridge, sender, functionSignature);
        } else {
            sig = SignatureHelper.signatureStringToStruct(bridge_metatx_signature);
        }

        console.log("****** Meta Transaction signature ******");
        SignatureHelper.outputSignature(sig);

        bridge.executeMetaTransaction(sender, functionSignature, sig.r, sig.s, sig.v);
    }
}
