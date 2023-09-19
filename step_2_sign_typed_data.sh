#!/bin/bash

set -e

source .env

cast wallet sign \
    ${PRIV_KEY_SOURCE} \
    --data --from-file ${TYPED_DATA_FILE}
