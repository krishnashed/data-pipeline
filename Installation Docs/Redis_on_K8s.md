# Deploying Redis on Kubernetes using Redis® Cluster Bitnami helm chart

> Redis is an open source, in-memory data store used by millions of developers as a database, cache, streaming engine, and message broker.

## Introduction

Bitnami's chart bootstraps a Redis® deployment on a Kubernetes cluster using the Helm package manager.

Choose between Redis® Helm Chart and Redis® Cluster Helm Chart

You can choose any of the two Redis® Helm charts for deploying a Redis® cluster. While Redis® Helm Chart will deploy a master-slave cluster using Redis® Sentinel, the Redis® Cluster Helm Chart will deploy a Redis® Cluster with sharding. The main features of each chart are the following:

| Redis&reg;                                    | Redis&reg; Cluster                                            |
| --------------------------------------------- | ------------------------------------------------------------- |
| Supports multiple databases                   | Supports only one database. Better if you have a big dataset  |
| Single write point (single master)            | Multiple write points (multiple masters)                      |
| ![Redis® Topology](images/redis-topology.png) | ![Redis® Cluster Topology](images/redis-cluster-topology.png) |

Learn more at https://docs.bitnami.com/kubernetes/infrastructure/redis/get-started/compare-solutions/

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

Get values.yaml for Redis Cluster chart.

```shell
wget https://raw.githubusercontent.com/bitnami/charts/main/bitnami/redis-cluster/values.yaml
```

To install the chart with the release name redis:

```shell
helm install redis -f values.yaml oci://registry-1.docker.io/bitnamicharts/redis-cluster -n redis --create-namespace
```

> Note: We can edit the Cluster config by changing fields in values.yaml, such as cluster config, volume persistence, storageclass, etc. To successfully set the cluster up, it will need to have at least 3 master nodes. The total number of nodes is calculated like- nodes = numOfMasterNodes + numOfMasterNodes \* replicas. Hence, the defaults cluster.nodes = 6 and cluster.replicas = 1 means, 3 master and 3 replica nodes will be deployed by the chart.

Verify the deployment

```shell
$ kubectl get all -n redis
NAME                        READY   STATUS    RESTARTS   AGE
pod/redis-redis-cluster-0   1/1     Running   0          42s
pod/redis-redis-cluster-1   1/1     Running   0          42s
pod/redis-redis-cluster-2   1/1     Running   0          42s
pod/redis-redis-cluster-3   1/1     Running   0          42s
pod/redis-redis-cluster-4   1/1     Running   0          42s
pod/redis-redis-cluster-5   1/1     Running   0          42s

NAME                                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)              AGE
service/redis-redis-cluster            ClusterIP   10.233.53.61   <none>        6379/TCP             42s
service/redis-redis-cluster-headless   ClusterIP   None           <none>        6379/TCP,16379/TCP   42s

NAME                                   READY   AGE
statefulset.apps/redis-redis-cluster   6/6     42s
```

To get `REDIS_PASSWORD` run:

```shell
export REDIS_PASSWORD=$(kubectl get secret --namespace "redis" redis-redis-cluster -o jsonpath="{.data.redis-password}" | base64 -d)
```

## Connecting to Redis Cluster

To connect to your Redis&reg; cluster:

1. Run a Redis&reg; pod that you can use as a client:

```shell
kubectl run --namespace redis redis-redis-cluster-client --rm --tty -i --restart='Never' \
 --env REDIS_PASSWORD=$REDIS_PASSWORD \
--image docker.io/bitnami/redis-cluster:7.0.11-debian-11-r0 -- bash
```

2. Connect using the Redis&reg; CLI:

```shell
redis-cli -c -h redis-redis-cluster -a $REDIS_PASSWORD
```

Such as

```bash
$ kubectl run --namespace redis redis-redis-cluster-client --rm --tty -i --restart='Never' \
--env REDIS_PASSWORD=$REDIS_PASSWORD \
--image docker.io/bitnami/redis-cluster:7.0.11-debian-11-r0 -- bash
If you don't see a command prompt, try pressing enter.
I have no name!@redis-redis-cluster-client:/$ redis-cli -c -h redis-redis-cluster -a $REDIS_PASSWORD
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
redis-redis-cluster:6379>
```

Verify working of Redis Cluster

