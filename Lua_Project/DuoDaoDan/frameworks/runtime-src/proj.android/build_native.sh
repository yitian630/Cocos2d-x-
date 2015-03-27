#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export NDK_DEBUG=0
$DIR/build_native_release.sh