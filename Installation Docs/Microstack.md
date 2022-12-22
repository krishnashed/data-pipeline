# Installing Microstack as Single-node deployment on Ubuntu

> Microstack is a free, open standard cloud computing platform. It is mostly deployed as infrastructure-as-a-service in both public and private clouds where virtual servers and other resources are made available to users.

## Prerequisites
-  You will need a multi-core processor and at least 8 GiB of memory and 100 GiB of disk space. 
- MicroStack has been tested on x86-based physical and virtual (KVM) machines running either Ubuntu 18.04 LTS or Ubuntu 20.04 LTS.


## Installation

The installation step consists solely of installing the MicroStack snap.


```shell
sudo snap install microstack --beta
```

If snap isn't installed. Install snap using 
```shell
sudo apt install snapd
```

## Initialization

The initialisation step automatically deploys, configures, and starts OpenStack services. In particular, it will create the database, networks, an image, several flavors, and ICMP/SSH security groups. This can all be done within 10 to 20 minutes depending on your machine:

```shell
sudo microstack init --auto --control
```

Query Openstack

The standard openstack client comes pre-installed and 
is invoked like so:

```shell
microstack.openstack <command>
```

Create an alias to remove the need to type the `microstack.` prefix when using the `openstack` CLI client

```shell
sudo snap alias microstack.openstack openstack
```

## Exploring Microstack

To list the default images available:
```shell
openstack image list
```

To get the default list of flavors:

```shell
openstack flavor list
```

As microstack comes with a very minimal `cirros` by default. Lets add Ubuntu Image for our usage

- Storing images in folder `/var/snap/microstack/common/images/`
- Find the latest Images at [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)

```shell
cd /var/snap/microstack/common/images/

sudo wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

To upload the Ubuntu image to Glance, execute the following command:

```shell
openstack image create \
    --container-format bare \
    --disk-format qcow2 \
    --file jammy-server-cloudimg-amd64.img \
    Ubuntu-22.04
```

Launching the recently created Ubuntu image with m1.medium as flavour which has 4 vCPUs, 8 GiB RAM

```shell
microstack launch -f m1.medium Ubuntu-22.04  
```

Access the instance using the private SSH key associated with the default keypair:

```shell
ssh -i /home/ubuntu/snap/microstack/common/.ssh/id_microstack ubuntu@<ip-address>
```

## Access the cloud dashboard
You can log in to the web UI by accessing Public IP of your Bare metal ( Host VM )

```shell
https://<public-ip>
```

The username is ‘admin’ and the password is obtained in this way:
```shell
sudo snap get microstack config.credentials.keystone-password
```

Sample password:
```
OAEHxLgCBz7Wz4usvolAAt61TrDUz6zz
```

Upon logging in you should see the created instance:

<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/Created%20Instance.png">


To enable access to internet within the virtually created VMs, within your Host VM, run the following:

```shell
sudo iptables -t nat -A POSTROUTING -s 10.20.20.1/24 ! -d 10.20.20.1/24 -j MASQUERADE

sudo sysctl net.ipv4.ip_forward=1
```
Above commands enable IP forwarding and configure network address translation (NAT) on a Linux machine.

## Accessing services running within virtualized VMs (Guest VM) from Host VM

Lets suppose I have a [Prometheus Node Exporter](https://prometheus.io/docs/guides/node-exporter/) service running within my Guest VM on port number 9100.

I want to access it from my Host VM. We need to modify security groups so that guest VM will listen to external traffic on port 9100

Creating security groups, From the Host VM run:

```shell
openstack security group create allow-9100
```
Access the UI at Public IP of your Host VM, and go to `/project/security_groups/` where you'll be able to see the newly created security group

<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/Security-groups.png">

Click on `Manage rules`, and then `Add Rule` to create rules in security group

<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/Adding%20rules%20in%20seurity%20group.png">

After Adding the rule in security group, we need to Add newly created Security group to Instance. Head over to `/project/instances/` in UI, and select `Edit Security Groups` for the created Instance

<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/Adding%20Security%20group%20to%20Instance.png">

Click on the `+` button infront of `allow-9100` security group, to ad it to Instace Security Groups. And Save.

<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/adding%20group%20to%20instance.png">

<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/added%20group%20to%20instance.png">

Now we can access the Node exporter outside the Guest VM on `http://<Guest-Public-IP>:9100/metrics`

To access Guest VM services from Internet we will have to map port of Guest VM and Host VM, and do Port Forwarding using NGINX.

So that services can now be accessible to world at e.g `http://<Host-Public-IP>:9100/metrics`

## References

- https://microstack.run/docs/single-node
- https://dev.to/donaldsebleung/introduction-to-openstack-with-microstack-1f5j
- https://docs.openstack.org/ocata/user-guide/cli-cheat-sheet.html
- https://docs.openstack.org/ocata/user-guide/cli-nova-configure-access-security-for-instances.html
