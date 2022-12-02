# Deploy a Production Ready Kubernetes Cluster using Kubespray on AWS

> Kubespray is a composition of Ansible playbooks aimed at providing users with a flexible method of deploying a production-grade HA Kubernetes cluster.

## Kubespray

Cloning the Kubespray Repo

```shell
git clone https://github.com/kubernetes-sigs/kubespray.git
```

#### Installing Terraform

> Terraform is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently. This includes low-level components like compute instances, storage, and networking; and high-level components like DNS entries and SaaS features.

```shell
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```

Install the HashiCorp GPG key.

```shell
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Verify the key's fingerprint.

```shell
gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint
```

Add the official HashiCorp repository to your system. The `lsb_release -cs` command finds the distribution release codename for your current system, such as `buster`, `groovy`, or `sid`.

```shell
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```shell
sudo apt update
```

Install Terraform from the new repository.

```shell
sudo apt-get install terraform
```

Verify the installation

```shell
terraform -help
```

### Infrastructure Provisioning

cd in to kubespray/contrib/terraform/aws and rename credentials.tfvars.example to credentials.tfvars

```shell
cd kubespray/contrib/terraform/aws
mv credentials.tfvars.example credentials.tfvars
```

Fill the AWS credential values in `credentials.tfvars` file

Modify the values in `terraform.tfvars` based on your cluster requirements

For ubuntu 22.04 instances replace the debian ami config to ubuntu ami structure in `variables.tf`

```shell
data "aws_ami" "distro" {
most_recent = true

filter {
name   = "name"
values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

filter {
name = "virtualization-type"
values = ["hvm"]
}

owners = ["099720109477"]
}
```

Initialize Terraform and planning steps

```shell
terraform init
terraform plan -out <terraform-plan-name> -var-file=credentials.tfvars
```

Execute the plan

```
terraform apply "<terraform-plan-name>"
```

Wait for the infrastructure to be provisioned.

Verify if instance are running then ssh into bastion and run the following,

```shell
sudo apt update
sudo apt upgrade -y
sudo apt install python3-pip -y
```

Clone the kubespray repo

```shell
git clone https://github.com/kubernetes-sigs/kubespray.git
```

Install Ansible and other dependencies

```shell
cd kubespray
pip install -r requirements.txt
export PATH=/home/ubuntu/.local/bin:$PATH
```

### Setting up Passwordless SSH for Ansible from Bastion

Create `ansible.cfg` in ~/

```shell
[defaults]
inventory = ./inventory
remote_user = ubuntu
```

Create `inventory` file in ~/

Add IP Addresses of all your VMs

```shell
[machines]
<master-ip-addr>
<worker1-ip-addr>
<worker2-ip-addr>
.
.
<workern-ip-addr>
```

Creating Identity Key

```shell
ssh-keygen -t rsa
```

Public key can be found in `/home/ubuntu/.ssh/id_rsa.pub`

Creating Ansible Playbook to automate passwordless ssh. Create `passwordless-ssh.yaml` in ~/

```shell
---
- name: Passwordless SSH
  hosts: all
  tasks:
    - name: Install Key...
      authorized_key:
        user: ubuntu
        state: present
        key: "{{lookup('file','/home/ubuntu/.ssh/id_rsa.pub')}}"
```

Check yaml syntax by

```shell
$ ansible-playbook --syntax-check passwordless-ssh.yaml

playbook: passwordless-ssh.yaml
```

Avoid SSH Asking permission

Uncomment StrictHostKeyChecking and Set `StrictHostKeyChecking no` in your `/etc/ssh/ssh_config` file

```shell
StrictHostKeyChecking no
```

SCP the < key-pair >.pem file to Bastion VM

Run the Playbook

```shell
ansible-playbook passwordless-ssh.yaml --private-key=<key-pair>.pem
```

Copy _inventory/sample_ as _inventory/mycluster_

```
cp -rfp inventory/sample inventory/mycluster
```

Update Ansible inventory file with inventory builder. Include Private IPs of the VMs, and run the command.

```
declare -a IPS=(<master-node> <worker-node-1> <worker-node-2> … <worker-node-n>)
```

Next create inventory file with

```
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

Running the ansible playbook by

```
ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml
```

Setup usually take 10-15 minutes

## Post Setup scripts

SSH into master and run the following commands

```
ssh ubuntu@<master_ip>
mkdir .kube
sudo cp /etc/kubernetes/admin.conf .kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get all
```

### To access the kubernetes cluster through bastion (or any remote machine with ssh access to master)

- Installing kubectl

  ```
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get install -y kubectl
  ```

- SSH into the required VM
  ```
  mkdir ~/.kube
  scp ubuntu@10.250.212.28:~/.kube/config ~/.kube/config
  ```

Replace the server URL within ~/.kube/config of the master node by load balancer’s IP address or Domain, Copy this entire configuration and paste it into Bastion’s ~/.kube/config
