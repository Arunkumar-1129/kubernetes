# Kubernetes DaemonSet Lab

## Overview

This lab demonstrates how to create and manage a Kubernetes DaemonSet using the Nginx container image. A DaemonSet ensures that one Pod runs on every node in the cluster automatically.

---

## DaemonSet Configuration

Create a file named `daemonset.yaml`.

```yaml
apiVersion: apps/v1
kind: DaemonSet

metadata:
  name: nginx-daemonset
  labels:
    app: nginx
    env: prod

spec:
  selector:
    matchLabels:
      app: nginx-app

  template:
    metadata:
      labels:
        app: nginx-app

    spec:
      containers:
      - name: nginx-container
        image: nginx:1.27
        ports:
        - containerPort: 80
```

---

## Create DaemonSet

Apply the manifest:

```bash
kubectl apply -f daemonset.yaml
```

Output:

```bash
daemonset.apps/nginx-daemonset created
```

---

## Verify DaemonSet Pods

```bash
kubectl get pods -o wide
```

Output:

```bash
NAME                      READY   STATUS    NODE
nginx-daemonset-678rl     1/1     Running   k3s-worker2.sece.com
nginx-daemonset-nl9v8     1/1     Running   k3s-worker1.sece.com
nginx-daemonset-xr74t     1/1     Running   k3s-master.sece.com
```

Observation:

- One Pod is created on each node.
- DaemonSet automatically schedules Pods across all nodes.

---

## Verify DaemonSet

```bash
kubectl get ds
```

Output:

```bash
NAME              DESIRED   CURRENT   READY
nginx-daemonset   3         3         3
```

Meaning:

| Field | Description |
|---------|-------------|
| DESIRED | Number of nodes requiring Pods |
| CURRENT | Number of Pods currently running |
| READY | Number of healthy Pods |

---

## Monitor DaemonSet

Watch DaemonSet and Pods continuously:

```bash
watch kubectl get ds,po -o wide
```

Output:

```bash
daemonset.apps/nginx-daemonset

DESIRED: 3
CURRENT: 3
READY: 3
```

Pods:

```bash
nginx-daemonset-678rl
nginx-daemonset-nl9v8
nginx-daemonset-xr74t
```

Each Pod runs on a different node.

---

## Delete a DaemonSet Pod

Delete one DaemonSet Pod manually:

```bash
kubectl delete pod nginx-daemonset-678rl
```

Example:

```bash
kubectl delete pod nginx-daemonset-w2rxg
```

Output:

```bash
pod "nginx-daemonset-678rl" deleted
```

Verify:

```bash
kubectl get pods -o wide
```

Observation:

- DaemonSet automatically creates a replacement Pod.
- Desired Pod count remains unchanged.

---

# Namespace Lab

## Create Namespace

Create a namespace named `dev`.

```bash
kubectl create ns dev
```

Output:

```bash
namespace/dev created
```

---

## Verify Namespace

```bash
kubectl get ns
```

Output:

```bash
NAME
default
dev
kube-system
kube-public
kube-node-lease
```

---

## Deploy ReplicaSet in Namespace

Create `nginx-rs.yaml`.

```yaml
apiVersion: apps/v1
kind: ReplicaSet

metadata:
  name: nginx-rs
  namespace: dev

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
      - name: nginx
        image: nginx
```

Apply:

```bash
kubectl apply -f nginx-rs.yaml
```

Output:

```bash
replicaset.apps/nginx-rs created
```

---

## Verify ReplicaSet in Namespace

```bash
kubectl get rs -n dev
```

Output:

```bash
NAME       DESIRED   CURRENT   READY
nginx-rs   3         3         3
```

---

## View Pods Across All Namespaces

```bash
kubectl get pods -A
```

Output:

```bash
NAMESPACE     NAME
default       nginx-daemonset-7t6qp
default       nginx-pod
dev           nginx-rs-n5852
dev           nginx-rs-qp66w
dev           nginx-rs-zv9h6
kube-system   coredns-xxxxx
```

Observation:

- Pods are grouped by namespace.
- The ReplicaSet Pods are created inside the `dev` namespace.

---

## View Pods in Default Namespace

```bash
kubectl get pods
```

Displays Pods only from the default namespace.

---

## View Pods in Dev Namespace

```bash
kubectl get pod -n dev
```

