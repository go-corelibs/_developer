#!/bin/bash
SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CORELIBS_PATH="$(dirname "${SCRIPT_PATH}")"
RPL_BIN=$(which rpl.linux.arm64)

if [ $# -ne 3 ]
then
    echo "usage: $(basename $0) <tmplpkgname> <tmplpkgsummary> <tmplpkgdescription>"
    exit 1
fi

NAME="$(echo "${1}" | tr '[:upper:]' '[:lower:]')"
DIRNAME="${NAME}"
if echo "${DIRNAME}" | grep -q -- -
then
    NAME=$(echo "${DIRNAME}" | perl -pe '@p=split(m/-/,$_);$_=pop(@p);')
fi
SUMMARY="${2}"
DESCRIPTION="${3}"

DST="${CORELIBS_PATH}/${DIRNAME}"
KEY="$(echo ${NAME} | tr '[:lower:]' '[:upper:]')"

if [ -d "${DST}" ]
then
    echo "# go-corelibs/${DIRNAME} already exists"
    exit 1
fi

echo "# Path: ${DIRNAME}"
echo "# Package: ${NAME}"
echo "# Summary: ${SUMMARY}"
echo "# Description: ${DESCRIPTION}"
echo "#"
read -n 1 -p "# Create a new go-corelibs package? [Yn] " ANSWER
if [ -n "${ANSWER}" ]
then
    case "${ANSWER}" in
        "Y"|"y"|"\n") echo "";;
        *) echo; exit;;
    esac
fi


echo "# creating: ${DST}"

cp -Rv "${SCRIPT_PATH}/template-corelibs-pkg" "${DST}"
pushd "${DST}" > /dev/null

mv -v tmplpkgname.go ${NAME}.go
${RPL_BIN} -ra 'tmplpkgdir'         "${DIRNAME}"
${RPL_BIN} -ra 'tmplpkgname'        "${NAME}"
${RPL_BIN} -ra 'TMPLPKGNAME'        "${KEY}"
${RPL_BIN} -ra 'tmplpkgsummary'     "${SUMMARY}"
${RPL_BIN} -ra 'tmplpkgdescription' "${DESCRIPTION}"
go mod init
go mod tidy
git init .
git add .gitignore
git commit -m ".gitignore: added git ignorance"
for f in LICENSE AUTHORS.md
do
    git add "${f}"
    git commit -m "${f}: added $(basename "${f}" ".md") file"
done
CL_VER=$(grep CORELIBS_MK_VERSION CoreLibs.mk | awk '{print $3}')
git add CoreLibs.mk
git commit -m "CoreLibs.mk: added ${CL_VER}"
git add Makefile
git commit -m "Makefile: added go-corelibs Makefile"
popd > /dev/null
echo "# done"
