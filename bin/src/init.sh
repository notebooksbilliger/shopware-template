#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ ! -f .env ]; then
    echo -e "${RED}File '.env' was not found, copy .env.dist for you \n ${NC}"
    cp .env.dist .env && chmod a+rx .env
fi

export $(cat ${PWD}/.env | grep -v '#' | xargs)


# load functions -------------------------------------------------------------------------------------------------------
for file in ${script_dir}/src/functions/*.sh; do
    . ${file}
done

result=$(_check_host)

if [ $? -ne 0 ]; then
    log:error "Configure host first. Note './bin/run.sh' commands must be executed on the host and NOT inside the docker container"
    exit 2;
fi;

_read_env $@

# apply override file when it's available
if [ -f docker-compose.override.${APP_ENV}.yml ]; then
    echo -e "${RED}Was found 'docker-compose.override.${APP_ENV}.yml' file, so it's copied to 'docker-compose.override.yml' ${NC}"
    cp docker-compose.override.${APP_ENV}.yml docker-compose.override.yml && chmod a+rx docker-compose.override.yml
fi