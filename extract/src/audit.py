# This is a script to write to the audit table

import json
import psycopg2
#import subprocess
from flask import Flask, request

#subprocess.run(['export', f'FLASK_APP=audit.py'])

app = Flask(__name__)

# connecting to the database
def connect():
    connection = psycopg2.connect(
        host="localhost",
        port=5432,
        database="bpcl",
        user="aayush",
        password="test123"
    )
    return connection


# Insert data
def Insert(conn, data):
    cur = conn.cursor()
    query = f'''
        INSERT INTO audit( 
    job_type,
    job_name,
    source,
    query_execution_time,
    file_writing_time,
    compression_time,
    rows_affected,
    initial_file_size,
    final_file_size,
    committed_file) VALUES('{data["job_type"]}',' {data["job_name"]}', '{data["source"]}', '{data["query_execution_time"]}', '{data["file_writing_time"]}', '{data["compression_time"]}', '{data["rows_affected"]}', '{data["initial_file_size"]}', '{data["final_file_size"]}', '{data["committed_file"]}')
    '''
    cur.execute(query)
    conn.commit()
    return "OK"

@app.route('/', methods=["POST"])
def main():
    json_data = request.get_json(force=True)
    json_data = str(json_data)
    json_data = json_data.replace("\'", "\"")
    data = json.loads(json_data)
    print("Inserting data")
    print(json.dumps(data, indent=4)) #printing the data recieved
    conn = connect()
    return Insert(conn, data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)