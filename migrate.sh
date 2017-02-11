#!/bin/bash -e

HOST="127.0.0.1"
USERNAME="postgres"
PASSWORD=""

ROOT=$(dirname $0)

run_script() {
    OUTPUT=$(PGPASS=$PASSWORD psql -h $HOST -U $USERNAME < $1)
}

quiet_run_script() {
    OUTPUT=$(PGPASS=$PASSWORD psql -h $HOST -U $USERNAME < $1 2>/dev/null)
}

set_version() {
    ( cat $ROOT/database_scripts/set_version.sql; echo "$1"; echo "\." ) | PGPASS=$PASSWORD psql -h $HOST -U $USERNAME >/dev/null
    SET_VERSION=$1
}

if [[ "$#" > 1  || ("$#" = "1" && "$1" =~ "[0-9]+") ]]; then
    echo "Usage: [<migration-version>]"
    echo "Migrates the vite database to the specified version."
    exit
fi

DEST_VERSION=$1

quiet_run_script $ROOT/database_scripts/get_version.sql
SOURCE_VERSION=$OUTPUT

if [ -z "$SOURCE_VERSION" ]; then
    SOURCE_VERSION="-1"
fi

for migration_file in $(ls -v $ROOT/migrations); do
    MIGRATION_VERSION=$(echo $migration_file | cut -d. -f1)

    if [ -n "$DEST_VERSION" ] && [[ "$MIGRATION_VERSION" > "$DEST_VERSION" ]]; then break; fi

    if [[ "$MIGRATION_VERSION" > "$SOURCE_VERSION" ]]; then
       echo "Running migration: $migration_file"
       run_script $ROOT/migrations/$migration_file
       set_version $MIGRATION_VERSION
    fi
done

if [[ "$SOURCE_VERSION" < "$SET_VERSION" ]]; then
    if [ "$SOURCE_VERSION" -eq -1 ]; then
        echo "Database migrated to V$SET_VERSION"
    else
        echo "Database migrated from V$SOURCE_VERSION to V$SET_VERSION"
    fi
fi
