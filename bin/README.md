# Usage
Always, for the most recent help, refer to the `help` command. 

Do not forget, this runner is designed to be executed on the host machine (where you have installed docker) and should not be executed
inside the docker container.


### Call format
Note, overriding with `--env="VAR_val"` of the environment can work for any executed command.
```bash
./bin/run.sh [command] [args]           You can skip command name and arguments, in this case all default commands will be
                                    executed to start up the stack.
             [args]                 Allow you to define/override environment variables for any command you execute:
                                    --env='VAR=val'  Especially might be Needed on the CI/CD env.

                                    ./bin/run.sh build [--env='APP_VERSION=123' [--env='APP_ENV=prod']]
```

### Commands list
```bash
    help|--help|-h|h          - Shows this help
        vendors-sync          - Makes sync of the vendors folder from the container into host machine. It's needed
                                              Only for dev environment and only when developer wants to have a vendors on local for
                                              IDE highlighting or so..
        build   [args]        - Builds stack
        stop                  - Stops the stack
        logs                  - Tails logs from running stack
        test$ [args]          - Do testing. Uses docker-compose-test.yml services definition, but images taken from docker-compose.yml, so that
                                             Before you call test command, ensure that build command worked fine. As arguments you can pass all arguments, which are supported by phpunit
        start                 - Start the stack
        restart               - Restart the stack, but without any installations, just restart the stack
        reload                - Restart the stack and ensures that you have installed all composer dependencies. At the end
                                                it also makes sync of vendors directory from running container into host machine
        wipe-all              - Makes an attempt to clean up your workspace from docker leftovers/containers/volumes.
                                                Note, this operation is not safe for running on CI/CD environment, so use it ONLY on local
    
        clean-workspace       - do a soft clean up of the environement. Safe for usage on the CI/CD, because with proper configuration
                                                Should not affect on the parallel builds
```

### Commands call examples:
```bash
./bin/run.sh                            - does all the magic to start stack on the local host
./bin/run.sh build --env='APP_ENV=dev' --env='APP_VERSION=666' - builds an application for the prod environment
./bin/run.sh clean                      - clean up local environment from all the docker related to this stack,
                                                    also can clean up leftovers from other stacks :D. Never run it on CI/CD env
./bin/run.sh logs                       - connect to running stack to tail the logs. use CMD+C to terminate it
```