### Permit for Gnosis Chain Bridged tokens (e.g. COW)

#### `.env`

- `RPC_URL=https://rpc.gnosischain.com`
- `TYPED_DATA_FILE=./out/Permit.json`

#### `Env.s.sol`

- Set `sender`, `recipient` and `value`
- Set `actor` as `sender`

1. `./step_1_generate_typed_data.sh script/GnosisBridgedTokensPermit.s.sol`
2. `./step_2_sign_typed_data.sh`
3. Paste the signature to `signature` in `Env.s.sol`
4. `./step_3_verify_signature.sh script/GnosisBridgedTokensPermitVerify.s.sol`

### Permit for COW on Mainnet

#### `.env`

- `RPC_URL=https://rpc.ankr.com/eth`
- `TYPED_DATA_FILE=./out/Permit.json`

#### `Env.s.sol`

- Set `sender`, `recipient` and `value`
- Set `actor` as `sender`

1. `./step_1_generate_typed_data.sh script/CowPermit.s.sol`
2. `./step_2_sign_typed_data.sh`
3. Paste the signature to `signature` in `Env.s.sol`
4. `./step_3_verify_signature.sh script/CowPermitVerify.s.sol`

### Transfer USDC with authentication

#### `.env`

- `RPC_URL=https://rpc.ankr.com/eth`
- `TYPED_DATA_FILE=./out/TransferWithAuthorization.json`

#### `Env.s.sol`

- Update `typed_data_file_template` and `typed_data_file`
- Set `sender`, `recipient` and `value`
- Make sure that sender has the corresponding amount of USDC

1. `./step_1_generate_typed_data.sh script/USDCTransferAuth.s.sol` 
2. `./step_2_sign_typed_data.sh`
3. Paste the signature to `signature` in `Env.s.sol`
4. `./step_3_verify_signature.sh script/USDCTransferAuthVerify.s.sol`
