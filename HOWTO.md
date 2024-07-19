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
