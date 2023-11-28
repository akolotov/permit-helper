// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "./interfaces/permit2/ISignatureTransfer.sol";
import "./Env.s.sol";

contract Permit2TransferFrom is Script {
    uint256 deadline = block.timestamp + deadline_threshold;

    using stdJson for string;

    ISignatureTransfer permit2;

    function setUp() public {
        permit2 = ISignatureTransfer(permit2_addr);
    }

    function get_auth_nonce(bytes32 _salt) internal view returns (uint256) {
        return uint256(keccak256(abi.encode(block.number, _salt)));
    }

    function run() public {
        uint256 nonce = get_auth_nonce(keccak256(abi.encode(permit2_token_addr, value, recipient, deadline)));

        string memory domain_obj = "_domain";
        string memory domain = vm.serializeAddress(domain_obj, "verifyingContract", address(permit2));
        domain = vm.serializeUint(domain_obj, "chainId", block.chainid);
        domain = vm.serializeString(domain_obj, "name", "Permit2");

        string memory permitted_obj = "_permitted";
        string memory permitted = vm.serializeAddress(permitted_obj, "token", address(permit2_token_addr));
        permitted = vm.serializeUint(permitted_obj, "amount", value);

        string memory message_obj = "_message";
        string memory message = vm.serializeString(message_obj, "permitted", permitted);
        message = vm.serializeAddress(message_obj, "spender", recipient);
        message = vm.serializeUint(message_obj, "nonce", nonce);
        message = vm.serializeUint(message_obj, "deadline", deadline);

        string memory template_json = vm.readFile(typed_data_file_template);
        string memory json = "_root";
        string memory out = vm.serializeJson(json, template_json);
        out = vm.serializeString(json, "domain", domain);
        out = vm.serializeString(json, "message", message);
        vm.writeJson(out, typed_data_file);

        console.log("Token:", permit2_token_addr);
        console.log("Amount:", value);
        console.log("Spender:", recipient);
        console.log("Nonce:", nonce);
        console.log("Deadline:", deadline);
    }
}
