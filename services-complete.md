# ☸️ Kubernetes K3s Lab — Complete Command Reference

> **Cluster:** k3s on Ubuntu 24.04.4 LTS &nbsp;|&nbsp; **Version:** v1.35.5+k3s1 &nbsp;|&nbsp; **Runtime:** containerd 2.2.3-k3s1

---

## 🖥️ Cluster Topology

| Node | Role | IP | Labels |
|------|------|----|--------|
| `k3s-master.sece.com` | control-plane | 192.168.142.11 | — |
| `k3s-worker1.sece.com` | worker | 192.168.142.12 | `env=test`, `name=arun` |
| `k3s-worker2.sece.com` | worker | 192.168.142.13 | `env=test` |

---

## 📋 Table of Contents

1. [Node Management](#1-node-management)
2. [Node Labels](#2-node-labels)
3. [Node Taints](#3-node-taints)
4. [Pods](#4-pods)
5. [Deployments](#5-deployments)
6. [DaemonSets](#6-daemonsets)
7. [Resource Monitoring](#7-resource-monitoring)
8. [Services — ClusterIP](#8-services--clusterip)
9. [Services — NodePort](#9-services--nodeport)
10. [API Resources](#10-api-resources)
11. [YAML Manifests](#11-yaml-manifests)

---

## 1. Node Management

### View all nodes
```bash
kubectl get node
```

### View nodes with extra details (IP, OS, runtime)
```bash
kubectl get node -o wide
```

### View all nodes with labels
```bash
kubectl get node --show-labels
```

### Describe a specific node
```bash
kubectl describe node k3s-worker2
kubectl describe node k3s-worker2.sece.com
```

---

## 2. Node Labels

### Add a label to a node
```bash
kubectl label node k3s-worker1.sece.com name=arun
kubectl label node k3s-worker2.sece.com env=test
```

### Remove a label from a node
```bash
# Correct syntax: append '-' to the label KEY (not the value)
kubectl label node k3s-worker1.sece.com env-
```

> ⚠️ **Common Mistake:** `kubectl label node <node> env=test-` → Invalid!  
> The `-` suffix must follow the **key**, not the value: `kubectl label node <node> env-`

### Verify labels after changes
```bash
kubectl get node --show-labels
```

### Re-label (label already exists — no-op)
```bash
kubectl label node k3s-worker2.sece.com env=test
# Output: node/k3s-worker2.sece.com not labeled  (already exists)
```

---

## 3. Node Taints

### View taints on a node
```bash
kubectl describe node k3s-worker2.sece.com
# Look for: Taints: role=database:NoSchedule
```

### Remove a taint from a node
```bash
kubectl taint node k3s-worker2.sece.com role-
# Output: node/k3s-worker2.sece.com untainted
```

> **Effect:** After removing the `role=database:NoSchedule` taint from `k3s-worker2`, pods with `nodeSelector: env=test` could be scheduled there.

---

## 4. Pods

### View all pods
```bash
kubectl get po
```

### View pods with node/IP details
```bash
kubectl get po -o wide
```

### Describe a specific pod
```bash
kubectl describe po nginx-deployment-5d8dbff9fb-75d59
```

> ⚠️ **Common Mistake:** `kubectl describe nginx-deployment-5d8dbff9fb-75d59`  
> Must specify resource type: `kubectl describe po <pod-name>`

### Delete a pod (ReplicaSet/Deployment will recreate it)
```bash
kubectl delete pod/nginx-pod
kubectl delete pod/nginx-deployment-799ddc88c8-2pwkm
```

### Apply pod manifest
```bash
kubectl apply -f pod.yaml
```

---

## 5. Deployments

### View deployments
```bash
kubectl get deploy
```

### Apply / Create a deployment
```bash
kubectl apply -f nginx-deployment.yaml
kubectl create -f nginx-deployment.yaml
```

### Describe a deployment
```bash
kubectl describe deployment.apps/nginx-deployment
```

### Trigger rolling restart
```bash
kubectl rollout restart deploy nginx-deployment
```

### Delete a deployment
```bash
kubectl delete deploy nginx-deployment
kubectl delete deployment.apps/nginx-deployment
```

> **Note:** `spec.selector` is **immutable** after creation. Changing `matchLabels` requires deleting and recreating the deployment.  
> Errors encountered:
> ```
> The Deployment "nginx-deployment" is invalid: spec.selector: Invalid value: {"matchLabels":{"app":"http"}}: field is immutable
> ```

### nodeSelector behavior
The deployment uses `nodeSelector: env=test` — pods only schedule on nodes with that label.

```
# Before labeling worker2: all 10 pods → worker1 only
# After labeling worker2 env=test + removing taint: pods spread across worker1 & worker2
```

---

## 6. DaemonSets

DaemonSet pods run one per node automatically:

| Pod Name | Node |
|----------|------|
| `nginx-daemonset-ffvld` | k3s-worker1 |
| `nginx-daemonset-mtkcm` | k3s-worker2 |
| `nginx-daemonset-s7qjj` | k3s-master |

---

## 7. Resource Monitoring

### Node-level CPU & Memory usage
```bash
kubectl top node
```

```
NAME                   CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k3s-master.sece.com    250m         12%      1408Mi          36%
k3s-worker1.sece.com   35m          1%       695Mi           17%
k3s-worker2.sece.com   29m          1%       614Mi           15%
```

### Pod-level CPU & Memory usage
```bash
kubectl top pod
```

```
NAME                                CPU(cores)   MEMORY(bytes)
nginx-daemonset-ffvld               0m           13Mi
nginx-daemonset-mtkcm               0m           13Mi
nginx-daemonset-s7qjj               0m           13Mi
nginx-deployment-5d8dbff9fb-75d59   0m           8Mi
nginx-pod                           0m           8Mi
...
```

> ⚠️ `kubectl top pod -o wide` → Not supported. `-o wide` flag only works with `get`, not `top`.

---

## 8. Services — ClusterIP

### View services
```bash
kubectl get svc
```

### Create ClusterIP service
```bash
kubectl create -f service.yaml
# or
kubectl apply -f service.yaml
```

### Replace (update) a service
```bash
kubectl replace -f service.yaml
```

### Describe a service
```bash
kubectl describe svc nginx-svc
```

### View endpoints (pods backing the service)
```bash
kubectl get endpoints
```

### Test ClusterIP access (from within cluster/master)
```bash
curl 10.43.88.152
curl 10.43.241.254
```

### Delete a service
```bash
kubectl delete svc nginx-svc
```

> **Note:** `spec.selector` must match pod labels. Initial mismatch (`name: webserver` vs pod label `app: nginx`) was fixed by updating the selector.

---

## 9. Services — NodePort

### Create NodePort service (auto-assigned port)
```bash
kubectl create -f nodeport-svc.yaml
```

### Create NodePort service (custom port: 31001)
```bash
kubectl create -f np-custom-svc.yaml
```

### View all services
```bash
kubectl get svc
```

```
NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx-nodeport-svc          NodePort    10.43.218.6     <none>        80:31927/TCP   12m
nginx-nodeport-custom-svc   NodePort    10.43.149.14    <none>        80:31001/TCP   5s
nginx-svc                   ClusterIP   10.43.241.254   <none>        80/TCP         44m
```

### Describe NodePort service
```bash
kubectl describe svc nginx-nodeport-svc
kubectl describe svc nginx-nodeport-custom-svc
```

### Access via any node IP + NodePort (accessible externally)
```bash
curl 192.168.142.11:31927   # via master
curl 192.168.142.12:31927   # via worker1
curl 192.168.142.13:31927   # via worker2
```

> **Key insight:** NodePort exposes the service on the **same port** on ALL nodes in the cluster — any node IP works.

---

## 10. API Resources

### Explore available resource types
```bash
kubectl api-resources | grep pod
kubectl api-resources | grep replica
kubectl api-resources | grep deploy
kubectl api-resources | grep ds       # DaemonSets
kubectl api-resources | grep svc      # Services
```

### Get help for a resource type
```bash
kubectl explain svc
```

---

## 11. YAML Manifests

### `pod.yaml` — Final version
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

### `nginx-deployment.yaml` — Final version
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: sk
  template:
    metadata:
      labels:
        app: sk
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
```

### `service.yaml` — ClusterIP
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: sk
```

### `nodeport-svc.yaml` — NodePort (auto port)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport-svc
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: sk
```

### `np-custom-svc.yaml` — NodePort (custom port 31001)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport-custom-svc
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31001
  selector:
    app: sk
```

---

## ⚡ Key Learnings & Gotchas

| # | Issue | Fix |
|---|-------|-----|
| 1 | `kubectl describe <pod-name>` — missing resource type | Always use `kubectl describe po <pod-name>` |
| 2 | `kubectl label node <node> env=test-` — invalid label value | Use `kubectl label node <node> env-` to remove |
| 3 | `kubectl top pod -o wide` — unknown flag | `-o wide` not supported with `top`, only with `get` |
| 4 | `spec.selector` is immutable in Deployments | Delete and recreate the deployment to change selector |
| 5 | Pods stuck in `Pending` with `nodeSelector` | Label the correct nodes with the required key-value |
| 6 | Taint `role=database:NoSchedule` blocking scheduling | Remove taint: `kubectl taint node <node> role-` |
| 7 | `kubectl create -f` fails if resource exists | Use `kubectl apply -f` for idempotent updates |

---

## 🔗 References

- [K3s Docs](https://docs.k3s.io/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Node Selectors](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
- [Taints & Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

---

```

Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-117-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Wed Jun  3 03:28:58 PM UTC 2026

  System load:  0.93               Processes:              246
  Usage of /:   69.8% of 11.21GB   Users logged in:        1
  Memory usage: 27%                IPv4 address for ens33: 192.168.142.11
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Wed Jun  3 09:20:28 2026 from 192.168.142.1
arun@k3s-master:~$ sudo -i
[sudo] password for arun:
root@k3s-master:~# nginx-deployment.yaml
nginx-deployment.yaml: command not found
root@k3s-master:~# cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
root@k3s-master:~# kubectl get node
NAME                   STATUS   ROLES           AGE     VERSION
k3s-master.sece.com    Ready    control-plane   4d5h    v1.35.5+k3s1
k3s-worker1.sece.com   Ready    <none>          2d21h   v1.35.5+k3s1
k3s-worker2.sece.com   Ready    <none>          3d12h   v1.35.5+k3s1
root@k3s-master:~#
root@k3s-master:~# kubectl get node -o wide
NAME                   STATUS   ROLES           AGE     VERSION        INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k3s-master.sece.com    Ready    control-plane   4d5h    v1.35.5+k3s1   192.168.142.11   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.3-k3s1
k3s-worker1.sece.com   Ready    <none>          2d21h   v1.35.5+k3s1   192.168.142.12   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.3-k3s1
k3s-worker2.sece.com   Ready    <none>          3d12h   v1.35.5+k3s1   192.168.142.13   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.3-k3s1
root@k3s-master:~#
root@k3s-master:~# kubectl get node --show-labels
NAME                   STATUS   ROLES           AGE     VERSION        LABELS
k3s-master.sece.com    Ready    control-plane   4d6h    v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-master.sece.com,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node.kubernetes.io/instance-type=k3s
k3s-worker1.sece.com   Ready    <none>          2d21h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,env=test,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker1.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
k3s-worker2.sece.com   Ready    <none>          3d12h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker2.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl label node k3s-worker1.sece.com name=arun
node/k3s-worker1.sece.com labeled
root@k3s-master:~#
root@k3s-master:~# kubectl get node --show-labels
NAME                   STATUS   ROLES           AGE     VERSION        LABELS
k3s-master.sece.com    Ready    control-plane   4d6h    v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-master.sece.com,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node.kubernetes.io/instance-type=k3s
k3s-worker1.sece.com   Ready    <none>          2d21h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,env=test,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker1.sece.com,kubernetes.io/os=linux,name=arun,node.kubernetes.io/instance-type=k3s
k3s-worker2.sece.com   Ready    <none>          3d12h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker2.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
root@k3s-master:~#
root@k3s-master:~# kubectl label node k3s-worker1.sece.com env=test-
error: invalid label value: "env=test-": a valid label must be an empty string or consist of alphanumeric characters, '-', '_' or '.', and must start and end with an alphanumeric character (e.g. 'MyValue',  or 'my_value',  or '12345', regex used for validation is '(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?')
root@k3s-master:~# kubectl label node k3s-worker1.sece.com env-
node/k3s-worker1.sece.com unlabeled
root@k3s-master:~#
root@k3s-master:~# kubectl get node --show-labels
NAME                   STATUS   ROLES           AGE     VERSION        LABELS
k3s-master.sece.com    Ready    control-plane   4d6h    v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-master.sece.com,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node.kubernetes.io/instance-type=k3s
k3s-worker1.sece.com   Ready    <none>          2d21h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker1.sece.com,kubernetes.io/os=linux,name=arun,node.kubernetes.io/instance-type=k3s
k3s-worker2.sece.com   Ready    <none>          3d12h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker2.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
root@k3s-master:~#
root@k3s-master:~# ls
daemonset.yaml  deployment.yaml  nginx-deployment.yaml  nginx-rs.yaml  pod.yaml  service.yaml
root@k3s-master:~# cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
root@k3s-master:~#
root@k3s-master:~# vi pod.yaml
root@k3s-master:~#
root@k3s-master:~# kubectl get po
NAME                                READY   STATUS    RESTARTS      AGE
nginx-daemonset-ffvld               1/1     Running   1 (12h ago)   33h
nginx-daemonset-mtkcm               1/1     Running   1 (12h ago)   33h
nginx-daemonset-s7qjj               1/1     Running   1 (12h ago)   33h
nginx-deployment-5d8dbff9fb-75d59   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-dmlff   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-jzhl8   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-mk4sc   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-ntxcn   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-qbp46   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-s2tvv   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-tfqdd   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-vkfxn   1/1     Running   1 (12h ago)   29h
nginx-deployment-5d8dbff9fb-zr2z5   1/1     Running   1 (12h ago)   29h
nginx-pod                           1/1     Running   2 (12h ago)   47h
root@k3s-master:~#
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS      AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-ffvld               1/1     Running   1 (12h ago)   33h   10.42.2.81   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm               1/1     Running   1 (12h ago)   33h   10.42.1.64   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj               1/1     Running   1 (12h ago)   33h   10.42.0.79   k3s-master.sece.com    <none>           <none>
nginx-deployment-5d8dbff9fb-75d59   1/1     Running   1 (12h ago)   29h   10.42.2.79   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-dmlff   1/1     Running   1 (12h ago)   29h   10.42.2.75   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-jzhl8   1/1     Running   1 (12h ago)   29h   10.42.2.84   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-mk4sc   1/1     Running   1 (12h ago)   29h   10.42.2.77   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-ntxcn   1/1     Running   1 (12h ago)   29h   10.42.2.80   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-qbp46   1/1     Running   1 (12h ago)   29h   10.42.2.85   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-s2tvv   1/1     Running   1 (12h ago)   29h   10.42.2.82   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-tfqdd   1/1     Running   1 (12h ago)   29h   10.42.2.76   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-vkfxn   1/1     Running   1 (12h ago)   29h   10.42.2.78   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-zr2z5   1/1     Running   1 (12h ago)   29h   10.42.2.83   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   2 (12h ago)   47h   10.42.1.63   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~#
root@k3s-master:~# kubectl describe nginx-deployment-5d8dbff9fb-75d59
error: the server doesn't have a resource type "nginx-deployment-5d8dbff9fb-75d59"
root@k3s-master:~# kubectl describe po nginx-deployment-5d8dbff9fb-75d59
Name:             nginx-deployment-5d8dbff9fb-75d59
Namespace:        default
Priority:         0
Service Account:  default
Node:             k3s-worker1.sece.com/192.168.142.12
Start Time:       Tue, 02 Jun 2026 09:41:53 +0000
Labels:           app=nginx
                  pod-template-hash=5d8dbff9fb
Annotations:      <none>
Status:           Running
IP:               10.42.2.79
IPs:
  IP:           10.42.2.79
Controlled By:  ReplicaSet/nginx-deployment-5d8dbff9fb
Containers:
  nginx:
    Container ID:   containerd://ddf61ba095cbb5cb07cc265685188113f341d72dc19b330b1836c9b65a572929
    Image:          nginx:1.29
    Image ID:       docker.io/library/nginx@sha256:1881968aff6f7cdcc4b888c00a11f4ce241ad7ec957e0cb4a9e19e93a3ff87ea
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 03 Jun 2026 03:32:17 +0000
    Last State:     Terminated
      Reason:       Unknown
      Exit Code:    255
      Started:      Tue, 02 Jun 2026 09:41:56 +0000
      Finished:     Wed, 03 Jun 2026 03:32:10 +0000
    Ready:          True
    Restart Count:  1
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-wwvdj (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-wwvdj:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              env=test
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason       Age   From     Message
  ----     ------       ----  ----     -------
  Warning  FailedMount  20m   kubelet  MountVolume.SetUp failed for volume "kube-api-access-wwvdj" : failed to fetch token: Post "https://127.0.0.1:6444/api/v1/namespaces/default/serviceaccounts/default/token": http2: client connection lost
  Warning  FailedMount  20m   kubelet  MountVolume.SetUp failed for volume "kube-api-access-wwvdj" : failed to fetch token: Post "https://127.0.0.1:6444/api/v1/namespaces/default/serviceaccounts/default/token": read tcp 127.0.0.1:41988->127.0.0.1:6444: read: connection reset by peer
  Warning  FailedMount  20m   kubelet  MountVolume.SetUp failed for volume "kube-api-access-wwvdj" : failed to fetch token: Post "https://127.0.0.1:6444/api/v1/namespaces/default/serviceaccounts/default/token": read tcp 127.0.0.1:42180->127.0.0.1:6444: read: connection reset by peer
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS      AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-ffvld               1/1     Running   1 (12h ago)   33h   10.42.2.81   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm               1/1     Running   1 (12h ago)   33h   10.42.1.64   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj               1/1     Running   1 (12h ago)   33h   10.42.0.79   k3s-master.sece.com    <none>           <none>
nginx-deployment-5d8dbff9fb-75d59   1/1     Running   1 (12h ago)   30h   10.42.2.79   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-dmlff   1/1     Running   1 (12h ago)   30h   10.42.2.75   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-jzhl8   1/1     Running   1 (12h ago)   30h   10.42.2.84   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-mk4sc   1/1     Running   1 (12h ago)   30h   10.42.2.77   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-ntxcn   1/1     Running   1 (12h ago)   30h   10.42.2.80   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-qbp46   1/1     Running   1 (12h ago)   30h   10.42.2.85   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-s2tvv   1/1     Running   1 (12h ago)   30h   10.42.2.82   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-tfqdd   1/1     Running   1 (12h ago)   30h   10.42.2.76   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-vkfxn   1/1     Running   1 (12h ago)   30h   10.42.2.78   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-zr2z5   1/1     Running   1 (12h ago)   30h   10.42.2.83   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   2 (12h ago)   47h   10.42.1.63   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~# kubectl label node k3s-worker2.sece.com env=test
node/k3s-worker2.sece.com labeled
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS      AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-ffvld               1/1     Running   1 (12h ago)   33h   10.42.2.81   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm               1/1     Running   1 (12h ago)   33h   10.42.1.64   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj               1/1     Running   1 (12h ago)   33h   10.42.0.79   k3s-master.sece.com    <none>           <none>
nginx-deployment-5d8dbff9fb-75d59   1/1     Running   1 (12h ago)   30h   10.42.2.79   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-dmlff   1/1     Running   1 (12h ago)   30h   10.42.2.75   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-jzhl8   1/1     Running   1 (12h ago)   30h   10.42.2.84   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-mk4sc   1/1     Running   1 (12h ago)   30h   10.42.2.77   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-ntxcn   1/1     Running   1 (12h ago)   30h   10.42.2.80   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-qbp46   1/1     Running   1 (12h ago)   30h   10.42.2.85   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-s2tvv   1/1     Running   1 (12h ago)   30h   10.42.2.82   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-tfqdd   1/1     Running   1 (12h ago)   30h   10.42.2.76   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-vkfxn   1/1     Running   1 (12h ago)   30h   10.42.2.78   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-zr2z5   1/1     Running   1 (12h ago)   30h   10.42.2.83   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   2 (12h ago)   47h   10.42.1.63   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~# cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment configured
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS      AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-ffvld               1/1     Running   1 (12h ago)   33h   10.42.2.81   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm               1/1     Running   1 (12h ago)   33h   10.42.1.64   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj               1/1     Running   1 (12h ago)   33h   10.42.0.79   k3s-master.sece.com    <none>           <none>
nginx-deployment-5d8dbff9fb-75d59   1/1     Running   1 (12h ago)   30h   10.42.2.79   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-dmlff   1/1     Running   1 (12h ago)   30h   10.42.2.75   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-jzhl8   1/1     Running   1 (12h ago)   30h   10.42.2.84   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-mk4sc   1/1     Running   1 (12h ago)   30h   10.42.2.77   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-ntxcn   1/1     Running   1 (12h ago)   30h   10.42.2.80   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-qbp46   1/1     Running   1 (12h ago)   30h   10.42.2.85   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-s2tvv   1/1     Running   1 (12h ago)   30h   10.42.2.82   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-tfqdd   1/1     Running   1 (12h ago)   30h   10.42.2.76   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-vkfxn   1/1     Running   1 (12h ago)   30h   10.42.2.78   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-zr2z5   1/1     Running   1 (12h ago)   30h   10.42.2.83   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   2 (12h ago)   47h   10.42.1.63   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~# kubectl rollout restart deploy nginx-deployment
deployment.apps/nginx-deployment restarted
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS      AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-ffvld               1/1     Running   1 (12h ago)   33h   10.42.2.81   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm               1/1     Running   1 (12h ago)   33h   10.42.1.64   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj               1/1     Running   1 (12h ago)   33h   10.42.0.79   k3s-master.sece.com    <none>           <none>
nginx-deployment-5d8d9b84cb-7lxqh   0/1     Pending   0             5s    <none>       <none>                 <none>           <none>
nginx-deployment-5d8d9b84cb-bdrdf   0/1     Pending   0             5s    <none>       <none>                 <none>           <none>
nginx-deployment-5d8d9b84cb-bjv9l   0/1     Pending   0             5s    <none>       <none>                 <none>           <none>
nginx-deployment-5d8d9b84cb-d6q5f   0/1     Pending   0             5s    <none>       <none>                 <none>           <none>
nginx-deployment-5d8d9b84cb-qxhsg   0/1     Pending   0             5s    <none>       <none>                 <none>           <none>
nginx-deployment-5d8dbff9fb-75d59   1/1     Running   1 (12h ago)   30h   10.42.2.79   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-dmlff   1/1     Running   1 (12h ago)   30h   10.42.2.75   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-jzhl8   1/1     Running   1 (12h ago)   30h   10.42.2.84   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-mk4sc   1/1     Running   1 (12h ago)   30h   10.42.2.77   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-ntxcn   1/1     Running   1 (12h ago)   30h   10.42.2.80   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-qbp46   1/1     Running   1 (12h ago)   30h   10.42.2.85   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-tfqdd   1/1     Running   1 (12h ago)   30h   10.42.2.76   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-zr2z5   1/1     Running   1 (12h ago)   30h   10.42.2.83   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   2 (12h ago)   47h   10.42.1.63   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~# cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
root@k3s-master:~#
root@k3s-master:~# kubectl get deploy
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   8/10    5            8           2d11h
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS      AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-ffvld               1/1     Running   1 (12h ago)   33h     10.42.2.81   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm               1/1     Running   1 (12h ago)   33h     10.42.1.64   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj               1/1     Running   1 (12h ago)   33h     10.42.0.79   k3s-master.sece.com    <none>           <none>
nginx-deployment-5d8d9b84cb-7lxqh   0/1     Pending   0             7m13s   <none>       <none>                 <none>           <none>
nginx-deployment-5d8d9b84cb-bdrdf   0/1     Pending   0             7m13s   <none>       <none>                 <none>           <none>
nginx-deployment-5d8d9b84cb-bjv9l   0/1     Pending   0             7m13s   <none>       <none>                 <none>           <none>
nginx-deployment-5d8d9b84cb-d6q5f   0/1     Pending   0             7m13s   <none>       <none>                 <none>           <none>
nginx-deployment-5d8d9b84cb-qxhsg   0/1     Pending   0             7m13s   <none>       <none>                 <none>           <none>
nginx-deployment-5d8dbff9fb-75d59   1/1     Running   1 (12h ago)   30h     10.42.2.79   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-dmlff   1/1     Running   1 (12h ago)   30h     10.42.2.75   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-jzhl8   1/1     Running   1 (12h ago)   30h     10.42.2.84   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-mk4sc   1/1     Running   1 (12h ago)   30h     10.42.2.77   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-ntxcn   1/1     Running   1 (12h ago)   30h     10.42.2.80   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-qbp46   1/1     Running   1 (12h ago)   30h     10.42.2.85   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-tfqdd   1/1     Running   1 (12h ago)   30h     10.42.2.76   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-5d8dbff9fb-zr2z5   1/1     Running   1 (12h ago)   30h     10.42.2.83   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   2 (12h ago)   47h     10.42.1.63   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~# kubectl get nodes --show-labels
NAME                   STATUS   ROLES           AGE     VERSION        LABELS
k3s-master.sece.com    Ready    control-plane   4d6h    v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-master.sece.com,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node.kubernetes.io/instance-type=k3s
k3s-worker1.sece.com   Ready    <none>          2d22h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker1.sece.com,kubernetes.io/os=linux,name=arun,node.kubernetes.io/instance-type=k3s
k3s-worker2.sece.com   Ready    <none>          3d12h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,env=test,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker2.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
root@k3s-master:~# kubectl label node k3s-worker2.sece.com env=test
node/k3s-worker2.sece.com not labeled
root@k3s-master:~# kubectl label node k3s-worker2.sece.com env=test-
error: invalid label value: "env=test-": a valid label must be an empty string or consist of alphanumeric characters, '-', '_' or '.', and must start and end with an alphanumeric character (e.g. 'MyValue',  or 'my_value',  or '12345', regex used for validation is '(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?')
root@k3s-master:~# kubectl label node k3s-worker2.sece.com env-
node/k3s-worker2.sece.com unlabeled
root@k3s-master:~# kubectl label node k3s-worker2.sece.com env=test
node/k3s-worker2.sece.com labeled
root@k3s-master:~# kubectl get nodes --show-labels
NAME                   STATUS   ROLES           AGE     VERSION        LABELS
k3s-master.sece.com    Ready    control-plane   4d6h    v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-master.sece.com,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node.kubernetes.io/instance-type=k3s
k3s-worker1.sece.com   Ready    <none>          2d22h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker1.sece.com,kubernetes.io/os=linux,name=arun,node.kubernetes.io/instance-type=k3s
k3s-worker2.sece.com   Ready    <none>          3d12h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,env=test,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker2.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
root@k3s-master:~# kubectl describe node k3s-worker2
Name:               k3s-worker2.sece.com
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=k3s
                    beta.kubernetes.io/os=linux
                    env=test
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k3s-worker2.sece.com
                    kubernetes.io/os=linux
                    node.kubernetes.io/instance-type=k3s
Annotations:        alpha.kubernetes.io/provided-node-ip: 192.168.142.13
                    flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"ee:08:2c:50:20:89"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.142.13
                    k3s.io/hostname: k3s-worker2.sece.com
                    k3s.io/internal-ip: 192.168.142.13
                    k3s.io/node-args: ["agent"]
                    k3s.io/node-config-hash: IWOFII6CM77JU2SEV73FNXC6ZJMQBHDXVO53R2XSXVWO7VZOUSWQ====
                    k3s.io/node-env: {"K3S_TOKEN":"********","K3S_URL":"https://k3s-master.sece.com:6443"}
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Sun, 31 May 2026 03:20:32 +0000
Taints:             role=database:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  k3s-worker2.sece.com
  AcquireTime:     <unset>
  RenewTime:       Wed, 03 Jun 2026 15:58:18 +0000
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Wed, 03 Jun 2026 15:54:00 +0000   Sun, 31 May 2026 17:42:12 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Wed, 03 Jun 2026 15:54:00 +0000   Sun, 31 May 2026 17:42:12 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Wed, 03 Jun 2026 15:54:00 +0000   Sun, 31 May 2026 17:42:12 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Wed, 03 Jun 2026 15:54:00 +0000   Tue, 02 Jun 2026 06:14:53 +0000   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.142.13
  Hostname:    k3s-worker2.sece.com
Capacity:
  cpu:                2
  ephemeral-storage:  11758760Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             3960880Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  11438921720
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             3960880Ki
  pods:               110
System Info:
  Machine ID:                 a8d44799f41e4591b3e038cdd4d1c8f1
  System UUID:                bd2d4d56-83df-b9c1-a61f-38f32daac65f
  Boot ID:                    d845989b-28df-450d-993b-02638c3ee2b5
  Kernel Version:             6.8.0-117-generic
  OS Image:                   Ubuntu 24.04.4 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://2.2.3-k3s1
  Kubelet Version:            v1.35.5+k3s1
  Kube-Proxy Version:
PodCIDR:                      10.42.1.0/24
PodCIDRs:                     10.42.1.0/24
ProviderID:                   k3s://k3s-worker2.sece.com
Non-terminated Pods:          (4 in total)
  Namespace                   Name                            CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                            ------------  ----------  ---------------  -------------  ---
  default                     nginx-daemonset-mtkcm           0 (0%)        0 (0%)      0 (0%)           0 (0%)         33h
  default                     nginx-pod                       0 (0%)        0 (0%)      0 (0%)           0 (0%)         47h
  dev                         nginx-rs-n5852                  0 (0%)        0 (0%)      0 (0%)           0 (0%)         34h
  kube-system                 svclb-traefik-56ac0f3b-jt47t    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3d12h
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests  Limits
  --------           --------  ------
  cpu                0 (0%)    0 (0%)
  memory             0 (0%)    0 (0%)
  ephemeral-storage  0 (0%)    0 (0%)
  hugepages-1Gi      0 (0%)    0 (0%)
  hugepages-2Mi      0 (0%)    0 (0%)
Events:              <none>

root@k3s-master:~#
root@k3s-master:~# top
top - 16:00:11 up  6:58,  5 users,  load average: 0.32, 0.29, 0.27
Tasks: 256 total,   1 running, 255 sleeping,   0 stopped,   0 zombie
%Cpu(s):  8.6 us,  4.1 sy,  0.0 ni, 86.7 id,  0.0 wa,  0.0 hi,  0.5 si,  0.0 st
MiB Mem :   3868.0 total,   1574.6 free,   1273.3 used,   1261.3 buff/cache
MiB Swap:   2258.0 total,   2258.0 free,      0.0 used.   2594.7 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   3073 root      20   0 1986724 675916 161376 S  11.3  17.1  40:47.75 k3s-server
   3090 root      20   0 1442056 166548 124012 S   0.7   4.2   2:37.86 containerd
   3504 arun      20   0 1296068  67940  46804 S   0.7   1.7   2:00.48 metrics-server
    739 root      20   0  316380  10232   8392 S   0.3   0.3   0:50.94 vmtoolsd
   2945 65532     20   0 1333708  60540  48408 S   0.3   1.5   1:22.14 coredns
   3502 root      20   0 1311780  38904  31696 S   0.3   1.0   0:04.12 local-path-prov
 201435 arun      20   0   15272   7952   5760 S   0.3   0.2   0:04.46 sshd
 207023 root      20   0       0      0      0 I   0.3   0.0   0:00.41 kworker/u256:2-events_power_efficient
 213488 root      20   0       0      0      0 I   0.3   0.0   0:00.66 kworker/1:2-events
 226833 arun      20   0    7340   3700   3440 S   0.3   0.1   0:00.06 bash
 227054 root      20   0   13232   6848   4572 R   0.3   0.2   0:00.07 top
      1 root      20   0   22500  13684   9472 S   0.0   0.3   0:51.27 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.03 kthreadd
      3 root      20   0       0      0      0 S   0.0   0.0   0:00.00 pool_workqueue_release
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-rcu_g
      5 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-rcu_p
      6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-slub_
      7 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-netns
      9 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/0:0H-events_highpri
     12 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-mm_pe
     13 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_tasks_kthread
     14 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_tasks_rude_kthread
     15 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_tasks_trace_kthread
     16 root      20   0       0      0      0 S   0.0   0.0   0:02.66 ksoftirqd/0
     17 root      20   0       0      0      0 I   0.0   0.0   0:15.75 rcu_preempt
     18 root      rt   0       0      0      0 S   0.0   0.0   0:00.37 migration/0
     19 root     -51   0       0      0      0 S   0.0   0.0   0:00.00 idle_inject/0
     20 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/0
     21 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/1
     22 root     -51   0       0      0      0 S   0.0   0.0   0:00.00 idle_inject/1
     23 root      rt   0       0      0      0 S   0.0   0.0   0:01.78 migration/1
     24 root      20   0       0      0      0 S   0.0   0.0   0:03.19 ksoftirqd/1
     27 root      20   0       0      0      0 S   0.0   0.0   0:00.00 kdevtmpfs
root@k3s-master:~# htop
root@k3s-master:~#
root@k3s-master:~# kubectl top node
NAME                   CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k3s-master.sece.com    250m         12%      1408Mi          36%
k3s-worker1.sece.com   35m          1%       695Mi           17%
k3s-worker2.sece.com   29m          1%       614Mi           15%
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl top pod
NAME                                CPU(cores)   MEMORY(bytes)
nginx-daemonset-ffvld               0m           13Mi
nginx-daemonset-mtkcm               0m           13Mi
nginx-daemonset-s7qjj               0m           13Mi
nginx-deployment-5d8dbff9fb-75d59   0m           8Mi
nginx-deployment-5d8dbff9fb-dmlff   0m           9Mi
nginx-deployment-5d8dbff9fb-jzhl8   0m           3Mi
nginx-deployment-5d8dbff9fb-mk4sc   0m           3Mi
nginx-deployment-5d8dbff9fb-ntxcn   0m           3Mi
nginx-deployment-5d8dbff9fb-qbp46   0m           3Mi
nginx-deployment-5d8dbff9fb-tfqdd   0m           3Mi
nginx-deployment-5d8dbff9fb-zr2z5   0m           3Mi
nginx-pod                           0m           8Mi
root@k3s-master:~# kubectl top pod -o wide
error: unknown shorthand flag: 'o' in -o
See 'kubectl top pod --help' for usage.
root@k3s-master:~# kubectl top pod
NAME                                CPU(cores)   MEMORY(bytes)
nginx-daemonset-ffvld               0m           13Mi
nginx-daemonset-mtkcm               0m           13Mi
nginx-daemonset-s7qjj               0m           13Mi
nginx-deployment-5d8dbff9fb-75d59   0m           8Mi
nginx-deployment-5d8dbff9fb-dmlff   0m           9Mi
nginx-deployment-5d8dbff9fb-jzhl8   0m           3Mi
nginx-deployment-5d8dbff9fb-mk4sc   0m           3Mi
nginx-deployment-5d8dbff9fb-ntxcn   0m           3Mi
nginx-deployment-5d8dbff9fb-qbp46   0m           3Mi
nginx-deployment-5d8dbff9fb-tfqdd   0m           3Mi
nginx-deployment-5d8dbff9fb-zr2z5   0m           3Mi
nginx-pod                           0m           8Mi
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl delete deploy nginx-deployment
deployment.apps "nginx-deployment" deleted from default namespace
root@k3s-master:~# cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
root@k3s-master:~# kubectl get node --show-labels
NAME                   STATUS   ROLES           AGE     VERSION        LABELS
k3s-master.sece.com    Ready    control-plane   4d6h    v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-master.sece.com,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node.kubernetes.io/instance-type=k3s
k3s-worker1.sece.com   Ready    <none>          2d22h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker1.sece.com,kubernetes.io/os=linux,name=arun,node.kubernetes.io/instance-type=k3s
k3s-worker2.sece.com   Ready    <none>          3d12h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,env=test,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker2.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
root@k3s-master:~#
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment created
root@k3s-master:~#
root@k3s-master:~# kubectl describe node k3s-worker2.sece.com
Name:               k3s-worker2.sece.com
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=k3s
                    beta.kubernetes.io/os=linux
                    env=test
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k3s-worker2.sece.com
                    kubernetes.io/os=linux
                    node.kubernetes.io/instance-type=k3s
Annotations:        alpha.kubernetes.io/provided-node-ip: 192.168.142.13
                    flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"ee:08:2c:50:20:89"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.142.13
                    k3s.io/hostname: k3s-worker2.sece.com
                    k3s.io/internal-ip: 192.168.142.13
                    k3s.io/node-args: ["agent"]
                    k3s.io/node-config-hash: IWOFII6CM77JU2SEV73FNXC6ZJMQBHDXVO53R2XSXVWO7VZOUSWQ====
                    k3s.io/node-env: {"K3S_TOKEN":"********","K3S_URL":"https://k3s-master.sece.com:6443"}
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Sun, 31 May 2026 03:20:32 +0000
Taints:             role=database:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  k3s-worker2.sece.com
  AcquireTime:     <unset>
  RenewTime:       Wed, 03 Jun 2026 16:07:09 +0000
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Wed, 03 Jun 2026 16:04:13 +0000   Sun, 31 May 2026 17:42:12 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Wed, 03 Jun 2026 16:04:13 +0000   Sun, 31 May 2026 17:42:12 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Wed, 03 Jun 2026 16:04:13 +0000   Sun, 31 May 2026 17:42:12 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Wed, 03 Jun 2026 16:04:13 +0000   Tue, 02 Jun 2026 06:14:53 +0000   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.142.13
  Hostname:    k3s-worker2.sece.com
Capacity:
  cpu:                2
  ephemeral-storage:  11758760Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             3960880Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  11438921720
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             3960880Ki
  pods:               110
System Info:
  Machine ID:                 a8d44799f41e4591b3e038cdd4d1c8f1
  System UUID:                bd2d4d56-83df-b9c1-a61f-38f32daac65f
  Boot ID:                    d845989b-28df-450d-993b-02638c3ee2b5
  Kernel Version:             6.8.0-117-generic
  OS Image:                   Ubuntu 24.04.4 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://2.2.3-k3s1
  Kubelet Version:            v1.35.5+k3s1
  Kube-Proxy Version:
PodCIDR:                      10.42.1.0/24
PodCIDRs:                     10.42.1.0/24
ProviderID:                   k3s://k3s-worker2.sece.com
Non-terminated Pods:          (4 in total)
  Namespace                   Name                            CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                            ------------  ----------  ---------------  -------------  ---
  default                     nginx-daemonset-mtkcm           0 (0%)        0 (0%)      0 (0%)           0 (0%)         33h
  default                     nginx-pod                       0 (0%)        0 (0%)      0 (0%)           0 (0%)         47h
  dev                         nginx-rs-n5852                  0 (0%)        0 (0%)      0 (0%)           0 (0%)         34h
  kube-system                 svclb-traefik-56ac0f3b-jt47t    0 (0%)        0 (0%)      0 (0%)           0 (0%)         3d12h
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests  Limits
  --------           --------  ------
  cpu                0 (0%)    0 (0%)
  memory             0 (0%)    0 (0%)
  ephemeral-storage  0 (0%)    0 (0%)
  hugepages-1Gi      0 (0%)    0 (0%)
  hugepages-2Mi      0 (0%)    0 (0%)
Events:              <none>
root@k3s-master:~# kubectl taint node k3s-worker2.sece.com role-
node/k3s-worker2.sece.com untainted
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  nodeSelector:
    name: arun
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
root@k3s-master:~# cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc

spec:
  ports:
  - port: 80
    targetPort: 80

  selector:
    name: webserver
root@k3s-master:~#
root@k3s-master:~# kubectl api-resources | grep pod
pods                                po           v1                                  true         Pod
podtemplates                                     v1                                  true         PodTemplate
horizontalpodautoscalers            hpa          autoscaling/v2                      true         HorizontalPodAutoscaler
pods                                             metrics.k8s.io/v1beta1              true         PodMetrics
poddisruptionbudgets                pdb          policy/v1                           true         PodDisruptionBudget
root@k3s-master:~# kubectl api-resources | grep replica
replicationcontrollers              rc           v1                                  true         ReplicationController
replicasets                         rs           apps/v1                             true         ReplicaSet
root@k3s-master:~# kubectl api-resources | grep deploy
deployments                         deploy       apps/v1                             true         Deployment
root@k3s-master:~#
root@k3s-master:~# kubectl api-resources | grep ds
pods                                po           v1                                  true         Pod
customresourcedefinitions           crd,crds     apiextensions.k8s.io/v1             false        CustomResourceDefinition
daemonsets                          ds           apps/v1                             true         DaemonSet
managedsubscriptions                             hub.traefik.io/v1alpha1             true         ManagedSubscription
etcdsnapshotfiles                                k3s.cattle.io/v1                    false        ETCDSnapshotFile
pods                                             metrics.k8s.io/v1beta1              true         PodMetrics
root@k3s-master:~#
root@k3s-master:~# kubectl api-resources | grep svc
services                            svc          v1                                  true         Service
root@k3s-master:~# cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc

spec:
  ports:
  - port: 80
    targetPort: 80

  selector:
    name: webserver
root@k3s-master:~# vi service.yaml
root@k3s-master:~# cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc

spec:
  ports:
  - port: 80
    targetPort: 80

  selector:
    app: nginx
root@k3s-master:~# cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  nodeSelector:
    name: arun
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
root@k3s-master:~# vi pod.yaml
root@k3s-master:~# cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
root@k3s-master:~# kubectl apply -f pod.yaml
pod/nginx-pod unchanged
root@k3s-master:~#
root@k3s-master:~# kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP   4d7h
nginx-svc    ClusterIP   10.43.88.152   <none>        80/TCP    6h44m
root@k3s-master:~#
root@k3s-master:~# kubectl replace -f service.yaml
service/nginx-svc replaced
root@k3s-master:~#
root@k3s-master:~# kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP   4d7h
nginx-svc    ClusterIP   10.43.88.152   <none>        80/TCP    6h45m
root@k3s-master:~#
root@k3s-master:~# kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME         ENDPOINTS                                               AGE
kubernetes   192.168.142.11:6443                                     4d7h
nginx-svc    10.42.1.63:80,10.42.1.66:80,10.42.1.67:80 + 8 more...   6h45m
root@k3s-master:~# kubectl describe deployment.apps/nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Wed, 03 Jun 2026 16:06:28 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx:1.29
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  env=test
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-5d8dbff9fb (10/10 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  34m   deployment-controller  Scaled up replica set nginx-deployment-5d8dbff9fb from 0 to 10
root@k3s-master:~#
root@k3s-master:~# kubectl describe pod/nginx-deployment-5d8dbff9fb-25jlp
Name:             nginx-deployment-5d8dbff9fb-25jlp
Namespace:        default
Priority:         0
Service Account:  default
Node:             k3s-worker2.sece.com/192.168.142.13
Start Time:       Wed, 03 Jun 2026 16:08:30 +0000
Labels:           app=nginx
                  pod-template-hash=5d8dbff9fb
Annotations:      <none>
Status:           Running
IP:               10.42.1.73
IPs:
  IP:           10.42.1.73
Controlled By:  ReplicaSet/nginx-deployment-5d8dbff9fb
Containers:
  nginx:
    Container ID:   containerd://37bf3a2a930963497f791857de37a8100da9dc2ddad732362a8f5dd710dc63a2
    Image:          nginx:1.29
    Image ID:       docker.io/library/nginx@sha256:1881968aff6f7cdcc4b888c00a11f4ce241ad7ec957e0cb4a9e19e93a3ff87ea
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 03 Jun 2026 16:08:35 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rgdkl (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-rgdkl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              env=test
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  34m   default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint(s), 2 node(s) didn't match Pod's node affinity/selector. no new claims to deallocate, preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
  Normal   Scheduled         32m   default-scheduler  Successfully assigned default/nginx-deployment-5d8dbff9fb-25jlp to k3s-worker2.sece.com
  Normal   Pulled            32m   kubelet            spec.containers{nginx}: Container image "nginx:1.29" already present on machine and can be accessed by the pod
  Normal   Created           32m   kubelet            spec.containers{nginx}: Container created
  Normal   Started           32m   kubelet            spec.containers{nginx}: Container started
root@k3s-master:~#
root@k3s-master:~# kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME         ENDPOINTS                                               AGE
kubernetes   192.168.142.11:6443                                     4d7h
nginx-svc    10.42.1.63:80,10.42.1.66:80,10.42.1.67:80 + 8 more...   6h47m
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
The Deployment "nginx-deployment" is invalid: spec.template.metadata.labels: Invalid value: {"app":"http"}: `selector` does not match template `labels`
root@k3s-master:~#
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~#
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
The Deployment "nginx-deployment" is invalid: spec.selector: Invalid value: {"matchLabels":{"app":"http"}}: field is immutable
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
The Deployment "nginx-deployment" is invalid: spec.selector: Invalid value: {"matchLabels":{"app":"sk"}}: field is immutable
root@k3s-master:~#
root@k3s-master:~# kubectl delete deployment.apps/nginx-deployment
deployment.apps "nginx-deployment" deleted from default namespace
root@k3s-master:~# kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME         ENDPOINTS             AGE
kubernetes   192.168.142.11:6443   4d7h
nginx-svc    10.42.1.63:80         6h51m
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP   4d7h
nginx-svc    ClusterIP   10.43.88.152   <none>        80/TCP    6h51m
root@k3s-master:~# kubectl describe svc nginx-svc
Name:                     nginx-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=nginx
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.88.152
IPs:                      10.43.88.152
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                10.42.1.63:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
root@k3s-master:~# curl 10.43.88.152
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy,
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@k3s-master:~# kubectl delete pod/nginx-pod
pod "nginx-pod" deleted from default namespace
root@k3s-master:~# cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: sk
  template:
    metadata:
      labels:
        app: sk
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# vi service.yaml
root@k3s-master:~# cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
root@k3s-master:~#
root@k3s-master:~# cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: sk
  template:
    metadata:
      labels:
        app: sk
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
root@k3s-master:~#
root@k3s-master:~# vi service.yaml
root@k3s-master:~# cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc

spec:
  ports:
  - port: 80
    targetPort: 80

  selector:
    app: sk
root@k3s-master:~#
root@k3s-master:~# kubectl create -f nginx-deployment.yaml
deployment.apps/nginx-deployment created
root@k3s-master:~# kubectl create -f service.yaml
Error from server (AlreadyExists): error when creating "service.yaml": services "nginx-svc" already exists
root@k3s-master:~# kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP   4d7h
nginx-svc    ClusterIP   10.43.88.152   <none>        80/TCP    7h1m
root@k3s-master:~# kubectl delete svc nginx-svc
service "nginx-svc" deleted from default namespace
root@k3s-master:~# kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   4d7h
root@k3s-master:~# kubectl create -f service.yaml
service/nginx-svc created
root@k3s-master:~# kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1       <none>        443/TCP   4d7h
nginx-svc    ClusterIP   10.43.241.254   <none>        80/TCP    2s
root@k3s-master:~# kubectl describe svc nginx-svc
Name:                     nginx-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=sk
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.241.254
IPs:                      10.43.241.254
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                10.42.1.84:80,10.42.1.81:80,10.42.1.76:80 + 7 more...
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# curl 10.43.241.254
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy,
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@k3s-master:~# kubectl delete pod/nginx-deployment-799ddc88c8-2pwkm
pod "nginx-deployment-799ddc88c8-2pwkm" deleted from default namespace
root@k3s-master:~#
root@k3s-master:~# kubectl describe svc nginx-svc
Name:                     nginx-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=sk
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.241.254
IPs:                      10.43.241.254
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                10.42.1.81:80,10.42.1.76:80,10.42.1.79:80 + 7 more...
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
root@k3s-master:~#
root@k3s-master:~# curl 10.43.241.254
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy,
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@k3s-master:~# vi service.yaml
root@k3s-master:~# cp service.yaml nodeport-svc.yaml
root@k3s-master:~# vi nodeport-svc.yaml
root@k3s-master:~# kubectl explain cluster
the server doesn't have a resource type "cluster"
root@k3s-master:~# kubectl explain clusterip
the server doesn't have a resource type "clusterip"
root@k3s-master:~# kubectl explain nodeport
the server doesn't have a resource type "nodeport"
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl explain svc
KIND:       Service
VERSION:    v1

DESCRIPTION:
    Service is a named abstraction of software service (for example, mysql)
    consisting of local port (for example 3306) that the proxy listens on, and
    the selector that determines which pods will answer requests sent through
    the proxy.

FIELDS:
  apiVersion    <string>
    APIVersion defines the versioned schema of this representation of an object.
    Servers should convert recognized schemas to the latest internal value, and
    may reject unrecognized values. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources

  kind  <string>
    Kind is a string value representing the REST resource this object
    represents. Servers may infer this from the endpoint the client submits
    requests to. Cannot be updated. In CamelCase. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds

  metadata      <ObjectMeta>
    Standard object's metadata. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

  spec  <ServiceSpec>
    Spec defines the behavior of a service.
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

  status        <ServiceStatus>
    Most recently observed status of the service. Populated by the system.
    Read-only. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status


root@k3s-master:~# vi nodeport-svc.yaml
root@k3s-master:~# cat nodeport-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc

spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80

  selector:
    app: sk
root@k3s-master:~#
root@k3s-master:~# kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1       <none>        443/TCP   4d7h
nginx-svc    ClusterIP   10.43.241.254   <none>        80/TCP    31m
root@k3s-master:~#
root@k3s-master:~# kubectl create -f nodeport-svc.yaml
Error from server (AlreadyExists): error when creating "nodeport-svc.yaml": services "nginx-svc" already exists
root@k3s-master:~# vi nodeport-svc.yaml
root@k3s-master:~#
root@k3s-master:~# kubectl create -f nodeport-svc.yaml
service/nginx-nodeport-svc created
root@k3s-master:~# kubectl get svc
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes           ClusterIP   10.43.0.1       <none>        443/TCP        4d7h
nginx-nodeport-svc   NodePort    10.43.218.6     <none>        80:31927/TCP   3s
nginx-svc            ClusterIP   10.43.241.254   <none>        80/TCP         32m
root@k3s-master:~# kubectl describe svc 10.43.218.6
Error from server (NotFound): services "10.43.218.6" not found
root@k3s-master:~# kubectl describe svc nginx-nodeport-svc
Name:                     nginx-nodeport-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=sk
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.218.6
IPs:                      10.43.218.6
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31927/TCP
Endpoints:                10.42.1.83:80,10.42.1.85:80,10.42.1.77:80 + 7 more...
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:                   <none>
root@k3s-master:~# kubectl describe svc nginx-svc
Name:                     nginx-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=sk
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.241.254
IPs:                      10.43.241.254
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                10.42.1.81:80,10.42.1.76:80,10.42.1.79:80 + 7 more...
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
root@k3s-master:~#
root@k3s-master:~# kubectl describe svc nginx-nodeport-svc
Name:                     nginx-nodeport-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=sk
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.218.6
IPs:                      10.43.218.6
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31927/TCP
Endpoints:                10.42.1.83:80,10.42.1.85:80,10.42.1.77:80 + 7 more...
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:                   <none>
root@k3s-master:~#
root@k3s-master:~# kubectl get node -o wide
NAME                   STATUS   ROLES           AGE     VERSION        INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k3s-master.sece.com    Ready    control-plane   4d7h    v1.35.5+k3s1   192.168.142.11   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.3-k3s1
k3s-worker1.sece.com   Ready    <none>          2d23h   v1.35.5+k3s1   192.168.142.12   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.3-k3s1
k3s-worker2.sece.com   Ready    <none>          3d14h   v1.35.5+k3s1   192.168.142.13   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.3-k3s1
root@k3s-master:~# curl 192.168.142.13:31927
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy,
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@k3s-master:~# curl 192.168.142.12:31927
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy,
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@k3s-master:~# curl 192.168.142.11:31927
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy,
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@k3s-master:~#
root@k3s-master:~# cp nodeport-svc.yaml np-custom-svc.yaml
root@k3s-master:~# vi np-custom-svc.yaml
root@k3s-master:~#
root@k3s-master:~# cat np-custom-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport-svc

spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31001

  selector:
    app: sk
root@k3s-master:~#
root@k3s-master:~# kubectl create -f np-custom-svc.yaml
Error from server (AlreadyExists): error when creating "np-custom-svc.yaml": services "nginx-nodeport-svc" already exists
root@k3s-master:~# vi np-custom-svc.yaml
root@k3s-master:~#
root@k3s-master:~# kubectl create -f np-custom-svc.yaml
service/nginx-nodeport-custom-svc created
root@k3s-master:~#
root@k3s-master:~# kubectl get svc
NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes                  ClusterIP   10.43.0.1       <none>        443/TCP        4d8h
nginx-nodeport-custom-svc   NodePort    10.43.149.14    <none>        80:31001/TCP   5s
nginx-nodeport-svc          NodePort    10.43.218.6     <none>        80:31927/TCP   12m
nginx-svc                   ClusterIP   10.43.241.254   <none>        80/TCP         44m
root@k3s-master:~# kubectl describe svc nginx-nodeport-custom-svc
Name:                     nginx-nodeport-custom-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=sk
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.43.149.14
IPs:                      10.43.149.14
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31001/TCP
Endpoints:                10.42.1.80:80,10.42.1.78:80,10.42.1.82:80 + 7 more...
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:                   <none>
root@k3s-master:~#


<div align="center">

**Lab by Arunkumar** &nbsp;|&nbsp; K3s Cluster @ SECE &nbsp;|&nbsp; Ubuntu 24.04.4 LTS

</div>
