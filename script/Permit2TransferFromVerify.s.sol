// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "./interfaces/permit2/ISignatureTransfer.sol";
import "./utils/Signature.sol";
import "./Env.s.sol";

contract USDCTransferAuthVerify is Script {
    using stdJson for string;

    ISignatureTransfer permit2;

    struct TokenPermissions {
        uint256 amount;
        address token;
    }

    struct PermitTransferFrom {
        uint256 deadline;
        uint256 nonce;
        TokenPermissions permitted;
        address spender;
    }

    function setUp() public {
        permit2 = ISignatureTransfer(permit2_addr);
    }

    function readPermitTransferFromParams(string memory _json_path) internal view returns (PermitTransferFrom memory) {
        string memory json = vm.readFile(_json_path);
        bytes memory raw_params = json.parseRaw(".message");
        return abi.decode(raw_params, (PermitTransferFrom));
    }

    function run() public {
        SignatureHelper.sigVRS memory sig = SignatureHelper.signatureStringToStruct(signature);

        PermitTransferFrom memory interim_params = readPermitTransferFromParams(typed_data_file);
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({
                token: interim_params.permitted.token,
                amount: interim_params.permitted.amount
            }),
            nonce: interim_params.nonce,
            deadline: interim_params.deadline
        });

        ISignatureTransfer.SignatureTransferDetails memory transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: recipient,
            requestedAmount: value
        });

        vm.deal(interim_params.spender, 1 ether);
        vm.startPrank(interim_params.spender);
        permit2.permitTransferFrom(permit, transferDetails, sender, SignatureHelper.signatureStringToBytes(signature));
        vm.stopPrank();

        console.log("****** permitTransferFrom signature ******");
        SignatureHelper.outputSignature(sig);
    }
}
