#!/bin/bash
SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CORELIBS_PATH="$(dirname "${SCRIPT_PATH}")"
MAKEFILES_PATH="${SCRIPT_PATH}/common-makefiles"

link_makefile () {
    sel=$(basename "${1}")
    src="${MAKEFILES_PATH}/${sel}"
    if [ -f "${src}" ]
    then
        rm -f "${sel}"
        ln -v "${src}" "${sel}"
        return 0
    fi
    return 1
}

if [ "${1}" == "Golang" ]
then
    for f in $(ls -1 ${MAKEFILES_PATH} | sort -V)
    do
        link_makefile "${f}"
    done
    exit
fi

for mf in "${@}"
do
    link_makefile "${mf}"
    if [ $? -ne 0 ]
    then
        link_makefile "Golang.${mf}.mk"
        if [ $? -ne 0 ]
        then
            echo "# Makefile not found: ${mf}"
        fi
    fi
done
