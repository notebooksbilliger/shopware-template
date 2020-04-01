#!/usr/bin/env bash

function _check_host() {
    # check is all the nessesary things are available
    docker_version=$(docker --version)
    if [ $? -ne 0 ]; then
        log:error "Install 'Docker' on the host";
        exit 2;
    fi;

    docker_compose_version=$(docker-compose --version)
    if [ $? -ne 0 ]; then
        log:error "Install 'docker-compose' on the host";
        exit 2;
    fi;
    exit 0;
}