#!/bin/bash
if docker images | grep -q torizoncore-builder; then
    . ./tcb-env-setup.sh -a local &>/dev/null
else
    echo Downloading torizoncore-builder image
    . ./tcb-env-setup.sh -a remote &>/dev/null
fi
shopt -s expand_aliases
torizoncore-builder "$@"
true
