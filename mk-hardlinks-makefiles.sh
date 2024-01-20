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

if [ $# -eq 0 ]
then
    echo "usage: $(basename $0) <name> [name...]"
    echo "       $(basename $0) all"
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
        for f in $(ls -1 ${MAKEFILES_PATH} | sort -V)
        do
            link_makefile "${f}"
        done
        exit
        ;;
esac

for mf in "${@}"
do
    #: check exact name first
    link_makefile "${mf}"
    if [ $? -ne 0 ]
    then
        #: check Golang.{name}.mk next
        link_makefile "Golang.${mf}.mk"
        if [ $? -ne 0 ]
        then
            #: not a thing
            echo "# not found: ${mf}"
        fi
    fi
done
