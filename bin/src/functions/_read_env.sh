#!/usr/bin/env bash

function _read_env() {
    while [ $# -gt 0 ]; do
        case "${1}" in
            --env=*)
                env_string="${1#*=}";
                export $env_string
            ;;
        esac;
        shift;
    done;
}