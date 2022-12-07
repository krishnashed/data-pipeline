# Creating TPCDS Schema

Download the tpcds data that is to be loaded in the schema.

> It's required to have your data in /tmp directory else loading the data to postgresql schema will prompt permission denied.


### creating database
To create

```console
aayush@aayushs2-mobl:~$ sudo su postgres
[sudo] password for aayush:
postgres@aayushs2-mobl:/home/aayush$ psql
psql (15.1 (Ubuntu 15.1-1.pgdg20.04+1))
Type "help" for help.

postgres=# create database tpcds_db;
CREATE DATABASE
postgres=#\q
QUIT
```

### loading data in tpcds databse

Now we can load the data in tpcds database


> ensure to correct the \COPY command with right file location.

```console
aayush@aayushs2-mobl:~$ sudo su postgres
[sudo] password for aayush:
postgres@aayushs2-mobl:/home/aayush$ psql -h localhost -p 5432 -d tpcds_db --username=aayush -f data-pipeline/extract/src/tpcds_data/create_tables.sql
```


> If create_table.sql promts permission denied move the file to /tmp and re-run it.