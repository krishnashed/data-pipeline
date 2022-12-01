# Minio Installation on Ubuntu 22.04 VM

> MinIO High Performance Object Storage

MinIO is a high performance object storage solution that provides an Amazon Web Services S3-compatible API and supports all core S3 features.

## Minio Server Installation DEB (Debian/Ubuntu)

Use the following commands to download the latest stable MinIO DEB and install it:

```shell
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20221126224332.0.0_amd64.deb -O minio.deb
sudo dpkg -i minio.deb
```

## Launch the MinIO Server

Run the following command from the system terminal or shell to start a local MinIO instance using the `~/minio` folder. You can replace this path with another folder path on the local machine:

```shell
mkdir ~/minio
minio server ~/minio --console-address :9090
```

The `mkdir` command creates the folder explicitly at the specified path.

The `minio server` command starts the MinIO server. The path argument `~/minio` identifies the folder in which the server operates.

The [`minio server`](https://min.io/docs/minio/linux/reference/minio-server/minio-server.html#command-minio.server) process prints its output to the system console, similar to the following:

```shell
API: http://192.0.2.10:9000  http://127.0.0.1:9000
RootUser: minioadmin
RootPass: minioadmin

Console: http://192.0.2.10:9090 http://127.0.0.1:9090
RootUser: minioadmin
RootPass: minioadmin

Command-line: https://min.io/docs/minio/linux/reference/minio-mc.html
   $ mc alias set myminio http://192.0.2.10:9000 minioadmin minioadmin

Documentation: https://min.io/docs/minio/linux/index.html

WARNING: Detected default credentials 'minioadmin:minioadmin', we recommend that you change these values with 'MINIO_ROOT_USER' and 'MINIO_ROOT_PASSWORD' environment variables.
```

## Connect Your Browser to the MinIO Server

Open http://127.0.0.1:9000 in a web browser to access the MinIO Console. You can alternatively enter any of the network addresses specified as part of the server command output. For example, console: http://192.0.2.10:9090 http://127.0.0.1:9090 in the example output indicates two possible addresses to use for connecting to the Console.

While the port 9000 is used for connecting to the API, MinIO automatically redirects browser access to the MinIO Console.

Log in to the Console with the `RootUser` and `RootPass` user credentials displayed in the output. These default to `minioadmin` | `minioadmin`.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://min.io/docs/minio/linux/_images/console-login1.png"/>
</div>

<br/>
You can use the MinIO Console for general administration tasks like Identity and Access Management, Metrics and Log Monitoring, or Server Configuration. Each MinIO server includes its own embedded MinIO Console.
<br/>
<br/>

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://min.io/docs/minio/linux/_images/minio-console1.png"/>
</div>

### Reference

- [Minio](https://min.io/docs/minio/linux/index.html)
