#!/usr/bin/env bash
function _mysql_wait(){
    retries=10;
    interval=5;

    echo "Waiting for database being ready. Max retries ${retries} with interval ${interval} sec";

    # insert parameters
    while [ ${retries} -gt 0 ]; do
        retries=$((retries-1))
        sleep ${interval}

        docker-compose exec -T mysql bash -c 'mysql --protocol TCP -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "show databases;" 2>&1 | grep -v "Warning:"' \
            || docker-compose logs mysql
        foundDB=$(docker-compose exec -T mysql bash -c 'mysql --protocol TCP -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "show databases;" 2>&1 | grep -v "Warning:" | grep "${MYSQL_DATABASE}"')
        if [ ! -z "${foundDB}" ]; then
            echo "DB found ${foundDB} \n"
            break;
        fi;
        echo '.';
    done;
}
