#!/usr/bin/env bash
set -e

#the scripts gets executed when creating the database the first time and can be called manually if needed later

#make sure the root details are in place
if [ -z ${POSTGRES_USER} ]; then
    echo "The root postgres user is not specified"
    exit 1;
fi

#postgres shortcut
POSTGRES="psql -tA --username ${POSTGRES_USER}"

#checks whether the user already exists in postgres
function userExists {
    local USER=$1

    if [ -z ${USER} ]; then
        echo "The username is missing"
        exit 1
    fi

    local exists=$(${POSTGRES} <<< "SELECT 1 FROM pg_roles WHERE rolname='${USER}'")

    if [ "${exists}" = "1" ]; then
        echo true
    else
        echo false
    fi
}

#checks whether the database exists
function dbExists {
    local DB=$1

    if [ -z ${DB} ]; then
        echo "The database name is missing"
        exit 1
    fi

    local exists=$(${POSTGRES} <<< "SELECT 1 FROM pg_database WHERE datname='${DB}'")

    if [ "${exists}" = "1" ]; then
        echo true
    else
        echo false
    fi
}

#create a user in the database
#params:
# - user (required)
# - password (required)
# - database (optional)
function addUser {
    local USER=$1
    local PASS=$2
    local DB=$3

    if [ -z ${USER} ] || [ -z ${PASS} ]; then
        echo "The required arguments are missing"
        exit 1;
    fi

    #create the user

    local userExists=$(userExists ${USER})

    if [ ${userExists} = true ]; then
        echo "The user ${USER} already exists"
    else
        echo "Creating user ${USER} with password ${PASS}";

        ${POSTGRES} <<< "CREATE USER ${USER} WITH PASSWORD '${PASS}'";

        if [ ! -z ${DB} ]; then

            local dbExists=$(dbExists ${DB})

            if [ ${dbExists} = true ]; then
                echo "The database ${DB} already exists"
            else
                echo "Creating database ${DB} for the user ${USER}";
                ${POSTGRES} <<< "CREATE DATABASE ${DB} OWNER ${USER}";
                ${POSTGRES} <<< "GRANT ALL PRIVILEGES ON DATABASE ${DB} TO ${USER}";
            fi
        fi
    fi
}

#create the users/databases
addUser ${UREG_DS_USER} ${UREG_DS_PASS} ${UREG_DS_DB}
addUser ${MAILER_DS_USER} ${MAILER_DS_PASS} ${MAILER_DS_DB}
addUser ${POLLING_USER} ${POLLING_PASS} ${POLLING_DB}
addUser ${KONG_PG_USER} ${KONG_PG_PASSWORD} ${KONG_PG_DATABASE}

echo "Initialization finished";

exit 0;