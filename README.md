# Vite DB
A basic postgres database setup with migrations for the [vite_server project](https://github.com/theVite/vite_server/).

## Docker
- To start the postgres run `docker/start_db.sh`
- To stop the postgres container run `docker/stop_db.sh`

## Database Operations
- To clear the data in the database run `drop_data.sh`
- To run migrations run `migrate.sh` with the version that is being upgraded to
  as the first argument. If no argument is given, the database will be upgraded
  to the latest version.
