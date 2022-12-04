CREATE TABLE audit(
    entry_time timestamp,
    job_type varchar(300),
    job_name varchar(300),
    source varchar(300),
    query_execution_time varchar(300),
    file_writing_time varchar(300),
    compression_time varchar(300),
    rows_affected varchar(300),
    initial_file_size varchar(300),
    final_file_size varchar(300),
    committed_file varchar(300),
    primary key(entry_time)
);
alter table audit alter column entry_time set default now();