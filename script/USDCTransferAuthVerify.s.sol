// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "./interfaces/IUSDCAuth.sol";
import "./Env.s.sol";
import "./utils/Signature.sol";

contract USDCTransferAuthVerify is Script {
    using stdJson for string;

    IUSDCAuth token;

    function setUp() public {
        token = IUSDCAuth(usdc_addr);
    }

    struct transferWithAuthParams {
        address from;
        bytes32 nonce;
        address to;
        uint256 validAfter;
        uint256 validBefore;
        uint256 value;
    }

    function readTransferParams(string memory _json_path) internal view returns (transferWithAuthParams memory) {
        string memory json = vm.readFile(_json_path);
        bytes memory raw_params = json.parseRaw(".message");
        return abi.decode(raw_params, (transferWithAuthParams));
    }

    function run() public {
        SignatureHelper.sigVRS memory sig = SignatureHelper.signatureStringToStruct(signature);

        transferWithAuthParams memory params = readTransferParams(typed_data_file);

        vm.deal(params.to, 1 ether);
        vm.startPrank(params.to);
        token.transferWithAuthorization(
            params.from, params.to, params.value, params.validAfter, params.validBefore, params.nonce, sig.v, sig.r, sig.s
        );
        vm.stopPrank();

        console.log("****** transferWithAuthorization signature ******");
        SignatureHelper.outputSignature(sig);
    }
}
