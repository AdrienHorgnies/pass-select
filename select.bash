#!/usr/bin/env bash
# This script is largely derived from the method cmd_show from the password-store.
# See https://git.zx2c4.com/password-store/tree/src/password-store.sh#n368.

set -euo pipefail

[ -n "$PASSWORD_STORE_CONTENT_SELECTOR" ] || die "Please define the env variable PASSWORD_STORE_CONTENT_SELECTOR."
command -v "$PASSWORD_STORE_CONTENT_SELECTOR" >/dev/null || die "'$PASSWORD_STORE_CONTENT_SELECTOR' wasn't found."

local opts clip=0 qrcode=0
opts="$($GETOPT -o qc -l qrcode,clip -n "$PROGRAM" -- "$@")"
local err=$?
eval set -- "$opts"
while true; do case $1 in
    -q|--qrcode) qrcode=1; shift ;;
    -c|--clip) clip=1; shift ;;
    --) shift; break ;;
esac done

[[ $err -ne 0 || ( $qrcode -eq 1 && $clip -eq 1 ) || $# -ne 2 ]] && die "Usage: $PROGRAM $COMMAND [--clip,-c] [--qrcode,-q] pass-name expression"

local pass
local path="$1"
local expression="$2"
local passfile="$PREFIX/$path.gpg"
local selector="$PASSWORD_STORE_CONTENT_SELECTOR"
check_sneaky_paths "$path"
if [[ -f $passfile ]]; then
    pass="$($GPG -d "${GPG_OPTS[@]}" "$passfile" | $selector $expression | $BASE64)" || exit $?
    [[ -n $pass ]] || die "Selector '$selector $expression' didn't find any content in '$path'."
    if [[ $clip -eq 1 ]]; then
        clip "$($BASE64 -d <<< $pass)" "$path $expression"
    elif [[ $qrcode -eq 1 ]]; then
        qrcode "$($BASE64 -d <<< $pass)" "$path $expression"
    else
        echo "$pass" | $BASE64 -d
    fi
elif [[ -z $path ]]; then
    die "Error: password store is empty. Try \"pass init\"."
else
    die "Error: $path is not in the password store."
fi
