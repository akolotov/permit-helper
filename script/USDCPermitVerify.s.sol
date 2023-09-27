// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "./interfaces/IUSDCAuth.sol";
import "./helpers/polygon/USDCMetaTransactionVerifier.sol";
import "./utils/Signature.sol";
import "./Env.s.sol";

contract USDCTransferAuthVerify is Script {
    using stdJson for string;

    IUSDCAuth token;

    function setUp() public {
        token = IUSDCAuth(usdc_addr);
    }

    struct permitParams {
        uint256 deadline;
        uint256 nonce;
        address owner;
        address spender;
        uint256 value;
    }

    function readPermitParams(string memory _json_path) internal view returns (permitParams memory) {
        string memory json = vm.readFile(_json_path);
        bytes memory raw_params = json.parseRaw(".message");
        return abi.decode(raw_params, (permitParams));
    }

    function permitVeirfier() internal {
        USDCMetaTransactionVerifier.verify();
    }

    function run() public {
        SignatureHelper.sigVRS memory sig = SignatureHelper.signatureStringToStruct(signature);

        permitParams memory params = readPermitParams(typed_data_file);

        vm.deal(actor, 1 ether);
        vm.startPrank(actor);
        token.permit(params.owner, params.spender, params.value, params.deadline, sig.v, sig.r, sig.s);
        permitVeirfier();
        vm.stopPrank();

        console.log("****** Permit signature ******");
        SignatureHelper.outputSignature(sig);
    }
}
