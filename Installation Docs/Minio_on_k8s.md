# Minio Multi Node Multi Drive deployment on Kubernetes (using DirectPV as CSI)

> MinIO is a High Performance Object Storage released under GNU AGPL v3.0. It is API compatible with the Amazon S3 cloud storage service. It can handle unstructured data such as photos, videos, log files, backups, and container images with a current maximum supported object size of 5TB.

Minio Kubernetes Architecture, learn [more](https://min.io/product/kubernetes)

<div  style="align:center; margin-left:auto; margin-right:auto">
<img  src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/Minio_k8s_arch.svg"/>
</div>

## Prerequisites

### 1. Kubernetes Version 1.19.0 or above

### 2. Kubernetes TLS Certificate API

To verify whether the `kube-controller-manager` has the required settings, use the following command. Replace `$CLUSTER-NAME` with the name of the Kubernetes cluster:

```shell
kubectl get pod kube-controller-manager-$CLUSTERNAME-control-plane -n kube-system -o yaml
```

Confirm that the output contains values for `--cluster-signing-cert-file` and `--cluster-signing-key-file`. The output of the example command above may differ from the output in your terminal:

     spec:
     containers:
     - command:
         - kube-controller-manager
         - --allocate-node-cidrs=true
         - --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
         - --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
         - --bind-address=127.0.0.1
         - --client-ca-file=/etc/kubernetes/pki/ca.crt
         - --cluster-cidr=10.244.0.0/16
         - --cluster-name=my-cluster-name
    	 - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
    	 - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key

### 3. MinIO Kubernetes Plugin (using Krew Plugin Manager)

Krew is a `kubectl` plugin manager developed by the [Kubernetes SIG CLI group](https://github.com/kubernetes-sigs). Make sure you have `krew` installed, if not install it using :

Run this command to download and install `krew`:

```shell
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```

Add the `$HOME/.krew/bin` directory to your PATH environment variable. To do this, update your `.bashrc` or `.zshrc` file and append the following line:

```shell
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

Run `kubectl krew` to check the installation.

Use Krew to install the MinIO `kubectl` plugin using the following commands:

```shell
kubectl krew update
kubectl krew install minio
```

If you want to update the MinIO plugin with Krew, use the following command:

```shell
kubectl krew upgrade minio
```

You can validate the installation of the MinIO plugin using the following command:

```shell
kubectl minio version
```

### 4. Persistent Volumes (using DirectPV CSI)

For Kubernetes clusters where nodes have Direct Attached Storage, MinIO strongly recommends using the [DirectPV CSI driver](https://min.io/directpv?ref=docs). DirectPV provides a distributed persistent volume manager that can discover, format, mount, schedule, and monitor drives across Kubernetes nodes. DirectPV addresses the limitations of manually provisioning and monitoring [local persistent volumes](https://kubernetes.io/docs/concepts/storage/volumes/#local).

Install the `kubectl` DirectPV plugin.

```shell
kubectl krew install directpv
```

Use the plugin to install DirectPV in your Kubernetes cluster.

```shell
kubectl directpv install
```

Ensure that DirectPV has successfully started.

```shell
$ kubectl directpv info
 NODE    CAPACITY  ALLOCATED  VOLUMES  DRIVES
 • k8-1  -         -          -        -
 • k8-2  -         -          -        -
 • k8-3  -         -          -        -
 • k8-4  40 GiB    30 GiB     4        4
 • k8-5  40 GiB    30 GiB     4        4
 • k8-6  40 GiB    30 GiB     4        4
 • k8-7  40 GiB    30 GiB     4        4

120 GiB/160 GiB used, 17 volumes, 16 drives
```

In my scenario, I have a kubernetes cluster with 3 master, 4 worker nodes. Where each worker has 4 drives of 10GB each (which can be checked by running `lsblk` command). Your output for `kubectl directpv info` can be different.

List the available drives in your cluster.

```shell
$ kubectl directpv drives ls
 DRIVE     CAPACITY  ALLOCATED  FILESYSTEM  VOLUMES  NODE  ACCESS-TIER  STATUS
 /dev/vdc  10 GiB    -          -           -        k8-4  -            Available
 /dev/vdd  10 GiB    -          -           -        k8-4  -            Available
 /dev/vde  10 GiB    -          -           -        k8-4  -            Available
 /dev/vdf  10 GiB    -          -           -        k8-4  -            Available
 /dev/vdc  10 GiB    -          -           -        k8-5  -            Available
 /dev/vdd  10 GiB    -          -           -        k8-5  -            Available
 /dev/vde  10 GiB    -          -           -        k8-5  -            Available
 /dev/vdf  10 GiB    -          -           -        k8-5  -            Available
 /dev/vdc  10 GiB    -          -           -        k8-6  -            Available
 /dev/vdd  10 GiB    -          -           -        k8-6  -            Available
 /dev/vde  10 GiB    -          -           -        k8-6  -            Available
 /dev/vdf  10 GiB    -          -           -        k8-6  -            Available
 /dev/vdc  10 GiB    -          -           -        k8-7  -            Available
 /dev/vdd  10 GiB    -          -           -        k8-7  -            Available
 /dev/vde  10 GiB    -          -           -        k8-7  -            Available
 /dev/vdf  10 GiB    -          -           -        k8-7  -            Available
```

Learn more about [DirectPV](https://min.io/directpv)
Learn more about various [DirectPV CLI commands](https://github.com/minio/directpv/blob/master/docs/cli.md)

## Minio Operator

The MinIO Kubernetes Operator supports deploying MinIO Tenants onto private and public cloud infrastructures (“Hybrid” Cloud).

### Initialize the MinIO Kubernetes Operator

Run the following command to initialize the MinIO Operator:

```shell
kubectl  minio  init
```

### Validate the Operator Installation

To verify the installation, run the following command:

```
$ kubectl get all --namespace <minio-operator-namespace>
NAME                                  READY   STATUS    RESTARTS   AGE
pod/console-56f9795d5c-jmtkr          1/1     Running   0          4d9h
pod/minio-operator-7cd6784f59-28rjn   1/1     Running   0          4d9h
pod/minio-operator-7cd6784f59-9wvsf   1/1     Running   0          4d9h

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/console      ClusterIP   10.233.33.220   <none>        9090/TCP,9443/TCP   4d9h
service/operator     ClusterIP   10.233.30.132   <none>        4222/TCP,4221/TCP   4d9h

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/console          1/1     1            1           4d9h
deployment.apps/minio-operator   2/2     2            2           4d9h

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/console-56f9795d5c          1         1         1       4d9h
replicaset.apps/minio-operator-7cd6784f59   2         2         2       4d9h
```

### Open the Operator Console

Run the `kubectl  minio  proxy` command to **temporarily** forward traffic from the MinIO Operator Console service to your local machine.

The JWT Token will be required to login into the Minio Operator Console. It need not be stored or remembered, as we can run `kubectl minio proxy` command every time we need to login into Minio Operator Console, and enter the newly created JWT Token each time.

As `kubectl minio proxy` temporarily forward traffic from the MinIO Operator Console service to your local machine, We can't rely on this for frequent usage, We can deploy a NodePort Service to expose the port.

```shell
# console-np.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    name: console-np
    app.kubernetes.io/instance: minio-operator
    app.kubernetes.io/name: operator
  name: console-np
  namespace: minio-operator
spec:
  type: NodePort
  ports:
    - name: http
      protocol: TCP
      port: 9090
      nodePort: 30000
  selector:
    app: console
```

Apply the config, after which we will be able to access Minio Operator Console at `http://localhost:30000`

```shell
kubectl apply -f console-np.yaml
```

<div  style="align:center; margin-left:auto; margin-right:auto">
<img  src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/minio-operator-console.png"/>
</div>

## Minio Tenants

The MinIO Kubernetes Operator supports deploying and managing MinIO Tenants onto your Kubernetes cluster through either the Operator Console web interface or the MinIO Kubernetes Plugin.

### Lets get our PVs and Storage Class ready!

Based on the output of `kubectl directpv drives ls`, In my case drive names span over /dev/vd{c...f} and nodes as k8-{4...7}

To format these drives and make them usable, run

```shell
kubectl directpv drives format --drives /dev/vd{c...f} --nodes k8-{4...7}
```

After sometime, when we check the status of these Volumes

```shell
$ kubectl directpv drives ls
 DRIVE     CAPACITY  ALLOCATED  FILESYSTEM  VOLUMES  NODE  ACCESS-TIER  STATUS
 /dev/vdc  10 GiB    -          xfs         -        k8-4  -            Ready
 /dev/vdd  10 GiB    -          xfs         -        k8-4  -            Ready
 /dev/vde  10 GiB    -          xfs         -        k8-4  -            Ready
 /dev/vdf  10 GiB    -          xfs         -        k8-4  -            Ready
 /dev/vdc  10 GiB    -          xfs         -        k8-5  -            Ready
 /dev/vdd  10 GiB    -          xfs         -        k8-5  -            Ready
 /dev/vde  10 GiB    -          xfs         -        k8-5  -            Ready
 /dev/vdf  10 GiB    -          xfs         -        k8-5  -            Ready
 /dev/vdc  10 GiB    -          xfs         -        k8-6  -            Ready
 /dev/vdd  10 GiB    -          xfs         -        k8-6  -            Ready
 /dev/vde  10 GiB    -          xfs         -        k8-6  -            Ready
 /dev/vdf  10 GiB    -          xfs         -        k8-6  -            Ready
 /dev/vdc  10 GiB    -          xfs         -        k8-7  -            Ready
 /dev/vdd  10 GiB    -          xfs         -        k8-7  -            Ready
 /dev/vde  10 GiB    -          xfs         -        k8-7  -            Ready
 /dev/vdf  10 GiB    -          xfs         -        k8-7  -            Ready
```

Now are Persistent Volumes are ready to be used.

**Configuring Storage class**

When we install DirectPV in our Kubernetes cluster using `kubectl directpv install`, It installs Storage Classes like `directpv-min-io`. To check if Storage class is correctly configured, run :

```shell
$ kubectl get sc
NAME                PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
direct-csi-min-io   direct-csi-min-io              Delete          WaitForFirstConsumer   false                  3d19h
directpv-min-io     direct-csi-min-io              Delete          WaitForFirstConsumer   false                  3d19h
```

Now that we have our PV and Storage class configured. Lets create Minio Tenants.

### Deploy a MinIO Tenant using the Command Line

Lets look at the resources at hand, I have a 3 master, 4 worker node k8s cluster, which has 4 Persistent Volumes of 10GB each in each of the worker nodes. I plan to deploy 2 tenants, each with 2 servers (nodes), 8 volumes in total (which mean all of the volumes in 2 nodes), with total size of 60GB and `directpv-min-io` as our storage class.

Now you might ask, why didn't I use complete 80GB instead of just using 60GB ?
When DirectPV formats a drive, its total usable size reduces, and some size if occupied by filesytem metadata, inodes, etc. which is normal for xfs file system.

Creating Namespace for Minio Tenant

```shell
kubectl create namespace minio-tenant-1-namespace
```

Creating a Minio Tenant

```shell
kubectl minio tenant create minio-tenant-1 --servers 2 --volumes 8 --capacity 60Gi --namespace minio-tenant-1-namespace --enable-prometheus=false --enable-audit-logs=false --disable-tls --storage-class directpv-min-io
```

Learn about more parameters which can be passed to create a Minio Tenant [here](https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-minio-tenant.html#determine-values-for-required-settings)

While deploying the Minio Tenant through CLI, you will get credentials to access the Tenant Console, such as :

    ...
    Tenant 'minio-tenant-1' created in 'minio-tenant-1-namespace' Namespace

    Username: SNP01YZ23JWHRV8RSWST
    Password: Dka5O8XDxBeGZ7QHoYs1L5HsDjZFns64EbrjemD0
    ...

**Note: Copy the credentials to a secure location. MinIO will not display these again.**

Verify whether the Tenant is successfully deployed, you should get a similar output:

```shell
$ kubectl get all -n minio-tenant-1-namespace
NAME                        READY   STATUS    RESTARTS   AGE
pod/minio-tenant-1-ss-0-0   1/1     Running   0          3d10h
pod/minio-tenant-1-ss-0-1   1/1     Running   0          3d10h

NAME                             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/minio                    ClusterIP   10.233.34.130   <none>        80/TCP           3d10h
service/minio-tenant-1-console   ClusterIP   10.233.56.191   <none>        9090/TCP         3d10h
service/minio-tenant-1-hl        ClusterIP   None            <none>        9000/TCP         3d10h

NAME                                   READY   AGE
statefulset.apps/minio-tenant-1-ss-0   2/2     3d10h
```

We can expose the `service/minio-tenant-1-console`, using NodePort Service, following is the config for it :

```shell
# tenant1-np.yaml
apiVersion: v1
kind: Service
metadata:
  name: tenant1-np
  namespace: minio-tenant-1-namespace
  labels:
    name: tenant1-np
    v1.min.io/console: minio-tenant-1-console
spec:
  type: NodePort
  ports:
    - name: http
      protocol: TCP
      port: 9090
      nodePort: 30001
  selector:
    v1.min.io/tenant: minio-tenant-1
```

Apply the config, after which we will be able to access Minio Tenant-1 Console at `http://localhost:30001`

```shell
kubectl apply -f tenant1-np.yaml
```

<div  style="align:center; margin-left:auto; margin-right:auto">
<img  src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/tenant1-console.png"/>
</div>

**Similarly deploying tenant-2**

```shell
# Creation of namespace
kubectl create namespace minio-tenant-2-namespace

# Deploying Minio tenant
kubectl minio tenant create minio-tenant-2 --servers 2 --volumes 8 --capacity 60Gi --namespace minio-tenant-2-namespace --enable-prometheus=false --enable-audit-logs=false --disable-tls --storage-class directpv-min-io
```

Status of Volumes after both tenant (tenant-1, tenant-2) creation.

```shell

 DRIVE     CAPACITY  ALLOCATED  FILESYSTEM  VOLUMES  NODE  ACCESS-TIER  STATUS
 /dev/vdc  10 GiB    7.5 GiB    xfs         1        k8-4  -            InUse
 /dev/vdd  10 GiB    7.5 GiB    xfs         1        k8-4  -            InUse
 /dev/vde  10 GiB    7.5 GiB    xfs         1        k8-4  -            InUse
 /dev/vdf  10 GiB    7.5 GiB    xfs         1        k8-4  -            InUse
 /dev/vdc  10 GiB    7.5 GiB    xfs         1        k8-5  -            InUse
 /dev/vdd  10 GiB    7.5 GiB    xfs         1        k8-5  -            InUse
 /dev/vde  10 GiB    7.5 GiB    xfs         1        k8-5  -            InUse
 /dev/vdf  10 GiB    7.5 GiB    xfs         1        k8-5  -            InUse
 /dev/vdc  10 GiB    7.5 GiB    xfs         1        k8-6  -            InUse
 /dev/vdd  10 GiB    7.5 GiB    xfs         1        k8-6  -            InUse
 /dev/vde  10 GiB    7.5 GiB    xfs         1        k8-6  -            InUse
 /dev/vdf  10 GiB    7.5 GiB    xfs         1        k8-6  -            InUse
 /dev/vdc  10 GiB    7.5 GiB    xfs         1        k8-7  -            InUse
 /dev/vdd  10 GiB    7.5 GiB    xfs         1        k8-7  -            InUse
 /dev/vde  10 GiB    7.5 GiB    xfs         1        k8-7  -            InUse
 /dev/vdf  10 GiB    7.5 GiB    xfs         1        k8-7  -            InUse
```

**Restoring the PVs**

We can release all `InUse` PVs by :

```shell
kubectl directpv drives release --all
```

And force format the Volumes, and get them back in `Ready` state by :

```shell
kubectl directpv drives format --drives /dev/vd{c...f} --nodes k8-{4...7} --force
```