```shell
redis-redis-cluster:6379> set name krishna
OK
redis-redis-cluster:6379> get name
"krishna"
redis-redis-cluster:6379> exit
I have no name!@redis-redis-cluster-client:/$ exit
exit
pod "redis-redis-cluster-client" deleted
```

## Scaling Up/Down the Redis Cluster

### Scaling up

There is a job that will be executed using a post-upgrade hook that will allow you to add a new node. To use it, you should provide some parameters to the upgrade:

- Pass as `password` the password used in the installation time. If you did not provide a password follow the instructions from the NOTES.txt to get the generated password.
- Set the desired number of nodes at `cluster.nodes`.
- Set the number of current nodes at `cluster.update.currentNumberOfNodes`.
- Set to true `cluster.update.addNodes`.

> NOTE: To avoid the creation of the Job that initializes the Redis® Cluster again, you will need to provide cluster.init=false.

Lets change the state of Redis cluster, from {nodes:6, replicas:1} to {nodes:8, replicas:2}

Changes to be made in `values.yaml`

```yaml
cluster:
  init: false
  nodes: 8
  replicas: 2

  update:
    addNodes: true
```

Apply the changes

```shell
helm upgrade -f values.yaml redis oci://registry-1.docker.io/bitnamicharts/redis-cluster --set password=$REDIS_PASSWORD -n redis
```

Wait until the cluster reshards. i.e.

1. Until all 8 of the `redis-redis-cluster` pods are in 1/1 Running State
2. `statefulset.apps/redis-redis-cluster` is 8/8 Ready
3. `job.batch/redis-redis-cluster-cluster-update` reaches 1/1 COMPLETIONS
4. `pod/redis-redis-cluster-cluster-update` is in 0/1 Completed State.

```shell
$ kubectl get all -n redis
NAME                                           READY   STATUS      RESTARTS   AGE
pod/redis-redis-cluster-0                      1/1     Running     0          2m22s
pod/redis-redis-cluster-1                      1/1     Running     0          3m12s
pod/redis-redis-cluster-2                      1/1     Running     0          3m32s
pod/redis-redis-cluster-3                      1/1     Running     0          3m46s
pod/redis-redis-cluster-4                      1/1     Running     0          4m1s
pod/redis-redis-cluster-5                      1/1     Running     0          4m11s
pod/redis-redis-cluster-6                      1/1     Running     0          4m44s
pod/redis-redis-cluster-7                      1/1     Running     0          4m44s
pod/redis-redis-cluster-client                 1/1     Running     0          4m1s
pod/redis-redis-cluster-cluster-update-4ddr7   0/1     Completed   0          4m44s

NAME                                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)              AGE
service/redis-redis-cluster            ClusterIP   10.233.53.61   <none>        6379/TCP             29m
service/redis-redis-cluster-headless   ClusterIP   None           <none>        6379/TCP,16379/TCP   29m

NAME                                   READY   AGE
statefulset.apps/redis-redis-cluster   8/8     29m

NAME                                           COMPLETIONS   DURATION   AGE
job.batch/redis-redis-cluster-cluster-update   1/1           31s        4m44
```

Now lets check if the `key` set previously is still available or not, by connecting to the redis cluster.

```shell
redis-redis-cluster:6379> get name
-> Redirected to slot [5798] located at 10.233.75.39:6379
"krishna"
```

You can observe that data in Redis cluster has been resharded to accomodate the new state of Redis cluster {nodes: 8, replicas:2}

Lets also check details of Redis Nodes, we need it to understand state changes while scaling down the Redis cluster

```shell
redis-redis-cluster:6379> CLUSTER NODES
8890cba2e6c6e4a20e55c778943cd5af983deb89 10.233.100.168:6379@16379 slave 350ccb14d34b6f14ba18f12ebbc856537297d9dd 0 1682588968674 3 connected
d0bcc789047c06d2902767f96882afc61bca1b2b 10.233.90.49:6379@16379 slave 61e811e81ec79051291b937df582c7547ceede93 0 1682588969000 1 connected
07654fb0f1e37c24960e3a3cf424533cfa9f6ad7 10.233.71.16:6379@16379 slave 61e811e81ec79051291b937df582c7547ceede93 0 1682588969679 1 connected
ffeafd7d99283e9d26e36fe234ea8b9d7fde2c76 10.233.74.92:6379@16379 slave d429665ee330391b723c9c431eb0b18fbaef59f2 0 1682588969000 2 connected
d429665ee330391b723c9c431eb0b18fbaef59f2 10.233.75.43:6379@16379 master - 0 1682588969000 2 connected 5461-10922
6612cd6e4a3d7a9d09ea0e1259e4dada39da636f 10.233.75.81:6379@16379 slave d429665ee330391b723c9c431eb0b18fbaef59f2 0 1682588969000 2 connected
61e811e81ec79051291b937df582c7547ceede93 10.233.111.235:6379@16379 myself,master - 0 1682588970000 1 connected 0-5460
350ccb14d34b6f14ba18f12ebbc856537297d9dd 10.233.97.161:6379@16379 master - 0 1682588970684 3 connected 10923-16383
```

