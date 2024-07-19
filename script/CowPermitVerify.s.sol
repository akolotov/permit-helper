// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import {StdCheats} from "../lib/forge-std/src/StdCheats.sol";
import "./interfaces/ICowToken.sol";
import "./utils/Signature.sol";
import "./Env.s.sol";

contract CowPermitPermitVerify is Script,StdCheats {
    using stdJson for string;

    ICowToken token;

    function setUp() public {
        token = ICowToken(cow_addr);
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
        deal(address(cow_addr), sender, value);
        token.transferFrom(sender, recipient, value);
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
