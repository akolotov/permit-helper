// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "./interfaces/IGCBridgedToken.sol";
import "./Env.s.sol";

contract GnosisBridgedTokensPermit is Script {
    uint256 deadline = block.timestamp + deadline_threshold;

    using stdJson for string;

    IGCBridgedToken token;

    function setUp() public {
        token = IGCBridgedToken(bridged_token_addr);
    }

    function run() public {
        uint256 nonce = token.nonces(sender);

        string memory domain_obj = "_domain";
        string memory domain = vm.serializeAddress(domain_obj, "verifyingContract", address(token));
        domain = vm.serializeUint(domain_obj, "chainId", block.chainid);
        domain = vm.serializeString(domain_obj, "name", token.name());
        domain = vm.serializeString(domain_obj, "version", string.concat("\"", token.version(), "\""));

        string memory message_obj = "_message";
        string memory message = vm.serializeAddress(message_obj, "owner", sender);
        message = vm.serializeAddress(message_obj, "spender", recipient);
        message = vm.serializeUint(message_obj, "value", value);
        message = vm.serializeUint(message_obj, "nonce", nonce);
        message = vm.serializeUint(message_obj, "deadline", deadline);

        string memory template_json = vm.readFile(typed_data_file_template);
        string memory json = "_root";
        string memory out = vm.serializeJson(json, template_json);
        out = vm.serializeString(json, "domain", domain);
        out = vm.serializeString(json, "message", message);
        vm.writeJson(out, typed_data_file);

        console.log("Owner:", sender);
        console.log("Spender:", recipient);
        console.log("Value:", value);
        console.log("Deadline:", vm.toString(deadline));
    }
}
