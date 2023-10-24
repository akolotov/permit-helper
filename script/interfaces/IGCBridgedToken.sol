// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface IGCBridgedToken {
    function DOMAIN_SEPARATOR() external returns (bytes32);

    function PERMIT_TYPEHASH() external returns (bytes32);

    function name() external returns (string memory);
    function version() external returns (string memory);

    function nonces(address owner) external returns (uint256);

    /** @dev Allows to spend holder's unlimited amount by the specified spender according to EIP2612.
     * The function can be called by anyone, but requires having allowance parameters
     * signed by the holder according to EIP712.
     * @param _holder The holder's address.
     * @param _spender The spender's address.
     * @param _value Allowance value to set as a result of the call.
     * @param _deadline The deadline timestamp to call the permit function. Must be a timestamp in the future.
     * Note that timestamps are not precise, malicious miner/validator can manipulate them to some extend.
     * Assume that there can be a 900 seconds time delta between the desired timestamp and the actual expiration.
     * @param _v A final byte of signature (ECDSA component).
     * @param _r The first 32 bytes of signature (ECDSA component).
     * @param _s The second 32 bytes of signature (ECDSA component).
     */
    function permit(
        address _holder,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external;

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}
