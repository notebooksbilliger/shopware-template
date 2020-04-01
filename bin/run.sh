#!/bin/bash
set +x

# a subshell needed to isolate host env from the runtime env
(
    script_dir=$(ABSOLUTE_PATH="$( cd "$( dirname "$0" )" && pwd -P )"; RELATIVE_PATH=$(dirname "$(readlink "$0")"); cd "${ABSOLUTE_PATH}/${RELATIVE_PATH}" && pwd -P)
    . ${script_dir}/src/init.sh

    # handle command
    case "${1}" in
        --help|-h|h|help)
            _help
            exit 0;
        ;;
        build):
            log:info "Building stack for project ${COMPOSE_PROJECT_NAME}, env: '${APP_ENV}', version: '${APP_VERSION}'"
            docker-compose build --compress --force-rm --pull --parallel \
               && ./bin/run.sh stop \
               && ./bin/run.sh start \
               && docker-compose exec app sh -c "shopware build:shopware-runtime" \
               && docker-compose build app \
               && ./bin/run.sh stop
        ;;
        stop):
            log:info "Killing stack for project ${COMPOSE_PROJECT_NAME}"
            docker-compose down
        ;;
        logs):
            log:info "Failing logs from stack ${COMPOSE_PROJECT_NAME}"
            trap _help INT
            docker-compose logs -f
        ;;
        start):
            log:info "Starting stack for project ${COMPOSE_PROJECT_NAME}, env: '${APP_ENV}', version: '${APP_VERSION}'"
            docker-compose up -d \
                && docker-compose exec app dockerize -wait tcp://${DB_HOST}:${HOST_DB_PORT} -timeout 30s \
                && docker-compose exec app sh -c "chown -R www-data:www-data ." \
                && log:info "Stack for project ${COMPOSE_PROJECT_NAME}, env: '${APP_ENV}', version: '${APP_VERSION}' is up and running!"
        ;;
        restart):
            log:info "Restarting stack for project ${COMPOSE_PROJECT_NAME}, env: '${APP_ENV}', version: '${APP_VERSION}'"
            ./bin/run.sh stop \
                &&./bin/run.sh start
        ;;
        reload):
            ./bin/run.sh stop \
                && ./bin/run.sh start \
                && ./bin/run.sh install \
                && ./bin/run.sh migrate
        ;;
        install):
            log:info "Install composer dependencies"
            docker-compose up -d mysql \
                && docker-compose exec app sh -c "composer install --no-interaction --optimize-autoloader --no-suggest" \
                && docker-compose exec app sh -c "composer install -d vendor/shopware/recovery --no-interaction --optimize-autoloader --no-suggest" \
                && docker-compose down
        ;;
        migrate):
            log:info "Run migrations"
            # TODO move dockerize -wait into entrypoint
            docker-compose exec app dockerize -wait tcp://${DB_HOST}:${HOST_DB_PORT} -timeout 30s \
                && docker-compose exec app shopware apply-migrations
        ;;
        test):
            log:info "Testing project ${COMPOSE_PROJECT_NAME}, env: '${APP_ENV}', version: '${APP_VERSION}'"
            (
                # with shift we remove command "test" from the arguments list
                shift
                docker-compose -f ./docker-compose.yml run --rm -e APP_ENV=test app ./vendor/bin/phpunit -d memory_limit=-1 $@
            )
        ;;
        wipe-all):
            log:info "Attempt to wiping a host from docker leftovers (unused images,networks,volumes)"
            (docker-compose down);
            (docker rmi -f $(docker images | grep 'none' | awk '{print $3}'))&
            (docker rmi -f $(docker images | grep "${COMPOSE_PROJECT_NAME}" | grep "${APP_VERSION}" | awk '{print $3}'))&
            (docker volume rm -f $(docker volume ls | grep "${COMPOSE_PROJECT_NAME}" | awk '{print $2}'))&
            (docker system prune --force --volumes --all)&
        ;;
        clean-workspace):
            log:info "Cleanup the workspace for project name: ${COMPOSE_PROJECT_NAME}; version: ${APP_VERSION}"
            docker-compose down
            docker rmi -f $(docker images --filter=reference="*/${COMPOSE_PROJECT_NAME}*:${APP_VERSION}*" -q) || true
            docker rmi -f $(docker images --filter=reference="*${COMPOSE_PROJECT_NAME}*:${APP_VERSION}*" -q) || true
            docker rmi -f $(docker images -f "dangling=true" -q) || true

            docker images | grep ${COMPOSE_PROJECT_NAME} | grep ${APP_VERSION}
        ;;
        vendors-sync):
            log:info "Doing sync of vendors from the container into host FS"
            docker-compose run --rm -v ${PWD}/vendor:/target -v ${COMPOSE_PROJECT_NAME}_app-vendor:/source app sh -c "echo '    -> Copying vendors content. Wait...' && cp -r /source/* /target"
        ;;
        *)
            # to prepare completely working application. Ensure that build-js builds proper theme for sales channel (if no, add parameters then)
            #  @see https://docs.shopware.com/en/shopware-platform-dev-en/internals/plugins/plugin-themes
            ./bin/run.sh build $@ \
            && ./bin/run.sh start $@ \
            && ./bin/run.sh vendors-sync $@
        ;;
    esac;
)
