# Extract

To demonstrate the extract job we need to set up data source and audit. Once your data source is set up, we can set up the audit table for audit api as follow.

## Setting Up  Audit Table In Postgres

create a database for audit table. I've created 'bpcl' as my database. Run the following commands to create audit schema in your database.


```console
aayush@aayushs2-mobl:~$ sudo su postgres
[sudo] password for aayush:
postgres@aayushs2-mobl:/home/aayush$ psql -h localhost -p 5432 -d bpcl --username=aayush -f data-pipeline/extract/src/create_tables.sql
```


> Save 'create_tables.sql' file in /tmp folder and run it form there if the above commands prompts permission denied.

once the table is created successfully we are ready to launch our audit flask api and extract job flask api.

## Running Audit.py

This is a flask api running at port 8080. To start the service run the file as,

```console
aayush@aayushs2-mobl:~/data-pipeline/extract/src$ python3 audit.py
 * Serving Flask app 'audit'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8080
 * Running on http://172.30.65.185:8080
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 127-822-027
 ```
 The service has started.

 > call the audit at http://127.0.0.1/8080/audit

 ## Running extract_job.py

 This script, when triggered via airflow, connects to postgresql runs the query passed in as a json input, writes the result in a csv file then compresses it and uploads the .gz file to Minio (object store). Then once this is complete it requests the audit api to log in all the details like execution time taken, compression time, file size before and after compression, etc.

 This script also runs as a flask api.

 ```console
 aayush@aayushs2-mobl:~/data-pipeline/extract/src$ python3 extract_job.py
 * Serving Flask app 'extract_job'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.30.65.185:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 127-822-027
 ```
> call extract_job at http://127.0.0.1:5000/extract

## Testing

To test the code let's use curl command as follow.

> Testing extract_job.py

```console
curl -X POST http://ec2-43-205-208-158.ap-south-1.compute.amazonaws.com:5000/extract -d '{ "location" : "/home/ubuntu/out/", "query" : "select * from store_sales limit 33", "table_name" : "store_sales"}'
```

> Testing audit.py

```console
curl -X POST http://ec2-43-205-208-158.ap-south-1.compute.amazonaws.com:8080/audit -d '{"query_execution_time" : "0.001","file_writing_time" : "0.002", "compression_time" : "0.003" , "initial_file_size" :  "30 KB", "final_file_size" :  "0.5 KB", "rows_affected" : "600", "committed_file" : "file_destination_minio", "job_name" : "python-fact-extract", "job_type" : "extract", "source" : "tpcds"}'
```
