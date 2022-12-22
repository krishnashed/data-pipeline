# Installing Metabase on Ubuntu VM

> Metabase is the BI tool with the friendly UX and integrated tooling to let your company explore data on their own.

## Prerequisites

### Install Java on Ubuntu 22.04

Update your APT package index:

```shell
sudo apt -y update
```

Then install Java JDK on Ubuntu system:

```shell
sudo apt install -y default-jdk
```

You can query for the version of Java installed using the following command:

```shell
$ java -version
openjdk version "11.0.17" 2022-10-18
OpenJDK Runtime Environment (build 11.0.17+8-post-Ubuntu-1ubuntu222.04)
OpenJDK 64-Bit Server VM (build 11.0.17+8-post-Ubuntu-1ubuntu222.04, mixed mode, sharing)
```

### Install and Configure the Postgres Database server

```shell
sudo apt install postgresql
sudo apt install libpq-dev
```

Enable the System Postgresql service:

```shell
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl status postgresql
```

#### Making the Postgres DB globally accessible

Under `/etc/postgresql/14/main/postgresql.conf` "CONNECTIONS AND AUTHENTICATION" section

Uncomment listen_addresses
Set listen_addresses to '\*'

Such that

```shell
#------------------------------------------------------------------------------
# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------------------

# - Connection Settings -

listen_addresses = '*'                  # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
```

Updating PostgreSQL Client Authentication Configuration File at `/etc/postgresql/14/main/pg_hba.conf`

> This file controls: which hosts are allowed to connect, how clients are authenticated, which PostgreSQL user names they can use, which databases they can access

Allowing all IPv4 and IPv6 hosts to use all PostgreSQL users and connect to all databases

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

Now we will be able to access Postgres globally

## Installing Metabase

```shell
export VER=0.44.6
wget http://downloads.metabase.com/v$VER/metabase.jar
sudo mkdir -p /apps/java
sudo cp metabase.jar /apps/java
```

### Configure Metabase Systemd service

Start by creating a system group for the user.

```shell
sudo groupadd -r appmgr
```

Next, we create a system user appmgr with the default group

```shell
sudo useradd -r -s /bin/false -g appmgr appmgr
```

Give this user ownership permission to the applications directory:

```shell
sudo chown -R appmgr:appmgr /apps/java
```

Create a systemd service unit file:

```shell
sudo vim /etc/systemd/system/metabase.service
```

Add the contents below to the file.

```shell
[Unit]
Description=Metabase applicaion service
Documentation=https://www.metabase.com/docs/latest

[Service]
WorkingDirectory=/apps/java
ExecStart=/usr/bin/java -Xms128m -Xmx256m -jar metabase.jar
User=appmgr
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

The next thing to do is start the application service, but first, reload systemd so that it loads the new application added.

```shell
sudo systemctl daemon-reload
```

Once reloaded, start the service and set it to start on boot:

```shell
sudo systemctl start metabase.service
sudo systemctl enable metabase.service
```

To check the status, use:

```shell
sudo systemctl status metabase
```

## Access Metabase Web User Interface

After the service is started, Metabase server will listen on port `3000` by default.
Access the web page to finish setup using `http://<server-IP>:3000`

### Adding Postgres Database to Metabase

Fill Appropriate values

```shell
Set any Display Name
Host : Public IPv4 DNS of Server
Port : 5432
Database name : postgres
Username : postgres
Password : postgres
```

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/postgres_db.jpeg"/>

</div>

### Reference

- [Metabase](https://computingforgeeks.com/how-to-install-metabase-with-systemd-on-ubuntu/)
