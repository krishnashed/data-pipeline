# Installing Longhorn on Kubernetes using kubectl

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

Install Longhorn on any Kubernetes cluster using this command:

```shell
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
```

Check that the deployment was successful:

```shell
$ kubectl -n longhorn-system get pod
NAME                                        READY     STATUS    RESTARTS   AGE
csi-attacher-6fdc77c485-8wlpg               1/1       Running   0          9d
csi-attacher-6fdc77c485-psqlr               1/1       Running   0          9d
csi-attacher-6fdc77c485-wkn69               1/1       Running   0          9d
csi-provisioner-78f7db7d6d-rj9pr            1/1       Running   0          9d
csi-provisioner-78f7db7d6d-sgm6w            1/1       Running   0          9d
csi-provisioner-78f7db7d6d-vnjww            1/1       Running   0          9d
engine-image-ei-6e2b0e32-2p9nk              1/1       Running   0          9d
engine-image-ei-6e2b0e32-s8ggt              1/1       Running   0          9d
engine-image-ei-6e2b0e32-wgkj5              1/1       Running   0          9d
longhorn-csi-plugin-g8r4b                   2/2       Running   0          9d
longhorn-csi-plugin-kbxrl                   2/2       Running   0          9d
longhorn-csi-plugin-wv6sb                   2/2       Running   0          9d
longhorn-driver-deployer-788984b49c-zzk7b   1/1       Running   0          9d
longhorn-manager-nr5rs                      1/1       Running   0          9d
longhorn-manager-rd4k5                      1/1       Running   0          9d
longhorn-manager-snb9t                      1/1       Running   0          9d
longhorn-ui-67b9b6887f-n7x9q                1/1       Running   0          9d
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
