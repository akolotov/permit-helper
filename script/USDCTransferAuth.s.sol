// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "./interfaces/IUSDCAuth.sol";
import "./Env.s.sol";

contract USDCTransferAuth is Script {
    uint256 validAfter = block.timestamp;
    uint256 validBefore = validAfter + deadline_threshold;

    using stdJson for string;

    IUSDCAuth token;

    function setUp() public {
        token = IUSDCAuth(usdc_addr);
    }

    function get_auth_nonce(bytes32 _salt) internal view returns (bytes32) {
        return keccak256(abi.encode(block.number, _salt));
    }

    function run() public {
        bytes32 nonce = get_auth_nonce(keccak256(abi.encode(sender, recipient, value, validAfter, validBefore)));

        string memory domain_obj = "_domain";
        string memory domain = vm.serializeAddress(domain_obj, "verifyingContract", address(token));
        domain = vm.serializeUint(domain_obj, "chainId", block.chainid);
        domain = vm.serializeString(domain_obj, "name", token.name());
        domain = vm.serializeString(domain_obj, "version", string.concat("\"", token.version(), "\""));

        string memory message_obj = "_message";
        string memory message = vm.serializeAddress(message_obj, "from", sender);
        message = vm.serializeAddress(message_obj, "to", recipient);
        message = vm.serializeUint(message_obj, "value", value);
        message = vm.serializeUint(message_obj, "validAfter", validAfter);
        message = vm.serializeUint(message_obj, "validBefore", validBefore);
        message = vm.serializeBytes32(message_obj, "nonce", nonce);

        string memory template_json = vm.readFile(typed_data_file_template);
        string memory json = "_root";
        string memory out = vm.serializeJson(json, template_json);
        out = vm.serializeString(json, "domain", domain);
        out = vm.serializeString(json, "message", message);
        vm.writeJson(out, "./out/TransferWithAuthorization.json");

        console.log("From:", sender);
        console.log("To:", recipient);
        console.log("Value:", value);
        console.log("Valid after:", validAfter);
        console.log("Valid before:", validBefore);
        console.log("Nonce:", vm.toString(nonce));
    }
}
