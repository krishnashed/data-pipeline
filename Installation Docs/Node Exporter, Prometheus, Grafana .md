<img src="./images/logo.sample.png" alt="Logo of the project" align="right">

# Monitor Linux Servers Using Prometheus & Grafana

> In this guide, you will learn how to setup Prometheus node exporter on a Linux server to export all node level metrics to the Prometheus server and visualize it on Grafana

## Setup Node Exporter

> Install Node Exporter on those VMs from which you need to scrape Node Metrics

Download the latest node exporter package from the Prometheus [download page](https://prometheus.io/download/)

```shell
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
```

Unpack the tarball

```shell
tar -xvf node_exporter-1.5.0.linux-amd64.tar.gz
```

Move the node export binary to /usr/local/bin

```shell
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/
```

### Create a Custom Node Exporter Service

Create a node_exporter user to run the node exporter service.

```shell
sudo useradd -rs /bin/false node_exporter
```

Create a node_exporter service file under systemd.

```shell
sudo vi /etc/systemd/system/node_exporter.service
```

Add the following service file content to the service file and save it.

```shell
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

Reload the system daemon and star the node exporter service.

```shell
sudo systemctl daemon-reload
sudo systemctl start node_exporter
```

Check the node exporter status to make sure it is running in the active state.

```shell
 sudo systemctl status node_exporter
```

Enable the node exporter service to the system startup.

```shell
 sudo systemctl enable node_exporter
```

Now, node exporter would be exporting metrics on port `9100`.

You can see all the server metrics by visiting your server URL on `/metrics` as shown below.

```shell
http://<server-IP>:9100/metrics
```

## Install and Configure Prometheus

> Prometheus is an open-source monitoring system which is very lightweight and has a good alerting mechanism.

Update the package repositories.

```shell
sudo apt update
sudo apt upgrade -y
```

### Downloading Prometheus

Go to the official Prometheus [downloads page](https://prometheus.io/download/) and get the latest download link for the Linux binary.

```shell
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.40.4/prometheus-2.40.4.linux-amd64.tar.gz
tar -xvf prometheus-2.40.4.linux-amd64.tar.gz
mv prometheus-2.40.4.linux-amd64 prometheus-files
```

Create a Prometheus user, required directories, and make Prometheus the user as the owner of those directories.

```shell
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

Copy prometheus and promtool binary from prometheus-files folder to /usr/local/bin and change the ownership to prometheus user.

```shell
sudo cp prometheus-files/prometheus /usr/local/bin/
sudo cp prometheus-files/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```

Move the consoles and console_libraries directories from prometheus-files to /etc/prometheus folder and change the ownership to prometheus user.

```shell
sudo cp -r prometheus-files/consoles /etc/prometheus
sudo cp -r prometheus-files/console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
```

### Setup Prometheus Configuration

All the prometheus configurations should be present in `/etc/prometheus/prometheus.yml` file.

#### Create the `prometheus.yml` file.

```shell
sudo vi /etc/prometheus/prometheus.yml
```

Copy the following contents to the `prometheus.yml` file.

```shell
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
```

Under the scrape config section add the node exporter target as shown below. Job name can be your server hostname or IP for identification purposes.

```shell
- job_name: 'node_exporter_metrics'
  scrape_interval: 5s
  static_configs:
    - targets: ['<server1-IP>:9100', '<server2-IP>:9100', ...]
```

The `prometheus.yml` should be something like, where I'm monitoring node_exporter metrics from 3 VMs

```shell
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100', '65.0.177.178:9100', '13.233.43.107:9100']
```

Change the ownership of the file to prometheus user.

```shell
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
```

### Setup Prometheus Service File

Create a prometheus service file.

```shell
sudo vi /etc/systemd/system/prometheus.service
```

Copy the following content to the file.

```shell
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

Reload the systemd service to register the prometheus service and start the prometheus service.

```shell
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

Check the prometheus service status using the following command.

```shell
sudo systemctl status prometheus
```

The status should show the active state as shown below.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://devopscube.com/wp-content/uploads/2018/08/prometheus-status.png"/>
</div>

### Access Prometheus Web UI

Now you will be able to access the prometheus UI on 9090 port of the prometheus server.

```shell
http://<prometheus-ip>:9090/graph
```

## Install and Configure Grafana

Download the debian package and install dependancies

```shell
sudo apt-get install -y adduser libfontconfig1

wget https://dl.grafana.com/oss/release/grafana_9.3.0_amd64.deb
sudo dpkg -i grafana_9.3.0_amd64.deb
```

#### Configure Grafana

Start and enable the grafana server.

```shell
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

Access grafana UI on port 3000.

```shell
http://<grafana_IP>:3000
```

The default username and password is `admin`. You will be prompted to change the default passsord.

### Add Prometheus Source To Grafana

Note: Make sure Prometheus endpoint is accessible from Grafana server.

Click the “add source” option from the Grafana homepage.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://devopscube.com/wp-content/uploads/2018/09/prometheus-grafana-add-source.png"/>
</div>

Add the source name, Prometheus endpoint details and save it.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://devopscube.com/wp-content/uploads/2018/09/prometheus-grafana-source.png"/>
</div>

### Reference

- [Node Exporter](https://devopscube.com/monitor-linux-servers-prometheus-node-exporter/)
- [Prometheus](https://devopscube.com/install-configure-prometheus-linux/)
- [Grafana](https://devopscube.com/integrate-visualize-prometheus-grafana/)
