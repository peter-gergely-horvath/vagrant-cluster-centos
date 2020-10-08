#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# set and IFS was taken from Microsoft Azure CLI templates.
# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

declare -r scriptDirectory="$(dirname "$0")"

die () {
    echo >&2 "$@"
    exit 1
}

usage() {
    echo "Usage: $0 TODO: add parameters" 1>&2;
    exit 1;
}

#######################################
# ENTRY POINT

cd "${scriptDirectory}"

vagrant up