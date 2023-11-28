## Permit Helper

This set of Foundry scripts helps to generate data for permit-family methods to transfer tokens gasless.

Currently supported tokens:
- Any token approved to be operated by Permit2, method `permitTransferFrom`, scripts `script/Permit2TransferFrom.s.sol` and `script/Permit2TransferFromVerify.s.sol`
- USDC, method `transferWithAuthorization`, scripts `script/USDCTransferAuth.s.sol` and `script/USDCTransferAuthVerify.s.sol`
- USDC, method `Permit`, scripts `script/USDCPermit.s.sol` and `script/USDCPermitVerify.s.sol`. The verification process uses Polygon bridge meta-transaction simulation which requires its own signature. The plan is to produce the signature by preparing typed data through `script/helpers/polygon/USDCMetaTransaction.s.sol` but due to [a bug in Foundry](https://github.com/foundry-rs/foundry/issues/5912) a workaround is used -- the privkey of the meta-transaction signer must be provided in `SIGNER` of `.env`
- Tokens bridged through Gnosis OmniBridge, method `Permit`, scripts `script/GnosisBridgedTokensPermit.s.sol` and `script/GnosisBridgedTokensPermitVerify.s.sol`
- COW token in Mainnet (example of token with the DOMAIN version hardcoded), method `Permit`, scripts `script/CowPermit.s.sol` and `script/CowPermitVerify.s.sol`  

### Steps to get data

1. Copy `.env.example` to `.env`. Modify `PRIV_KEY_SOURCE` if another source of the private key will be used (use `cast wallet sign --help` for reference)
2. Modify `./script/Env.s.sol` to set correct `sender`, `recipient` and `value` (in Wei). If it is required to have an extended threshold, `deadline_threshold` can be adjusted as well.
3. Run to produce typed data JSON:
   ```
   ./step_1_generate_typed_data.sh <path/to/script>
   ```
4. Run to sign the typed data:
   ```
   ./step_2_sign_typed_data.sh
   ```
5. Copy the signature from the previous step to `signature` of `./script/Env.s.sol`
6. Run the final step to verify the transfer and get the signature in the form that can be used in Etherscan/Gnosis Safe/etc:
   ```
   ./step_3_verify_signature.sh <path/to/verification script>
   ```

### Examples for `PRIV_KEY_SOURCE`

For entering a privkey interactively:
```
PRIV_KEY_SOURCE='--interactive'
```

For using the Ledger device
```
PRIV_KEY_SOURCE='--ledger  --mnemonic-index N'
```
where N is the index of an account. The very first account has the index `0`.