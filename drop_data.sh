#!/bin/bash

HOST="127.0.0.1"
USERNAME="postgres"
PASSWORD=""

ROOT=$(dirname $0)

run_script() {
    OUTPUT=$(PGPASS=$PASSWORD psql -h $HOST -U $USERNAME < $1)
}

run_script $ROOT/database_scripts/drop_schema.sql
