# Launch GreenPlum in DBeaver
## Create volume greenplum_data:
docker volume create greenplum_data

## Navigate to the docker-compose repository in the terminal.
## Run the command:

  docker-compose up -d

## Create database

  docker exec -it greenplum bash <br />
  sudo -u gpadmin /usr/local/gpdb/bin/createdb database_name

## Open DBeaver and create a connection (select PostgreSQL):

  Database: database_name <br />
  Port: 5433 <br />
  Username: gpadmin <br />
  Password: #empty field
### You can create your user through /usr/local/gpdb/bin/createdb

## RUN the sql scripts

  sql_scripts/create_tables_gp.sql <br />
  sql_scripts/func_generate_and_trancate.sql

## Call data generation

  SELECT generate_test_data();

## If you want to clear the data, call the truncate_test_data procedure

  SELECT truncate_test_data();

## You can drop all tables

  sql_scripts/drop_tall_tables_gp.sql

### Use explain analysis to see how data is distributed
## Stop containers


  docker-compose down -v

