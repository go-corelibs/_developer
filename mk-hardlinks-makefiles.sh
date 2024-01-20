#!/bin/bash
SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CORELIBS_PATH="$(dirname "${SCRIPT_PATH}")"
MAKEFILES_PATH="${SCRIPT_PATH}/common-makefiles"

#CMD=echo

link_makefile () {
    sel=$(basename "${1}")
    src="${MAKEFILES_PATH}/${sel}"
    if [ ! -f "${src}" ]
    then
        sel="Golang.${sel}.mk"
        src="${MAKEFILES_PATH}/${sel}"
        [ ! -f "${src}" ] && return 1
    fi
    ${CMD} rm -f "${sel}"
    ${CMD} ln -v "${src}" "${sel}"
    return 0
}

link_makefiles () {
    while [ $# -gt 0 ]
    do
        for f in $(ls -1 ${1} | sort -V)
        do
            link_makefile "${f}"
        done
        shift
    done
}

if [ $# -eq 0 ]
then
    echo "usage: $(basename $0) <name> [name...]"
    echo "       $(basename $0) <all|debian|golang>"
    echo
    echo "names:"
    for name in $(ls -1 ${MAKEFILES_PATH} | sort -V)
    do
        echo "  ${name}"
    done
    exit
fi

case "${1}" in
    "all"|"All"|"ALL")
        link_makefiles ${MAKEFILES_PATH}
        exit
        ;;
    "debian"|"Debian")
        link_makefiles ${MAKEFILES_PATH}/Debian.*mk
        exit
        ;;
    "golang"|"Golang")
        link_makefiles ${MAKEFILES_PATH}/Golang.*mk
        exit
        ;;
esac

for mf in "${@}"
do
    link_makefile "${mf}"
    [ $? -ne 0 ] && echo "# not found: ${mf}"
done
