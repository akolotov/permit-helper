// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../../../lib/forge-std/src/Script.sol";
import "../../interfaces/IUSDCAuth.sol";
import "../../Env.s.sol";
import "../../utils/Signature.sol";
import "./IPolygonBridge.sol";
import "./MetaTransactionHelper.sol";

string constant metatx_typed_data_file_template = "./templates/MetaTransaction.json";
string constant metatx_typed_data_file = "./out/MetaTransaction.json";

contract USDCMetaTransaction is Script {
    using stdJson for string;

    struct permitParams {
        uint256 deadline;
        uint256 nonce;
        address owner;
        address spender;
        uint256 value;
    }

    function setUp() public {}

    function readPermitParams(string memory _json_path) internal view returns (permitParams memory) {
        string memory json = vm.readFile(_json_path);
        bytes memory raw_params = json.parseRaw(".message");
        return abi.decode(raw_params, (permitParams));
    }

    function run() public {
        IPolygonBridge bridge = IPolygonBridge(polygon_bridge);

        MetaTransactionHelper.EIP712Domain memory domain_data = MetaTransactionHelper.getDomainSeparatorData(bridge);

        string memory domain_obj = "_domain";
        string memory domain = vm.serializeAddress(domain_obj, "verifyingContract", domain_data.verifyingContract);
        domain = vm.serializeBytes32(domain_obj, "salt", domain_data.salt);
        domain = vm.serializeString(domain_obj, "name", domain_data.name);
        domain = vm.serializeString(domain_obj, "version", string.concat("\"", domain_data.version, "\""));

        permitParams memory params = readPermitParams(typed_data_file);
        bytes memory functionSignature =
            abi.encodeCall(bridge.depositFor, (params.owner, usdc_addr, abi.encode(params.value)));

        uint256 nonce = bridge.getNonce(params.owner);

        string memory message_obj = "_message";
        string memory message = vm.serializeAddress(message_obj, "from", params.owner);
        message = vm.serializeUint(message_obj, "nonce", nonce);
        message = vm.serializeBytes(message_obj, "functionSignature", functionSignature);

        string memory template_json = vm.readFile(metatx_typed_data_file_template);
        string memory json = "_root";
        string memory out = vm.serializeJson(json, template_json);
        out = vm.serializeString(json, "domain", domain);
        out = vm.serializeString(json, "message", message);
        vm.writeJson(out, metatx_typed_data_file);

        MetaTransactionHelper.outputSignedData(params.owner, functionSignature);
    }
}
