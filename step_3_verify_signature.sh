#!/bin/bash

set -e

source .env

forge script -vvv \
  --rpc-url ${RPC_URL} \
  $@