Output:

```bash
NAME             READY   STATUS
nginx-rs-n5852   1/1     Running
nginx-rs-qp66w   1/1     Running
nginx-rs-zv9h6   1/1     Running
```

---

## Useful Commands

### Create Namespace

```bash
kubectl create ns dev
```

### View Namespaces

```bash
kubectl get ns
```

### Apply ReplicaSet

```bash
kubectl apply -f nginx-rs.yaml
```

### View ReplicaSets in Namespace

```bash
kubectl get rs -n dev
```

### View Pods in Namespace

```bash
kubectl get pods -n dev
```

### View All Pods

```bash
kubectl get pods -A
```

### View DaemonSets

```bash
kubectl get ds
```

### View DaemonSet and Pods

```bash
kubectl get ds,po -o wide
```

### Delete DaemonSet Pod

```bash
kubectl delete pod <pod-name>
```

---

## Conclusion

A DaemonSet ensures that exactly one Pod runs on every node in a Kubernetes cluster. When a node joins the cluster, a new DaemonSet Pod is automatically created on that node. Namespaces provide logical isolation, allowing resources such as Pods, ReplicaSets, and Deployments to be organized and managed independently within the same cluster. :contentReference[oaicite:0]{index=0}


```

vi daemonset.yaml


apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
  labels:
    app: nginx
    env: prod
spec:
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
      - name: nginx-container
        image: nginx:1.27
        ports:
        - containerPort: 80



kubectl apply -f daemonset.yaml
daemonset.apps/nginx-daemonset created
root@k3s-master:~# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS      AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-678rl               1/1     Running   0             23s   10.42.1.50   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-nl9v8               1/1     Running   0             23s   10.42.2.53   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-xr74t               1/1     Running   0             23s   10.42.0.68   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-2q9df   1/1     Running   1 (43m ago)   11h   10.42.1.46   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-4lfhk   1/1     Running   1 (43m ago)   11h   10.42.2.50   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-64vqq   1/1     Running   1 (43m ago)   11h   10.42.0.61   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-clzgq   1/1     Running   1 (43m ago)   11h   10.42.1.48   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-f8kt5   1/1     Running   1 (43m ago)   11h   10.42.2.52   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-g4nj9   1/1     Running   1 (43m ago)   11h   10.42.0.65   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-gff2q   1/1     Running   1 (43m ago)   11h   10.42.0.66   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-grhdx   1/1     Running   1 (43m ago)   11h   10.42.2.49   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-ngm7g   1/1     Running   1 (43m ago)   11h   10.42.1.49   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-qpw5h   1/1     Running   1 (43m ago)   11h   10.42.2.51   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   1 (43m ago)   12h   10.42.1.47   k3s-worker2.sece.com   <none>           <none>


root@k3s-master:~# kubectl get ds
NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
nginx-daemonset   3         3         3       3            3           <none>          44s





Every 2.0s: kubectl get ds,po -o wide                                                                            k3s-master.sece.com: Tue Jun  2 04:32:00 2026

NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE     CONTAINERS        IMAGES       SELECTOR
daemonset.apps/nginx-daemonset   3         3         3       3            3           <none>          7m44s   nginx-container   nginx:1.27   app=nginx-app

NAME                                    READY   STATUS    RESTARTS      AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-daemonset-678rl               1/1     Running   0             7m43s   10.42.1.50   k3s-worker2.sece.com   <none>           <none>
pod/nginx-daemonset-nl9v8               1/1     Running   0             7m43s   10.42.2.53   k3s-worker1.sece.com   <none>           <none>
pod/nginx-daemonset-xr74t               1/1     Running   0             7m43s   10.42.0.68   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-86c8cd48f6-2q9df   1/1     Running   1 (50m ago)   11h     10.42.1.46   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-4lfhk   1/1     Running   1 (50m ago)   11h     10.42.2.50   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-64vqq   1/1     Running   1 (51m ago)   11h     10.42.0.61   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-86c8cd48f6-clzgq   1/1     Running   1 (50m ago)   11h     10.42.1.48   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-f8kt5   1/1     Running   1 (50m ago)   11h     10.42.2.52   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-g4nj9   1/1     Running   1 (51m ago)   11h     10.42.0.65   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-86c8cd48f6-gff2q   1/1     Running   1 (51m ago)   11h     10.42.0.66   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-86c8cd48f6-grhdx   1/1     Running   1 (50m ago)   11h     10.42.2.49   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-ngm7g   1/1     Running   1 (50m ago)   11h     10.42.1.49   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-qpw5h   1/1     Running   1 (50m ago)   11h     10.42.2.51   k3s-worker1.sece.com   <none>           <none>
pod/nginx-pod                           1/1     Running   1 (50m ago)   12h     10.42.1.47   k3s-worker2.sece.com   <none>           <none>



kubectl delete pod/nginx-daemonset-w2rxg


creating namespace in the name of dev

root@k3s-master:~# vi nginx-rs.yaml
root@k3s-master:~# kubectl create ns dev
namespace/dev created
root@k3s-master:~# kubectl apply -f nginx-rs.yaml
replicaset.apps/nginx-rs created
root@k3s-master:~# kubectl get rs -n dev
NAME       DESIRED   CURRENT   READY   AGE
nginx-rs   3         3         0       10s
root@k3s-master:~# kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS       AGE
default       nginx-daemonset-7t6qp                     1/1     Running     0              7m42s
default       nginx-daemonset-nl9v8                     1/1     Running     0              43m
default       nginx-daemonset-xr74t                     1/1     Running     0              43m
default       nginx-deployment-86c8cd48f6-2q9df         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-4lfhk         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-64vqq         1/1     Running     1 (87m ago)    11h
default       nginx-deployment-86c8cd48f6-clzgq         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-f8kt5         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-g4nj9         1/1     Running     1 (87m ago)    11h
default       nginx-deployment-86c8cd48f6-gff2q         1/1     Running     1 (87m ago)    11h
default       nginx-deployment-86c8cd48f6-grhdx         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-ngm7g         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-qpw5h         1/1     Running     1 (86m ago)    11h
default       nginx-pod                                 1/1     Running     1 (86m ago)    12h
dev           nginx-rs-n5852                            1/1     Running     0              51s
dev           nginx-rs-qp66w                            1/1     Running     0              51s
dev           nginx-rs-zv9h6                            1/1     Running     0              51s
kube-system   coredns-8db54c48d-v6ck2                   1/1     Running     4 (87m ago)    2d19h
kube-system   helm-install-traefik-crd-rhl5l            0/1     Completed   0              2d19h
kube-system   helm-install-traefik-hgnt2                0/1     Completed   2              2d19h
kube-system   local-path-provisioner-5d9d9885bc-d9ws6   1/1     Running     4 (87m ago)    2d19h
kube-system   metrics-server-786d997795-mljbj           1/1     Running     4 (87m ago)    2d19h
kube-system   svclb-traefik-56ac0f3b-7pm7z              2/2     Running     8 (87m ago)    2d19h
kube-system   svclb-traefik-56ac0f3b-gz5x8              2/2     Running     6 (86m ago)    35h
kube-system   svclb-traefik-56ac0f3b-jt47t              2/2     Running     10 (86m ago)   2d1h
kube-system   traefik-9bcdbbd9-ztprx                    1/1     Running     4 (87m ago)    2d19h
root@k3s-master:~# kubectl get pods
NAME                                READY   STATUS    RESTARTS      AGE
nginx-daemonset-7t6qp               1/1     Running   0             8m37s
nginx-daemonset-nl9v8               1/1     Running   0             44m
nginx-daemonset-xr74t               1/1     Running   0             44m
nginx-deployment-86c8cd48f6-2q9df   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-4lfhk   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-64vqq   1/1     Running   1 (88m ago)   11h
nginx-deployment-86c8cd48f6-clzgq   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-f8kt5   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-g4nj9   1/1     Running   1 (88m ago)   11h
nginx-deployment-86c8cd48f6-gff2q   1/1     Running   1 (88m ago)   11h
nginx-deployment-86c8cd48f6-grhdx   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-ngm7g   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-qpw5h   1/1     Running   1 (87m ago)   11h
nginx-pod                           1/1     Running   1 (87m ago)   12h
root@k3s-master:~# kubectl get pod -n dev
NAME             READY   STATUS    RESTARTS   AGE
nginx-rs-n5852   1/1     Running   0          2m14s
nginx-rs-qp66w   1/1     Running   0          2m14s
nginx-rs-zv9h6   1/1     Running   0          2m14s

