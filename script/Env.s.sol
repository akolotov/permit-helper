// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";

string constant typed_data_file_template = "./templates/TransferWithAuthorization.json";
string constant typed_data_file = "./out/TransferWithAuthorization.json";

address constant usdc_addr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

address constant cow_addr = 0xDEf1CA1fb7FBcDC777520aa7f396b4E015F497aB;

address constant bridged_token_addr = 0x177127622c4A00F3d409B75571e12cB3c8973d3c;

address constant sender = 0x000000000000000000000000000000000000dEaD;
address constant recipient = 0x000000000000000000000000000000000000dEaD;
uint256 constant value = 10_000_000;
uint256 constant deadline_threshold = 1 days;

string constant signature = "0x...";

address constant actor = 0x000000000000000000000000000000000000dEaD;
address constant polygon_bridge = 0xA0c68C638235ee32657e8f720a23ceC1bFc77C77;
string constant bridge_metatx_signature = "0x...";