### Scaling down

First perform a normal upgrade setting the `cluster.nodes` value to the desired number of nodes. It should not be less than `6` and the difference between current number of nodes and the desired should be less or equal to `cluster.replicas` to avoid removing master node an its slaves at the same time. Also it is needed to provide the password using the `password`. For example, having more than 6 nodes, to scale down the cluster to 6 nodes:

So lets scale down our cluster to its initial state of {nodes: 6, replicas: 1}

Changes to be made in `values.yaml`

```yaml
cluster:
  init: false
  nodes: 6
  replicas: 1

  update:
    addNodes: false
    currentNumberOfNodes: 8
    currentNumberOfReplicas: 2
```

> NOTE: To avoid the creation of the Job that initializes the Redis® Cluster again, you will need to provide cluster.init=false.

Apply the changes

```shell
helm upgrade -f values.yaml redis oci://registry-1.docker.io/bitnamicharts/redis-cluster --set password=$REDIS_PASSWORD -n redis
```

The state of cluster will be:

```shell
$ kubectl get all -n redis
NAME                                           READY   STATUS      RESTARTS   AGE
pod/redis-redis-cluster-0                      1/1     Running     0          72s
pod/redis-redis-cluster-1                      1/1     Running     0          87s
pod/redis-redis-cluster-2                      1/1     Running     0          102s
pod/redis-redis-cluster-3                      1/1     Running     0          118s
pod/redis-redis-cluster-4                      1/1     Running     0          2m16s
pod/redis-redis-cluster-5                      1/1     Running     0          2m33s
pod/redis-redis-cluster-cluster-update-4ddr7   0/1     Completed   0          22m

NAME                                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)              AGE
service/redis-redis-cluster            ClusterIP   10.233.53.61   <none>        6379/TCP             47m
service/redis-redis-cluster-headless   ClusterIP   None           <none>        6379/TCP,16379/TCP   47m

NAME                                   READY   AGE
statefulset.apps/redis-redis-cluster   6/6     47m

NAME                                           COMPLETIONS   DURATION   AGE
job.batch/redis-redis-cluster-cluster-update   1/1           31s        22m
```

Once all the nodes are ready, get the list of nodes in the cluster using the `CLUSTER NODES` command. You will see references to the ones that were removed. Write down the node IDs of the nodes that show `fail`. In the following example the cluster scaled down from 8 to 6 nodes.

Connect to the Redis cluster, and run

```shell
redis-redis-cluster:6379> CLUSTER NODES
ffeafd7d99283e9d26e36fe234ea8b9d7fde2c76 10.233.74.98:6379@16379 slave d429665ee330391b723c9c431eb0b18fbaef59f2 0 1682589918406 2 connected
d0bcc789047c06d2902767f96882afc61bca1b2b 10.233.90.50:6379@16379 master - 0 1682589917402 7 connected 0-5460
350ccb14d34b6f14ba18f12ebbc856537297d9dd 10.233.97.163:6379@16379 master - 0 1682589915393 3 connected 10923-16383
61e811e81ec79051291b937df582c7547ceede93 10.233.111.238:6379@16379 myself,slave d0bcc789047c06d2902767f96882afc61bca1b2b 0 1682589916000 7 connected
07654fb0f1e37c24960e3a3cf424533cfa9f6ad7 10.233.71.16:6379@16379 slave,fail 61e811e81ec79051291b937df582c7547ceede93 1682589606046 1682589606046 1 connected
6612cd6e4a3d7a9d09ea0e1259e4dada39da636f 10.233.75.81:6379@16379 slave,fail d429665ee330391b723c9c431eb0b18fbaef59f2 1682589606046 1682589606046 2 connected
d429665ee330391b723c9c431eb0b18fbaef59f2 10.233.75.27:6379@16379 master - 0 1682589918000 2 connected 5461-10922
8890cba2e6c6e4a20e55c778943cd5af983deb89 10.233.100.160:6379@16379 slave 350ccb14d34b6f14ba18f12ebbc856537297d9dd 0 1682589916000 3 connected
```

