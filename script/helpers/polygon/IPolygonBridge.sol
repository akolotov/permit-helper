// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface IPolygonBridge {
    function ERC712_VERSION() external view returns (string memory);

    function depositFor(address user, address rootToken, bytes calldata depositData) external;

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    )
        external
        returns (bytes memory);

    function getNonce(address user) external returns (uint256);
    function getChainId() external view returns (uint256);
}
