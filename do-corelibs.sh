#!/bin/bash
SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CORELIBS_PATH="$(dirname "${SCRIPT_PATH}")"
MAKEFILE_PATH="${SCRIPT_PATH}/template/CoreLibs.mk"

DO_COMMAND="${@}"

pushd "${CORELIBS_PATH}" > /dev/null
for pkg in $(ls -1 -d * | grep -v "_developer")
do
    pushd "${pkg}" > /dev/null
    echo "##: ${pkg} - ${DO_COMMAND}"
    ${DO_COMMAND}
    popd > /dev/null
done
popd > /dev/null
