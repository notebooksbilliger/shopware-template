#!/usr/bin/env bash

function log:debug() {
    while [ $# -gt 0 ]; do
        echo -e "[$( date )][debug] ${1}"
        shift
    done
}

function log:info() {
    while [ $# -gt 0 ]; do
        echo -e "[$( date )][info] ${YELLOW} ${1} ${NC}"
        shift
    done
}

function log:error() {
    while [ $# -gt 0 ]; do
        echo -e "[$( date )][error] ${RED} ${1} ${NC}" 1>&2
        shift
    done
}