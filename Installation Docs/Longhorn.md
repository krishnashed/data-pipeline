# Installing Longhorn on Kubernetes using helm

> Cloud native distributed block storage for Kubernetes

## Prerequisites

Each node in the Kubernetes cluster where Longhorn is installed must fulfill the following requirements:

- Docker v1.13+
- Kubernetes v1.14+.

By default Longhorn installation requires a three-nodes cluster since the default replica count is 3 and the node level soft anti-affinity is disabled.

- `open-iscsi` is installed, and the `iscsid` daemon is running on all the nodes. For help installing open-iscsi, refer to this section.
- The host filesystem supports the `file extents` feature to store the data. Currently we support:
  ext4
  XFS
- `curl`, `findmnt`, `grep`, `awk`, `blkid`, `lsblk` must be installed.
- Mount propagation must be enabled.

### Installing open-iscsi

For Debian and Ubuntu, use this command:

```shell
sudo apt-get install open-iscsi
```

### Using the Environment Check Script

A script to help you gather enough information about the factors. Before installing, run:

```shell
$ curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/master/scripts/environment_check.sh | bash

daemonset.apps/longhorn-environment-check created
waiting for pods to become ready (0/3)
all pods ready (3/3)

  MountPropagation is enabled!

cleaning up...
daemonset.apps "longhorn-environment-check" deleted
clean up complete
```

## Longhorn Architecture

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/longhorn-architecture.svg"/>
</div>

## Installing Longhorn

Add the Longhorn Helm repository:

```shell
helm repo add longhorn https://charts.longhorn.io
```

Fetch the latest charts from the repository:

```shell
helm repo update
```

Install Longhorn in the `longhorn-system` namespace.

```shell
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.1
```

Check that the deployment was successful:

```shell
$ kubectl -n longhorn-system get pod
NAME                                           READY   STATUS    RESTARTS   AGE
longhorn-ui-b7c844b49-w25g5                    1/1     Running   0          2m41s
longhorn-conversion-webhook-5dc58756b6-9d5w7   1/1     Running   0          2m41s
longhorn-conversion-webhook-5dc58756b6-jp5fw   1/1     Running   0          2m41s
longhorn-admission-webhook-8b7f74576-rbvft     1/1     Running   0          2m41s
longhorn-admission-webhook-8b7f74576-pbxsv     1/1     Running   0          2m41s
longhorn-manager-pzgsp                         1/1     Running   0          2m41s
longhorn-driver-deployer-6bd59c9f76-lqczw      1/1     Running   0          2m41s
longhorn-csi-plugin-mbwqz                      2/2     Running   0          100s
csi-snapshotter-588457fcdf-22bqp               1/1     Running   0          100s
csi-snapshotter-588457fcdf-2wd6g               1/1     Running   0          100s
csi-provisioner-869bdc4b79-mzrwf               1/1     Running   0          101s
csi-provisioner-869bdc4b79-klgfm               1/1     Running   0          101s
csi-resizer-6d8cf5f99f-fd2ck                   1/1     Running   0          101s
csi-provisioner-869bdc4b79-j46rx               1/1     Running   0          101s
csi-snapshotter-588457fcdf-bvjdt               1/1     Running   0          100s
csi-resizer-6d8cf5f99f-68cw7                   1/1     Running   0          101s
csi-attacher-7bf4b7f996-df8v6                  1/1     Running   0          101s
csi-attacher-7bf4b7f996-g9cwc                  1/1     Running   0          101s
csi-attacher-7bf4b7f996-8l9sw                  1/1     Running   0          101s
csi-resizer-6d8cf5f99f-smdjw                   1/1     Running   0          101s
instance-manager-r-371b1b2e                    1/1     Running   0          114s
instance-manager-e-7c5ac28d                    1/1     Running   0          114s
engine-image-ei-df38d2e5-cv6nc                 1/1     Running   0          114s
```

### Accessing the Longhorn UI

Exposing the `longhorn-frontend` service using NodePort:

```shell
apiVersion: v1
kind: Service
metadata:
  labels:
    name: longhorn-ui-np
    app.kubernetes.io/instance: longhorn
    app.kubernetes.io/name: longhorn
  name: longhorn-ui-np
  namespace: longhorn-system
spec:
  type: NodePort
  ports:
    - name: http
      protocol: TCP
      port: 8000
      nodePort: 30100
  selector:
    app: longhorn-ui
```

Navigate to `http://localhost:30100` in your browser.

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/longhorn-ui.png"/>
</div>

### Create Longhorn Volumes

Creating Kubernetes persistent storage resources of persistent volumes (PVs) and persistent volume claims (PVCs) that correspond to Longhorn volumes.

By installing Longhorn, we get a default storage class as

```shell
$ kubectl get sc
NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
longhorn (default)   driver.longhorn.io   Delete          Immediate           true                   20d
```

The Longhorn StorageClass contains the parameters to provision PVs.

Next, a PersistentVolumeClaim is created that references the StorageClass. Finally, the PersistentVolumeClaim is mounted as a volume within a Pod.

When the Pod is deployed, the Kubernetes master will check the PersistentVolumeClaim to make sure the resource request can be fulfilled. If storage is available, the Kubernetes master will create the Longhorn volume and bind it to the Pod.

Create a Pod that uses Longhorn volumes by running this command:

```shell
kubectl create -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.1/examples/pod_with_pvc.yaml
```

A Pod named `volume-test` is launched, along with a PersistentVolumeClaim named `longhorn-volv-pvc`. The PersistentVolumeClaim references the Longhorn StorageClass:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: longhorn-volv-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 2Gi
```

The persistentVolumeClaim is mounted in the Pod as a volume:

```
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
  namespace: default
spec:
  containers:
  - name: volume-test
    image: nginx:stable-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: volv
      mountPath: /data
    ports:
    - containerPort: 80
  volumes:
  - name: volv
    persistentVolumeClaim:
      claimName: longhorn-volv-pvc
```

### Deleting Volumes Through Kubernetes

> Note: This method only works if the volume was provisioned by a StorageClass and the PersistentVolume for the Longhorn volume has its Reclaim Policy set to Delete.

You can delete a volume through Kubernetes by deleting the PersistentVolumeClaim that uses the provisioned Longhorn volume. This will cause Kubernetes to clean up the PersistentVolume and then delete the volume in Longhorn.

### Create a Snapshot

A snapshot is the state of a Kubernetes Volume at any given point in time.

To create a snapshot of an existing cluster,

1. In the top navigation bar of the Longhorn UI, click Volume.
2. Click the name of the volume of which you want a snapshot. This leads to the volume detail page.
3. Click the Take Snapshot button

Once the snapshot is created you’ll see it in the list of snapshots for the volume prior to the Volume Head.
