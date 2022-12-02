# Installing Airflow from PyPI

> Airflow is a platform to programmatically author, schedule and monitor workflows.

## Installing Airflow

Command to install airflow from PyPI looks like below:

```shell
pip install "apache-airflow[celery]==2.4.3" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.4.3/constraints-3.10.txt"
```

Airflow command is not recognized, then ensure that `~/.local/bin` is in your PATH environment variable, and add it in if necessary:

```shell
PATH=$PATH:~/.local/bin
```

Export Airflow directory

```shell
export AIRFLOW_HOME=/home/ubuntu/airflow
```

## Setting up Postgres

### Install Postgres and dependancies

```shell
sudo apt install postgresql
sudo apt install libpq-dev
pip install psycopg2
```

### Setting up a PostgreSQL Database

Switch to postgres user to access postgres shell

```shell
sudo su postgres
```

```shell
$ psql

psql (14.5 (Ubuntu 14.5-0ubuntu0.22.04.1))
Type "help" for help.

postgres=#
```

In the Postgres Shell

We need to create a database and a database user that Airflow will use to access this database. In the example below, a database airflow_db and user with username airflow_user with password airflow_pass will be created

```shell
CREATE DATABASE airflow_db;
CREATE USER airflow_user WITH PASSWORD 'airflow_pass';
GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;
```

We need to ensure schema public is in your Postgres user’s search_path.

```shell
ALTER USER airflow_user SET search_path = public;
```

You may need to update your Postgres config `/etc/postgresql/14/main/pg_hba.conf` to add the airflow user to the database access control list; and to reload the database configuration to load your change.

Add the following config under:

```shell
# TYPE  DATABASE        USER            ADDRESS                 METHOD


# IPv4 local connections:
host    all             all             0.0.0.0/0               trust
# IPv6 local connections:
host    all             all             ::/0                    trust
```

Restart the Postgres Service

```shell
sudo systemctl restart postgresql
```

## Configuring Airflow

> Groups are a very convenient way to hand over permissions to a directory or file

Create a new group called `ubuntu`

```shell
sudo groupadd ubuntu
```

Add user ubuntu to group ubuntu

```shell
sudo usermod -aG ubuntu ubuntu
```

Changing the airflow executor to `LocalExecutor` for use in production

```shell
cd $AIRFLOW_HOME
nano airflow.cfg
```

Add executor as LocalExecutor in the [core] section

```shell
executor = LocalExecutor
```

Also add postgres to be Metadata Database in the [database] section

```shell
sql_alchemy_conn = postgresql+psycopg2://airflow_user:airflow_pass@localhost:5432/airflow_db
```

Initialize Airflow DB

```shell
airflow db init
```

### Creating Unit files

Create Airflow Scheduler as below at `/etc/systemd/system/airflow-scheduler.service`

```shell
[Unit]
Description=Airflow scheduler daemon
After=network.target postgresql.service
Wants=postgresql.service

[Service]
#EnvironmentFile=/etc/default/airflow
Environment="PATH=/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
User=ubuntu
Group=ubuntu
Type=simple
ExecStart=/home/ubuntu/.local/bin/airflow scheduler
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
#airflow-webserver.service
```

Create Airflow Webserver as below at `/etc/systemd/system/airflow-webserver.service`

```shell
[Unit]
Description=Airflow webserver daemon
After=network.target postgresql.service
Wants=postgresql.service

[Service]
#EnvironmentFile=/etc/default/airflow
Environment="PATH=/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
User=ubuntu
Group=ubuntu
Type=simple
ExecStart=/home/ubuntu/.local/bin/airflow webserver -p 8080 --pid /home/ubuntu/airflow/airflow-webserver.pid
Restart=on-failure
RestartSec=5s
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

Reload systemd manager configuration.

```shell
sudo systemctl daemon-reload
```

Enable and start the services

```shell
sudo systemctl --now enable airflow-scheduler
sudo systemctl --now enable airflow-webserver
```

Creating Airflow User `admin` and password `admin`

```shell
airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin
```

Access Airflow through website at

```shell
http://<server-ip>:8080
```

Login with `admin` as username and password
