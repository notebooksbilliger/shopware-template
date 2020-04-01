#!/usr/bin/env bash

function _help(){
    echo -e "
########################################################################################################################
${YELLOW}Project '${COMPOSE_PROJECT_NAME}' launcher${NC}:
${GREEN}./bin/run.sh [command] [args]${NC}           You can skip command name and arguments, in this case all default commands will be
                                    executed to start up the stack.
             [args]                 Allow you to define/override environment variables for any command you execute:
                                    --env='VAR=val'  Especially might be Needed on the CI/CD env.

                                    ./bin/run.sh build [--env='APP_VERSION=123' [--env='APP_ENV=prod']]
${YELLOW}Commands list${NC}:

    ${GREEN}help|--help|-h|h${NC}      - Shows this help
    ${GREEN}vendors-sync${NC}          - Makes sync of the vendors folder from the container into host machine. It's needed
                                          Only for dev environment and only when developer wants to have a vendors on local for
                                          IDE highlighting or so..
    ${GREEN}build [args]${NC}          - Builds stack, prepares images, which possible to use for deployment. Note, during building
                                         it will start and stop stack, so that if you have running stack, it will be stopped
    ${GREEN}stop${NC}                  - Stops the stack
    ${GREEN}logs${NC}                  - Tails logs from running stack
    ${GREEN}test$ [args]${NC}          - Do testing. Uses docker-compose-test.yml services definition, but images taken from docker-compose.yml, so that
                                         Before you call test command, ensure that build command worked fine. As arguments you can pass all arguments, which are supported by phpunit
    ${GREEN}start${NC}                 - Start the stack
    ${GREEN}restart${NC}               - Restart the stack, but without any installations, just restart the stack
    ${GREEN}reload${NC}                - Restart the stack and ensures that you have installed all composer dependencies. At the end
                                            it also makes sync of vendors directory from running container into host machine
    ${GREEN}wipe-all${NC}              - Makes an attempt to ${RED}clean up your workspace from ALL docker leftovers/containers/volumes${NC}.
                                            Note, ${RED}this operation is NOT safe for running on CI/CD environment${NC}, so use it ONLY on local.
                                            It removes all docker related leftovers, which is possible to remove. It does not care about project names, so on and
                                            clean up everything.

    ${GREEN}clean-workspace${NC}        - do a soft clean up of the environement. Safe for usage on the CI/CD, because with proper configuration
                                            Should not affect on the parallel builds

${YELLOW}Commands call examples${NC}:

${GREEN}./bin/run.sh${NC}                                                       - does all the magic to start stack on the local host
${GREEN}./bin/run.sh build --env='APP_ENV=dev' --env='APP_VERSION=666'${NC}     - builds an application for the prod environment
${GREEN}./bin/run.sh clean${NC}                                                 - clean up local environment from all the docker related to this stack,
                                                                                    also can clean up leftovers from other stacks :D. Never run it on CI/CD env
${GREEN}./bin/run.sh logs${NC}                                                  - connect to running stack to tail the logs. use CMD+C to terminate it
${GREEN}./bin/run.sh test --version${NC}                                        - see phpunit version
${GREEN}./bin/run.sh test --testsuite=system${NC}                               - run phpunit with test suit 'system'
########################################################################################################################
    ";
}