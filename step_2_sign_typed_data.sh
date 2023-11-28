#!/bin/bash

set -e

source .env

WORKING_TYPED_DATA_FILE=`dirname ${TYPED_DATA_FILE}`/working_`basename ${TYPED_DATA_FILE}`
sed -e 's#"value": \([0-9]\{1,\}\)#"value": "\1"#' \
    -e 's#"amount": \([0-9]\{1,\}\)#"amount": "\1"#' \
    ${TYPED_DATA_FILE} > ${WORKING_TYPED_DATA_FILE}

cast wallet sign \
    ${PRIV_KEY_SOURCE} \
    --data --from-file ${WORKING_TYPED_DATA_FILE}

rm ${WORKING_TYPED_DATA_FILE}
