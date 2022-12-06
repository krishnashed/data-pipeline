#import snappy
import os
import csv
import gzip
import time
import json
import shutil
import psycopg2
import requests
import sys
from minio import Minio
from datetime import datetime
from dotenv import load_dotenv
from flask import Flask, request

app = Flask(__name__)


# connect to the postgres server
def get_connection():
    connection = psycopg2.connect(
    host="localhost",
    port=5432,
    database="tpcd_db",
    user="aayush",
    password="test123"
    )
    return connection


#get the file location and file name
def get_filename(location, table_name):
    path = location
    file = f"{table_name}_{datetime.timestamp(datetime.now())}.csv"
    if path[-1] == '/':
        return path + file
    return path + '/' + file


# execute the sql
def execute(connect, file_name, query):

    print("Query Execution Started")
    print(f"Executing : {query}")
    cur = connect.cursor()
    start_query_exec = time.time()
    cur.execute(f"{query}")
    end_query_exec = time.time()
    
    print("Writing to file started")
    print(f"writing to {file_name}")
    start_writing = time.time()
    #writing to csv file
    with open(file_name, "w", newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        #csv_writer.writerow([cur.rowcount])
        csv_writer.writerow([att_name[0] for att_name in cur.description])
        csv_writer.writerows(cur)
    end_writing = time.time()
    
    cur.close()
    connect.close()
    rows_affected = cur.rowcount
    return rows_affected, (end_query_exec-start_query_exec), (end_writing-start_writing) 


#compress file
def compress(file):
    
    print("Compressing file")
    gz_file = file+'.gz'
    with open(file, "rb") as f_in:
        with gzip.open(gz_file, "wb", compresslevel=9) as f_out:
            shutil.copyfileobj(f_in, f_out)
    print("Compresssion Done!")
    
    return gz_file

#calculate file size in KB, MB, GB
def convert_bytes(size):
    for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024.0:
            return "%3.1f %s" % (size, x)
        size /= 1024.0

#pushing to minIO
def push_file(file):
    print("UPLOAD STARTED")
    print(f"Uploading File : {file}")
    load_dotenv()
    ACCESS_KEY = os.environ.get('ACCESS_KEY')
    SECRET_KEY = os.environ.get('SECRET_KEY')
    BUCKET_NAME = os.environ.get('BUCKET_NAME')
    minIO_host = "ec2-65-0-177-178.ap-south-1.compute.amazonaws.com:9000"
    minIO_client = Minio(minIO_host, access_key=ACCESS_KEY, secret_key=SECRET_KEY, secure=False)
    if minIO_client.bucket_exists(BUCKET_NAME):
        minIO_client.fput_object(BUCKET_NAME, f"source/tpcds/{file.split('/')[-1]}", file)
        print("UPLOAD SUCCESSFUL!")
        return BUCKET_NAME
    print("buket doesn't exits")

# calling the audit api
def audit(d):
    print("Started Writing to the audit table")
    url = "http://43.205.208.158:8080/audit"
    #url = "http://127.0.0.1:8080/"
    res = requests.post(url, json=d)
    print(f"writing done code returned with status code {res.status_code}")



def main(location, query, table_name):
    print(f"Starting Execution At {datetime.now()}")
    connect = get_connection()
    file = get_filename(location, table_name)
    row_count, query_time, writing_time = execute(connect, file, query)
    initial_size = os.stat(file).st_size
    start_compression = time.time()
    compressed_file = compress(file)
    end_compression = time.time()
    final_size = os.stat(compressed_file).st_size
    initial_size = convert_bytes(initial_size)
    final_size = convert_bytes(final_size)
    #timestamp = datetime.now()
    bucket = push_file(compressed_file)
    d = {"query_execution_time" : query_time,"file_writing_time" : writing_time, "compression_time" : (end_compression-start_compression) , "initial_file_size" :  initial_size, "final_file_size" :  final_size, "rows_affected" : row_count, "committed_file" : f"{bucket}/source/tpcds/{compressed_file.split('/')[-1]}" }
    d["job_name"] = "python-fact-extract"
    d["job_type"] = "extract"
    d["source"] = "tpcds"
    audit(d)
    print(f"Execution ends at {datetime.now()}")
    return d

@app.route('/extract', methods=["POST"])
def entry():
    location=""
    query=""
    table_name=""

    json_data = request.get_json(force=True)

    location = json_data["location"]
    query = json_data["query"]
    table_name = json_data["table_name"] 

    if location!="" and query!="" and table_name!="":
        data = main(location, query, table_name)
        data_json = json.dumps(data, default=str)
        return data_json
    else:
        return "please use all the arguments"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)