In my case the failed nodes are:

```
07654fb0f1e37c24960e3a3cf424533cfa9f6ad7 10.233.71.16:6379@16379 slave,fail 61e811e81ec79051291b937df582c7547ceede93 1682589606046 1682589606046 1 connected
6612cd6e4a3d7a9d09ea0e1259e4dada39da636f 10.233.75.81:6379@16379 slave,fail d429665ee330391b723c9c431eb0b18fbaef59f2 1682589606046 1682589606046 2 connected
```

For each of the failed nodes, we run `CLUSTER FORGET <NODE_ID>`

```shell
redis-redis-cluster:6379> CLUSTER FORGET 07654fb0f1e37c24960e3a3cf424533cfa9f6ad7
OK
redis-redis-cluster:6379> CLUSTER FORGET 6612cd6e4a3d7a9d09ea0e1259e4dada39da636f
OK
```

Check the nodes available in Redis cluster now:

```shell
redis-redis-cluster:6379> CLUSTER NODES
ffeafd7d99283e9d26e36fe234ea8b9d7fde2c76 10.233.74.98:6379@16379 slave d429665ee330391b723c9c431eb0b18fbaef59f2 0 1682590277101 2 connected
d0bcc789047c06d2902767f96882afc61bca1b2b 10.233.90.50:6379@16379 master - 0 1682590276000 7 connected 0-5460
350ccb14d34b6f14ba18f12ebbc856537297d9dd 10.233.97.163:6379@16379 master - 0 1682590276096 3 connected 10923-16383
61e811e81ec79051291b937df582c7547ceede93 10.233.111.238:6379@16379 myself,slave d0bcc789047c06d2902767f96882afc61bca1b2b 0 1682590274000 7 connected
d429665ee330391b723c9c431eb0b18fbaef59f2 10.233.75.27:6379@16379 master - 0 1682590275091 2 connected 5461-10922
8890cba2e6c6e4a20e55c778943cd5af983deb89 10.233.100.160:6379@16379 slave 350ccb14d34b6f14ba18f12ebbc856537297d9dd 0 1682590276000 3 connected
```

The process of scaling down of Redis cluster to {nodes: 6, replicas:1} is now complete!

Now lets check if the `key` set previously is still available or not, by connecting to the redis cluster.

```shell
redis-redis-cluster:6379> get name
-> Redirected to slot [5798] located at 10.233.75.27:6379
"krishna"
```

You can observe that data in Redis cluster has been resharded to accomodate the new state of Redis cluster {nodes: 6, replicas:1}

## Securing traffic using TLS

TLS support can be enabled in the chart by specifying the `tls.` parameters while creating a release. The following parameters should be configured to properly enable the TLS support in the cluster:

- `tls.enabled`: Enable TLS support. Defaults to `false`
- `tls.existingSecret`: Name of the secret that contains the certificates. No defaults.
- `tls.certFilename`: Certificate filename. No defaults.
- `tls.certKeyFilename`: Certificate key filename. No defaults.
- `tls.certCAFilename`: CA Certificate filename. No defaults.

For example:

First, create the secret with the certificates files:

```shell
kubectl create secret generic certificates-tls-secret --from-file=./cert.pem --from-file=./cert.key --from-file=./ca.pem -n redis
```

Then update `values.yaml`

```yaml
tls.enabled="true"
tls.existingSecret="certificates-tls-secret"
tls.certFilename="cert.pem"
tls.certKeyFilename="cert.key"
tls.certCAFilename="ca.pem"
```

Apply the changes

```shell
helm upgrade -f values.yaml redis oci://registry-1.docker.io/bitnamicharts/redis-cluster --set password=$REDIS_PASSWORD -n redis
```

## References

- https://redis.com/redis-enterprise/technology/redis-enterprise-cluster-architecture/
- https://docs.redis.com/latest/kubernetes/architecture/
- https://github.com/bitnami/charts/tree/main/bitnami/redis-cluster
- https://redis.io/docs/management/scaling/
- https://stackoverflow.com/questions/58591980/production-redis-cluster-with-sharding-in-kubernetes
