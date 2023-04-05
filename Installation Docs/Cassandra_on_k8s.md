# Installing K8ssandra in a Single-cluster install with helm

> K8ssandra is a cloud native distribution of Apache Cassandra® that runs on Kubernetes. K8ssandra provides an ecosystem of tools to provide richer data APIs and automated operations alongside Cassandra.

## Prerequisites

Make sure you have the following installed before going through the related install topics.

- kubectx
- yq (YAML processor)
- gnu-getopt
- kubectl and helm v3+ on your preferred OS.

## K8ssandra Operator Architecture

<div style="align:center; margin-left:auto; margin-right:auto">
<img src="https://github.com/krishnashed/data-pipeline/blob/main/Installation%20Docs/images/k8ssandra-operator-architecture.png"/>
</div>

## Deploying K8ssandra

### Add the K8ssandra Helm chart repo

Deploy K8ssandra with one Cassandra datacenter in a single-cluster environment.
If you haven’t already, add the main K8ssandra stable Helm chart repo:

```shell
helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm repo update
```

### Deploy cert-manager

K8ssandra Operator has a dependency on `cert-manager`, which must be installed in each cluster, if not already available

```shell
helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager jetstack/cert-manager \
     --namespace cert-manager --create-namespace --set installCRDs=true
```

### Deploy K8ssandra Operator

You can deploy K8ssandra Operator for namespace-scoped operations (the default), or cluster-scoped operations.

- Deploying a namespace-scoped K8ssandra Operator means its operations – watching for resources to deploy in Kubernetes – are specific only to the identified namespace within a cluster.

Namespace-scoped example:

```shell
helm install k8ssandra-operator k8ssandra/k8ssandra-operator -n k8ssandra-operator --create-namespace
```

### Verify the deployment

```
$ kubectl get pods -n k8ssandra-operator

NAME                                                READY   STATUS    RESTARTS   AGE
k8ssandra-operator-7f76579f94-7s2tw                 1/1     Running   0          60s
k8ssandra-operator-cass-operator-794f65d9f4-j9lm5   1/1     Running   0          60s
```

### Deploy the K8ssandraCluster

To deploy a `K8ssandraCluster`, we use a custom YAML file. In this example, k8c1.yml. Notice, there is just one datacenter, `dc1`.

```shell
apiVersion: k8ssandra.io/v1alpha1
kind: K8ssandraCluster
metadata:
  name: demo
spec:
  cassandra:
    serverVersion: "4.0.1"
    datacenters:
      - metadata:
          name: dc1
        size: 3
        storageConfig:
          cassandraDataVolumeClaimSpec:
            storageClassName: standard
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 5Gi
        config:
          jvmOptions:
            heapSize: 512M
        stargate:
          size: 1
          heapSize: 256M
```

Create the K8ssandraCluster with `kubectl apply`:

```shell
kubectl apply -n k8ssandra-operator -f k8c1.yml
```

### Verify pod deployment

```
$ kubectl get pods -n k8ssandra-operator
NAME                                                    READY   STATUS    RESTARTS   AGE
demo-dc1-default-stargate-deployment-7b6c9d8dcd-k65jx   1/1     Running   0          5m33s
demo-dc1-default-sts-0                                  2/2     Running   0          10m
demo-dc1-default-sts-1                                  2/2     Running   0          10m
demo-dc1-default-sts-2                                  2/2     Running   0          10m
k8ssandra-operator-7f76579f94-7s2tw                     1/1     Running   0          11m
k8ssandra-operator-cass-operator-794f65d9f4-j9lm5       1/1     Running   0          11m
```

### Verify K8ssandraCluster deployment

```
$ kubectl get k8cs -n k8ssandra-operator
NAME   AGE
demo   8m22s
```

### Extract credentials

Use the following commands to extract the username and password:

```shell
CASS_USERNAME=$(kubectl get secret demo-superuser -n k8ssandra-operator -o=jsonpath='{.data.username}' | base64 --decode)

echo $CASS_USERNAME
```

Now obtain the password secret:

```shell
CASS_PASSWORD=$(kubectl get secret demo-superuser -n k8ssandra-operator -o=jsonpath='{.data.password}' | base64 --decode)

echo $CASS_PASSWORD
```

### Verify cluster status

```
$ % kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- nodetool -u $CASS_USERNAME -pw $CASS_PASSWORD status

Datacenter: dc1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens  Owns (effective)  Host ID                               Rack
UN  10.244.1.5  96.71 KiB  16      100.0%            4b95036b-1603-464f-bdee-b519fa28a079  default
UN  10.244.2.4  96.62 KiB  16      100.0%            ade61d9f-90f4-464c-8e18-dd3522c2bf3c  default
UN  10.244.3.4  96.7 KiB   16      100.0%            0f75a6fe-c91d-4c0e-9253-2235b6c9a206  default
```

All nodes should have the status UN, which stands for “Up Normal”.

### Test a few operations

Create a keyspace in the deployed Cassandra database, which is managed by K8ssandra Operator in the Kubernetes environment:

```shell
kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p $CASS_PASSWORD -e "CREATE KEYSPACE test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3};"

# Create a test.users table in the deployed Cassandra database:
kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p $CASS_PASSWORD  -e "CREATE TABLE test.users (email text primary key, name text, state text);"

# Insert some data in the table:
kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p $CASS_PASSWORD -e "insert into test.users (email, name, state) values ('john@gamil.com', 'John Smith', 'NC');"

kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p $CASS_PASSWORD -e "insert into test.users (email, name, state) values ('joe@gamil.com', 'Joe Jones', 'VA');"

kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p $CASS_PASSWORD -e "insert into test.users (email, name, state) values ('sue@help.com', 'Sue Sas', 'CA');"

# Select data from the table:
kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p $CASS_PASSWORD -e "select * from test.users;"

 email          | name          | state
----------------+---------------+-------
 john@gamil.com |    John Smith |    NC
  joe@gamil.com |     Joe Jones |    VA
   sue@help.com |       Sue Sas |    CA
```
