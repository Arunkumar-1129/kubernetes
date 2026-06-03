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

<div align="center">

**Lab by Arunkumar** &nbsp;|&nbsp; K3s Cluster @ SECE &nbsp;|&nbsp; Ubuntu 24.04.4 LTS

</div>
