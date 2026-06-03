# Kubernetes Deployment Lab

## Overview

This lab demonstrates how to create, scale, update, monitor, and rollback a Kubernetes Deployment using the Nginx container image. It also illustrates how Deployments manage ReplicaSets and Pods during rolling updates.

---

## Create ReplicaSet

Create a file named `nginx-rs.yaml`.

```yaml
apiVersion: apps/v1
kind: ReplicaSet

metadata:
  name: nginx-rs

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

Apply the ReplicaSet:

```bash
kubectl apply -f nginx-rs.yaml
```

Verify:

```bash
kubectl get rs
```

Output:

```bash
NAME       DESIRED   CURRENT   READY
nginx-rs   3         3         3
```

---

## Create Deployment

Create a file named `nginx-deployment.yaml`.

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx-deployment

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
        image: nginx:1.25
        ports:
        - containerPort: 80
```

Apply the Deployment:

```bash
kubectl apply -f nginx-deployment.yaml
```

Output:

```bash
deployment.apps/nginx-deployment created
```

---

## Verify Deployment

```bash
kubectl get deploy
```

Output:

```bash
NAME               READY   UP-TO-DATE   AVAILABLE
nginx-deployment   3/3     3            3
```

View Pods:

```bash
kubectl get po -o wide
```

View Deployment details:

```bash
kubectl describe deploy nginx-deployment
```

---

## Scale Deployment

Edit the deployment YAML and change replicas from 3 to 10.

```yaml
spec:
  replicas: 10
```

Apply the updated file:

```bash
kubectl apply -f nginx-deployment.yaml
```

Verify:

```bash
kubectl get deploy
```

Output:

```bash
NAME               READY   UP-TO-DATE   AVAILABLE
nginx-deployment   10/10   10           10
```

Check Pods:

```bash
kubectl get po -o wide
```

Check ReplicaSets:

```bash
kubectl get rs
```

Output:

```bash
NAME                          DESIRED   CURRENT   READY
nginx-deployment-569f95f5cb   10        10        10
nginx-rs                      3         3         3
```

---

## View Deployment, ReplicaSets and Pods Together

```bash
kubectl get deploy,rs,po -o wide
```

Output:

```bash
deployment.apps/nginx-deployment

replicaset.apps/nginx-deployment-569f95f5cb

pod/nginx-deployment-569f95f5cb-xxxxx
```

This command displays:

- Deployment details
- ReplicaSet details
- Pod details
- Images
- IP addresses
- Node placement

---

## Rolling Update

Update the deployment image from:

```yaml
image: nginx:1.25
```

to:

```yaml
image: nginx:1.26
```

Or update directly using:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26
```

Output:

```bash
deployment.apps/nginx-deployment image updated
```

---

## Observe Rolling Update

Monitor Deployment:

```bash
kubectl get deploy,rs,po -o wide
```

During update you will observe:

### Old ReplicaSet

```bash
nginx-deployment-569f95f5cb
```

### New ReplicaSet

```bash
nginx-deployment-8574879789
```

Example:

```bash
NAME                                          DESIRED   CURRENT   READY
nginx-deployment-569f95f5cb                   8         8         8
nginx-deployment-8574879789                   5         5         5
```

The Deployment gradually:

- Creates Pods from the new ReplicaSet.
- Removes Pods from the old ReplicaSet.
- Maintains application availability throughout the update.

---

## Verify Rollout Status

```bash
kubectl rollout status deployment/nginx-deployment
```

Output:

```bash
deployment "nginx-deployment" successfully rolled out
```

---

## Check Deployment Revision

```bash
kubectl describe deploy nginx-deployment
```

Example:

```text
Annotations:
deployment.kubernetes.io/revision: 2
```

Revision 1:

```text
nginx:1.25
```

Revision 2:

```text
nginx:1.26
```

---

## Rollback Deployment

Rollback to the previous version:

```bash
kubectl rollout undo deployment/nginx-deployment
```

Output:

```bash
deployment.apps/nginx-deployment rolled back
```

---

## Verify Rollback

```bash
kubectl get deploy,rs,po -o wide
```

Output:

```bash
deployment.apps/nginx-deployment   10/10
```

ReplicaSets:

```bash
nginx-deployment-569f95f5cb   10
nginx-deployment-8574879789    0
```

Verify Deployment:

```bash
kubectl describe deploy nginx-deployment
```

Output:

```text
Image: nginx:1.25
Revision: 3
```

The old ReplicaSet becomes active again and the newer ReplicaSet scales down to zero.

---

## Useful Commands

### Create Deployment

```bash
kubectl apply -f nginx-deployment.yaml
```

### List Deployments

```bash
kubectl get deploy
```

### List ReplicaSets

```bash
kubectl get rs
```

### List Pods

```bash
kubectl get po
```

### Describe Deployment

```bash
kubectl describe deploy nginx-deployment
```

### Scale Deployment

```bash
kubectl scale deployment nginx-deployment --replicas=10
```

### Update Image

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26
```

### Check Rollout Status

```bash
kubectl rollout status deployment/nginx-deployment
```

### View Rollout History

```bash
kubectl rollout history deployment/nginx-deployment
```

### Rollback

```bash
kubectl rollout undo deployment/nginx-deployment
```

### Delete Deployment

```bash
kubectl delete deployment nginx-deployment
```

---

## Conclusion

A Deployment provides declarative updates for Pods and ReplicaSets. It supports scaling, rolling updates, rollback, and self-healing, making it the preferred Kubernetes workload controller for managing stateless applications.


```
arun@192.168.142.11's password:
    ┌──────────────────────────────────────────────────────────────────────┐
    │                 • MobaXterm Personal Edition v26.3 •                 │
    │               (SSH client, X server and network tools)               │
    │                                                                      │
    │ ⮞ SSH session to arun@192.168.142.11                                 │
    │   • Direct SSH      :  ✓                                             │
    │   • SSH compression :  ✓                                             │
    │   • SSH-browser     :  ✓                                             │
    │   • X11-forwarding  :  ✓  (remote display is forwarded through SSH)  │
    │                                                                      │
    │ ⮞ For more info, ctrl+click on help or visit our website.            │
    └──────────────────────────────────────────────────────────────────────┘

Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-117-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Mon Jun  1 03:46:39 AM UTC 2026

  System load:  0.75               Processes:              264
  Usage of /:   55.8% of 11.21GB   Users logged in:        1
  Memory usage: 29%                IPv4 address for ens33: 192.168.142.11
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

48 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Sun May 31 17:25:25 2026 from 192.168.142.1
arun@k3s-master:~$ sudo -i
[sudo] password for arun:
root@k3s-master:~# vi nginx-rs.yaml
root@k3s-master:~# kubectl get rs
No resources found in default namespace.
root@k3s-master:~# kubectl get nginx-rs
error: the server doesn't have a resource type "nginx-rs"
root@k3s-master:~# kubectl apply -f nginx-rs.yaml
replicaset.apps/nginx-rs created
root@k3s-master:~# kubectl get nginx-rs
error: the server doesn't have a resource type "nginx-rs"
root@k3s-master:~# kubectl get rs
NAME       DESIRED   CURRENT   READY   AGE
nginx-rs   3         3         0       17s
root@k3s-master:~# kubectl get po -l app=nginx
NAME             READY   STATUS              RESTARTS   AGE
nginx-rs-9m7gn   0/1     ErrImagePull        0          32s
nginx-rs-j49b6   0/1     ContainerCreating   0          32s
nginx-rs-wsnh9   0/1     ErrImagePull        0          32s
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment created
root@k3s-master:~# kubectl get deploy
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   0/3     3            0           9s
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS              RESTARTS   AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-deployment-569f95f5cb-7khw4   0/1     ContainerCreating   0          18s     <none>       k3s-master.sece.com    <none>           <none>
nginx-deployment-569f95f5cb-lfkgb   0/1     ContainerCreating   0          18s     <none>       k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-xwhwm   0/1     ContainerCreating   0          18s     <none>       k3s-worker2.sece.com   <none>           <none>
nginx-rs-9m7gn                      0/1     ImagePullBackOff    0          4m15s   10.42.1.6    k3s-worker2.sece.com   <none>           <none>
nginx-rs-j49b6                      1/1     Running             0          4m15s   10.42.0.19   k3s-master.sece.com    <none>           <none>
nginx-rs-wsnh9                      0/1     ImagePullBackOff    0          4m15s   10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl describe deploy nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               3 desired | 3 updated | 3 total | 0 available | 3 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx:1.25
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      False   MinimumReplicasUnavailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-569f95f5cb (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  34s   deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 0 to 3
root@k3s-master:~# kubectl get po
NAME                                READY   STATUS              RESTARTS   AGE
nginx-deployment-569f95f5cb-7khw4   0/1     ContainerCreating   0          64s
nginx-deployment-569f95f5cb-lfkgb   0/1     ContainerCreating   0          64s
nginx-deployment-569f95f5cb-xwhwm   0/1     ImagePullBackOff    0          64s
nginx-rs-9m7gn                      0/1     ImagePullBackOff    0          5m1s
nginx-rs-j49b6                      1/1     Running             0          5m1s
nginx-rs-wsnh9                      0/1     ImagePullBackOff    0          5m1s
root@k3s-master:~# cat nginx-replicaset
cat: nginx-replicaset: No such file or directory
root@k3s-master:~# cat nginx-deployment
cat: nginx-deployment: No such file or directory
root@k3s-master:~# cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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
        image: nginx:1.25
        ports:
        - containerPort: 80
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment configured
root@k3s-master:~# cat nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 10
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
        image: nginx:1.25
        ports:
        - containerPort: 80
root@k3s-master:~# kubectl get rs
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-569f95f5cb   10        10        10      10m
nginx-rs                      3         3         3       14m
root@k3s-master:~# kubectl describe deploy nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
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
    Image:         nginx:1.25
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-569f95f5cb (10/10 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  10m   deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 0 to 3
  Normal  ScalingReplicaSet  31s   deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 3 to 10
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-deployment-569f95f5cb-4xg2w   1/1     Running   0          43s   10.42.2.6    k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-7khw4   1/1     Running   0          10m   10.42.0.20   k3s-master.sece.com    <none>           <none>
nginx-deployment-569f95f5cb-ccgh9   1/1     Running   0          43s   10.42.1.9    k3s-worker2.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-gb6hg   1/1     Running   0          43s   10.42.0.22   k3s-master.sece.com    <none>           <none>
nginx-deployment-569f95f5cb-krl69   1/1     Running   0          43s   10.42.2.5    k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-lfkgb   1/1     Running   0          10m   10.42.2.4    k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-vd9fq   1/1     Running   0          43s   10.42.0.21   k3s-master.sece.com    <none>           <none>
nginx-deployment-569f95f5cb-vnzqz   1/1     Running   0          43s   10.42.1.8    k3s-worker2.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-vt42h   1/1     Running   0          43s   10.42.2.7    k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-xwhwm   1/1     Running   0          10m   10.42.1.7    k3s-worker2.sece.com   <none>           <none>
nginx-rs-9m7gn                      1/1     Running   0          14m   10.42.1.6    k3s-worker2.sece.com   <none>           <none>
nginx-rs-j49b6                      1/1     Running   0          14m   10.42.0.19   k3s-master.sece.com    <none>           <none>
nginx-rs-wsnh9                      1/1     Running   0          14m   10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS   AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-deployment-569f95f5cb-4xg2w   1/1     Running   0          5m50s   10.42.2.6    k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-7khw4   1/1     Running   0          15m     10.42.0.20   k3s-master.sece.com    <none>           <none>
nginx-deployment-569f95f5cb-ccgh9   1/1     Running   0          5m50s   10.42.1.9    k3s-worker2.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-gb6hg   1/1     Running   0          5m50s   10.42.0.22   k3s-master.sece.com    <none>           <none>
nginx-deployment-569f95f5cb-krl69   1/1     Running   0          5m50s   10.42.2.5    k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-lfkgb   1/1     Running   0          15m     10.42.2.4    k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-vd9fq   1/1     Running   0          5m50s   10.42.0.21   k3s-master.sece.com    <none>           <none>
nginx-deployment-569f95f5cb-vnzqz   1/1     Running   0          5m50s   10.42.1.8    k3s-worker2.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-vt42h   1/1     Running   0          5m50s   10.42.2.7    k3s-worker1.sece.com   <none>           <none>
nginx-deployment-569f95f5cb-xwhwm   1/1     Running   0          15m     10.42.1.7    k3s-worker2.sece.com   <none>           <none>
nginx-rs-9m7gn                      1/1     Running   0          19m     10.42.1.6    k3s-worker2.sece.com   <none>           <none>
nginx-rs-j49b6                      1/1     Running   0          19m     10.42.0.19   k3s-master.sece.com    <none>           <none>
nginx-rs-wsnh9                      1/1     Running   0          19m     10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl describe deploy nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
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
    Image:         nginx:1.25
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-569f95f5cb (10/10 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  16m    deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 0 to 3
  Normal  ScalingReplicaSet  6m20s  deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 3 to 10
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   10/10   10           10          23m   nginx        nginx:1.25   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   10        10        10      23m   nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-rs                      3         3         3       27m   nginx        nginx        app=nginx

NAME                                    READY   STATUS    RESTARTS   AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-569f95f5cb-4xg2w   1/1     Running   0          13m   10.42.2.6    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-7khw4   1/1     Running   0          23m   10.42.0.20   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-ccgh9   1/1     Running   0          13m   10.42.1.9    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-gb6hg   1/1     Running   0          13m   10.42.0.22   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-krl69   1/1     Running   0          13m   10.42.2.5    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-lfkgb   1/1     Running   0          23m   10.42.2.4    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-vd9fq   1/1     Running   0          13m   10.42.0.21   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-vnzqz   1/1     Running   0          13m   10.42.1.8    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-vt42h   1/1     Running   0          13m   10.42.2.7    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-xwhwm   1/1     Running   0          23m   10.42.1.7    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running   0          27m   10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running   0          27m   10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running   0          27m   10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl set image deployment/nginx-deployment nginx=nginx:1.26
deployment.apps/nginx-deployment image updated
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   8/10    5            8           27m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   8         8         8       27m   nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   5         5         0       3s    nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       31m   nginx        nginx        app=nginx

NAME                                    READY   STATUS              RESTARTS   AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-569f95f5cb-7khw4   1/1     Running             0          27m   10.42.0.20   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-ccgh9   1/1     Running             0          18m   10.42.1.9    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-gb6hg   1/1     Running             0          18m   10.42.0.22   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-krl69   1/1     Running             0          18m   10.42.2.5    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-lfkgb   1/1     Running             0          27m   10.42.2.4    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-vd9fq   1/1     Running             0          18m   10.42.0.21   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-vnzqz   1/1     Running             0          18m   10.42.1.8    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-xwhwm   1/1     Running             0          27m   10.42.1.7    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-5kgqc   0/1     ContainerCreating   0          3s    <none>       k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-9297t   0/1     ContainerCreating   0          3s    <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-hwrhk   0/1     ContainerCreating   0          3s    <none>       k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-pf4bz   0/1     ContainerCreating   0          3s    <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-vbq77   0/1     ContainerCreating   0          3s    <none>       k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running             0          31m   10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running             0          31m   10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running             0          31m   10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   8/10    5            8           29m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   8         8         8       29m    nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5               cb
replicaset.apps/nginx-deployment-8574879789   5         5         0       2m3s   nginx        nginx:1.26   app=nginx,pod-template-hash=85748797               89
replicaset.apps/nginx-rs                      3         3         3       33m    nginx        nginx        app=nginx

NAME                                    READY   STATUS              RESTARTS   AGE    IP           NODE                   NOMINATED NODE   READ               INESS GATES
pod/nginx-deployment-569f95f5cb-7khw4   1/1     Running             0          29m    10.42.0.20   k3s-master.sece.com    <none>           <non               e>
pod/nginx-deployment-569f95f5cb-ccgh9   1/1     Running             0          20m    10.42.1.9    k3s-worker2.sece.com   <none>           <non               e>
pod/nginx-deployment-569f95f5cb-gb6hg   1/1     Running             0          20m    10.42.0.22   k3s-master.sece.com    <none>           <non               e>
pod/nginx-deployment-569f95f5cb-krl69   1/1     Running             0          20m    10.42.2.5    k3s-worker1.sece.com   <none>           <non               e>
pod/nginx-deployment-569f95f5cb-lfkgb   1/1     Running             0          29m    10.42.2.4    k3s-worker1.sece.com   <none>           <non               e>
pod/nginx-deployment-569f95f5cb-vd9fq   1/1     Running             0          20m    10.42.0.21   k3s-master.sece.com    <none>           <non               e>
pod/nginx-deployment-569f95f5cb-vnzqz   1/1     Running             0          20m    10.42.1.8    k3s-worker2.sece.com   <none>           <non               e>
pod/nginx-deployment-569f95f5cb-xwhwm   1/1     Running             0          29m    10.42.1.7    k3s-worker2.sece.com   <none>           <non               e>
pod/nginx-deployment-8574879789-5kgqc   0/1     ImagePullBackOff    0          2m3s   10.42.0.23   k3s-master.sece.com    <none>           <non               e>
pod/nginx-deployment-8574879789-9297t   0/1     ContainerCreating   0          2m3s   <none>       k3s-worker1.sece.com   <none>           <non               e>
pod/nginx-deployment-8574879789-hwrhk   0/1     ContainerCreating   0          2m3s   <none>       k3s-worker2.sece.com   <none>           <non               e>
pod/nginx-deployment-8574879789-pf4bz   0/1     ContainerCreating   0          2m3s   <none>       k3s-worker1.sece.com   <none>           <non               e>
pod/nginx-deployment-8574879789-vbq77   0/1     ContainerCreating   0          2m3s   <none>       k3s-worker2.sece.com   <none>           <non               e>
pod/nginx-rs-9m7gn                      1/1     Running             0          33m    10.42.1.6    k3s-worker2.sece.com   <none>           <non               e>
pod/nginx-rs-j49b6                      1/1     Running             0          33m    10.42.0.19   k3s-master.sece.com    <none>           <non               e>
pod/nginx-rs-wsnh9                      1/1     Running             0          33m    10.42.2.3    k3s-worker1.sece.com   <none>           <non               e>
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   8/10    5            8           30m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   8         8         8       30m     nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   5         5         0       2m11s   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       34m     nginx        nginx        app=nginx

NAME                                    READY   STATUS              RESTARTS   AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-569f95f5cb-7khw4   1/1     Running             0          30m     10.42.0.20   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-ccgh9   1/1     Running             0          20m     10.42.1.9    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-gb6hg   1/1     Running             0          20m     10.42.0.22   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-krl69   1/1     Running             0          20m     10.42.2.5    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-lfkgb   1/1     Running             0          30m     10.42.2.4    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-vd9fq   1/1     Running             0          20m     10.42.0.21   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-vnzqz   1/1     Running             0          20m     10.42.1.8    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-xwhwm   1/1     Running             0          30m     10.42.1.7    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-5kgqc   0/1     ImagePullBackOff    0          2m11s   10.42.0.23   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-9297t   0/1     ContainerCreating   0          2m11s   <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-hwrhk   0/1     ContainerCreating   0          2m11s   <none>       k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-pf4bz   0/1     ContainerCreating   0          2m11s   <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-vbq77   0/1     ContainerCreating   0          2m11s   <none>       k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running             0          34m     10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running             0          34m     10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running             0          34m     10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~#
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   8/10    5            8           30m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   8         8         8       30m     nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   5         5         0       2m21s   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       34m     nginx        nginx        app=nginx

NAME                                    READY   STATUS              RESTARTS   AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-569f95f5cb-7khw4   1/1     Running             0          30m     10.42.0.20   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-ccgh9   1/1     Running             0          20m     10.42.1.9    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-gb6hg   1/1     Running             0          20m     10.42.0.22   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-krl69   1/1     Running             0          20m     10.42.2.5    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-lfkgb   1/1     Running             0          30m     10.42.2.4    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-vd9fq   1/1     Running             0          20m     10.42.0.21   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-vnzqz   1/1     Running             0          20m     10.42.1.8    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-xwhwm   1/1     Running             0          30m     10.42.1.7    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-5kgqc   0/1     ImagePullBackOff    0          2m21s   10.42.0.23   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-9297t   0/1     ContainerCreating   0          2m21s   <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-hwrhk   0/1     ContainerCreating   0          2m21s   <none>       k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-pf4bz   0/1     ContainerCreating   0          2m21s   <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-vbq77   0/1     ContainerCreating   0          2m21s   <none>       k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running             0          34m     10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running             0          34m     10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running             0          34m     10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   8/10    7            8           33m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   6         6         6       33m     nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   7         7         2       5m34s   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       37m     nginx        nginx        app=nginx

NAME                                    READY   STATUS              RESTARTS   AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-569f95f5cb-7khw4   1/1     Running             0          33m     10.42.0.20   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-ccgh9   1/1     Running             0          23m     10.42.1.9    k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-gb6hg   1/1     Running             0          23m     10.42.0.22   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-krl69   1/1     Running             0          23m     10.42.2.5    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-lfkgb   1/1     Running             0          33m     10.42.2.4    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-vd9fq   1/1     Running             0          23m     10.42.0.21   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-5kgqc   0/1     ImagePullBackOff    0          5m34s   10.42.0.23   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-9297t   0/1     ContainerCreating   0          5m34s   <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-frv9m   0/1     ContainerCreating   0          50s     <none>       k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-hwrhk   1/1     Running             0          5m34s   10.42.1.11   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-pf4bz   0/1     ContainerCreating   0          5m34s   <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-r72zb   0/1     ContainerCreating   0          50s     <none>       k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-vbq77   1/1     Running             0          5m34s   10.42.1.10   k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running             0          37m     10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running             0          37m     10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running             0          37m     10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   8/10    10           8           34m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   1         1         1       34m     nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   10        10        7       6m11s   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       38m     nginx        nginx        app=nginx

NAME                                    READY   STATUS              RESTARTS   AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-569f95f5cb-krl69   1/1     Running             0          24m     10.42.2.5    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-5kgqc   0/1     ImagePullBackOff    0          6m11s   10.42.0.23   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-9297t   1/1     Running             0          6m11s   10.42.2.8    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-frv9m   0/1     ContainerCreating   0          87s     <none>       k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-hwrhk   1/1     Running             0          6m11s   10.42.1.11   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-l2rtj   0/1     ContainerCreating   0          11s     <none>       k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-l9qkw   1/1     Running             0          11s     10.42.1.12   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-pf4bz   1/1     Running             0          6m11s   10.42.2.9    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-r72zb   1/1     Running             0          87s     10.42.2.10   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-vbq77   1/1     Running             0          6m11s   10.42.1.10   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-xgp9k   1/1     Running             0          11s     10.42.1.13   k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running             0          38m     10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running             0          38m     10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running             0          38m     10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   8/10    10           8           34m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   1         1         1       34m     nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   10        10        7       6m15s   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       38m     nginx        nginx        app=nginx

NAME                                    READY   STATUS              RESTARTS   AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-569f95f5cb-krl69   1/1     Running             0          24m     10.42.2.5    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-5kgqc   0/1     ImagePullBackOff    0          6m15s   10.42.0.23   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-9297t   1/1     Running             0          6m15s   10.42.2.8    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-frv9m   0/1     ContainerCreating   0          91s     <none>       k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-hwrhk   1/1     Running             0          6m15s   10.42.1.11   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-l2rtj   0/1     ContainerCreating   0          15s     <none>       k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-l9qkw   1/1     Running             0          15s     10.42.1.12   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-pf4bz   1/1     Running             0          6m15s   10.42.2.9    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-r72zb   1/1     Running             0          91s     10.42.2.10   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-vbq77   1/1     Running             0          6m15s   10.42.1.10   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-xgp9k   1/1     Running             0          15s     10.42.1.13   k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running             0          38m     10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running             0          38m     10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running             0          38m     10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   10/10   10           10          51m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   0         0         0       51m   nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   10        10        10      23m   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       55m   nginx        nginx        app=nginx

NAME                                    READY   STATUS    RESTARTS   AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-8574879789-5kgqc   1/1     Running   0          23m   10.42.0.23   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-9297t   1/1     Running   0          23m   10.42.2.8    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-frv9m   1/1     Running   0          18m   10.42.0.24   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-hwrhk   1/1     Running   0          23m   10.42.1.11   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-l2rtj   1/1     Running   0          17m   10.42.0.25   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-l9qkw   1/1     Running   0          17m   10.42.1.12   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-pf4bz   1/1     Running   0          23m   10.42.2.9    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-r72zb   1/1     Running   0          18m   10.42.2.10   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-vbq77   1/1     Running   0          23m   10.42.1.10   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-xgp9k   1/1     Running   0          17m   10.42.1.13   k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running   0          55m   10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running   0          55m   10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running   0          55m   10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl describe deploy nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=nginx
Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx:1.26
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deployment-569f95f5cb (0/0 replicas created)
NewReplicaSet:   nginx-deployment-8574879789 (10/10 replicas created)
Events:          <none>
root@k3s-master:~# ^C
root@k3s-master:~# kubectl rollout status deployment/nginx-deployment --revision=2
deployment "nginx-deployment" successfully rolled out
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   10/10   10           10          128m   nginx        nginx:1.26   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   0         0         0       128m   nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   10        10        10      100m   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       132m   nginx        nginx        app=nginx

NAME                                    READY   STATUS    RESTARTS   AGE    IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-8574879789-5kgqc   1/1     Running   0          100m   10.42.0.23   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-9297t   1/1     Running   0          100m   10.42.2.8    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-frv9m   1/1     Running   0          95m    10.42.0.24   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-hwrhk   1/1     Running   0          100m   10.42.1.11   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-l2rtj   1/1     Running   0          94m    10.42.0.25   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-8574879789-l9qkw   1/1     Running   0          94m    10.42.1.12   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-pf4bz   1/1     Running   0          100m   10.42.2.9    k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-r72zb   1/1     Running   0          95m    10.42.2.10   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-vbq77   1/1     Running   0          100m   10.42.1.10   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-8574879789-xgp9k   1/1     Running   0          94m    10.42.1.13   k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running   0          132m   10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running   0          132m   10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running   0          132m   10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl get rs
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-569f95f5cb   0         0         0       128m
nginx-deployment-8574879789   10        10        10      101m
nginx-rs                      3         3         3       132m
root@k3s-master:~# kubectl describe deploy nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=nginx
Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx:1.26
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deployment-569f95f5cb (0/0 replicas created)
NewReplicaSet:   nginx-deployment-8574879789 (10/10 replicas created)
Events:          <none>
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment configured
root@k3s-master:~# kubectl get rs
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-569f95f5cb   10        10        6       131m
nginx-deployment-8574879789   2         2         2       103m
nginx-rs                      3         3         3       134m
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   10/10   10           10          131m   nginx        nginx:1.25   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   10        10        10      131m   nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-8574879789   0         0         0       103m   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-rs                      3         3         3       135m   nginx        nginx        app=nginx

NAME                                    READY   STATUS    RESTARTS   AGE    IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-deployment-569f95f5cb-2zvsl   1/1     Running   0          39s    10.42.2.14   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-59hzf   1/1     Running   0          43s    10.42.2.11   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-6t8mn   1/1     Running   0          39s    10.42.0.28   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-7hzss   1/1     Running   0          40s    10.42.2.13   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-9v9gj   1/1     Running   0          43s    10.42.2.12   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-c9n8k   1/1     Running   0          41s    10.42.0.27   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-h8f8c   1/1     Running   0          40s    10.42.1.16   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-kzsdh   1/1     Running   0          43s    10.42.0.26   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-569f95f5cb-mvnqh   1/1     Running   0          43s    10.42.1.14   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-569f95f5cb-v2l8q   1/1     Running   0          43s    10.42.1.15   k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-9m7gn                      1/1     Running   0          135m   10.42.1.6    k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-j49b6                      1/1     Running   0          135m   10.42.0.19   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-wsnh9                      1/1     Running   0          135m   10.42.2.3    k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# kubectl describe deploy nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 3
Selector:               app=nginx
Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx:1.25
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deployment-8574879789 (0/0 replicas created)
NewReplicaSet:   nginx-deployment-569f95f5cb (10/10 replicas created)
Events:
  Type    Reason             Age                 From                   Message
  ----    ------             ----                ----                   -------
  Normal  ScalingReplicaSet  68s (x2 over 132m)  deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 0 to 3
  Normal  ScalingReplicaSet  68s                 deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 10 to 8
  Normal  ScalingReplicaSet  68s                 deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 3 to 5
  Normal  ScalingReplicaSet  66s                 deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 8 to 7
  Normal  ScalingReplicaSet  66s                 deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 5 to 6
  Normal  ScalingReplicaSet  65s                 deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 7 to 6
  Normal  ScalingReplicaSet  65s                 deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 6 to 7
  Normal  ScalingReplicaSet  65s                 deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 6 to 3
  Normal  ScalingReplicaSet  65s                 deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 7 to 10
  Normal  ScalingReplicaSet  63s (x10 over 98m)  deployment-controller  (combined from similar events): Scaled down replica set nginx-deployment-8574879789 from 1 to 0
root@k3s-master:~# kubectl rollout status deployment/nginx-deployment
deployment "nginx-deployment" successfully rolled out
root@k3s-master:~# kubectl describe deployment nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 3
Selector:               app=nginx
Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx:1.25
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deployment-8574879789 (0/0 replicas created)
NewReplicaSet:   nginx-deployment-569f95f5cb (10/10 replicas created)
Events:
  Type    Reason             Age                    From                   Message
  ----    ------             ----                   ----                   -------
  Normal  ScalingReplicaSet  5m41s (x2 over 136m)   deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 0 to 3
  Normal  ScalingReplicaSet  5m41s                  deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 10 to 8
  Normal  ScalingReplicaSet  5m41s                  deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 3 to 5
  Normal  ScalingReplicaSet  5m39s                  deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 8 to 7
  Normal  ScalingReplicaSet  5m39s                  deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 5 to 6
  Normal  ScalingReplicaSet  5m38s                  deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 7 to 6
  Normal  ScalingReplicaSet  5m38s                  deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 6 to 7
  Normal  ScalingReplicaSet  5m38s                  deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 6 to 3
  Normal  ScalingReplicaSet  5m38s                  deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 7 to 10
  Normal  ScalingReplicaSet  5m36s (x10 over 102m)  deployment-controller  (combined from similar events): Scaled down replica set nginx-deployment-8574879789 from 1 to 0
root@k3s-master:~# kubectl describe deployment nginx-deployment | grep Image
    Image:         nginx:1.25
root@k3s-master:~# kubectl describe deployment nginx-deployment^C
root@k3s-master:~# kubectl rollout undo deployment/nginx-deployment
deployment.apps/nginx-deployment rolled back
root@k3s-master:~# kubectl rollout status deployment/nginx-deployment
deployment "nginx-deployment" successfully rolled out
root@k3s-master:~# kubectl describe deployment nginx-deployment | grep Image
    Image:         nginx:1.26
root@k3s-master:~# kubectl get deploy
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   10/10   10           10          149m
root@k3s-master:~# kubectl describe deploy
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 4
Selector:               app=nginx
Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx:1.26
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deployment-569f95f5cb (0/0 replicas created)
NewReplicaSet:   nginx-deployment-8574879789 (10/10 replicas created)
Events:
  Type    Reason             Age                   From                   Message
  ----    ------             ----                  ----                   -------
  Normal  ScalingReplicaSet  20m                   deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 3 to 5
  Normal  ScalingReplicaSet  20m (x2 over 151m)    deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 0 to 3
  Normal  ScalingReplicaSet  20m                   deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 10 to 8
  Normal  ScalingReplicaSet  20m                   deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 5 to 6
  Normal  ScalingReplicaSet  20m                   deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 8 to 7
  Normal  ScalingReplicaSet  20m                   deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 7 to 10
  Normal  ScalingReplicaSet  20m                   deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 6 to 3
  Normal  ScalingReplicaSet  20m                   deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 6 to 7
  Normal  ScalingReplicaSet  20m                   deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 7 to 6
  Normal  ScalingReplicaSet  6m14s (x2 over 123m)  deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 0 to 3
  Normal  ScalingReplicaSet  6m14s (x2 over 123m)  deployment-controller  Scaled down replica set nginx-deployment-569f95f5cb from 10 to 8
  Normal  ScalingReplicaSet  6m14s (x2 over 123m)  deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 3 to 5
  Normal  ScalingReplicaSet  6m12s (x2 over 118m)  deployment-controller  Scaled down replica set nginx-deployment-569f95f5cb from 8 to 7
  Normal  ScalingReplicaSet  6m12s (x2 over 118m)  deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 5 to 6
  Normal  ScalingReplicaSet  6m11s (x2 over 117m)  deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 7 to 8
  Normal  ScalingReplicaSet  6m11s (x2 over 117m)  deployment-controller  Scaled down replica set nginx-deployment-569f95f5cb from 6 to 5
  Normal  ScalingReplicaSet  6m11s (x2 over 118m)  deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 6 to 7
  Normal  ScalingReplicaSet  6m11s (x2 over 118m)  deployment-controller  Scaled down replica set nginx-deployment-569f95f5cb from 7 to 6
  Normal  ScalingReplicaSet  6m9s (x15 over 117m)  deployment-controller  (combined from similar events): Scaled down replica set nginx-deployment-569f95f5cb from 1 to 0
root@k3s-master:~# kubectl describe deploy nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 01 Jun 2026 04:30:32 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 4
Selector:               app=nginx
Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx:1.26
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deployment-569f95f5cb (0/0 replicas created)
NewReplicaSet:   nginx-deployment-8574879789 (10/10 replicas created)
Events:
  Type    Reason             Age                    From                   Message
  ----    ------             ----                   ----                   -------
  Normal  ScalingReplicaSet  20m                    deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 3 to 5
  Normal  ScalingReplicaSet  20m (x2 over 151m)     deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 0 to 3
  Normal  ScalingReplicaSet  20m                    deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 10 to 8
  Normal  ScalingReplicaSet  20m                    deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 5 to 6
  Normal  ScalingReplicaSet  20m                    deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 8 to 7
  Normal  ScalingReplicaSet  20m                    deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 7 to 10
  Normal  ScalingReplicaSet  20m                    deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 6 to 3
  Normal  ScalingReplicaSet  20m                    deployment-controller  Scaled up replica set nginx-deployment-569f95f5cb from 6 to 7
  Normal  ScalingReplicaSet  20m                    deployment-controller  Scaled down replica set nginx-deployment-8574879789 from 7 to 6
  Normal  ScalingReplicaSet  6m33s (x2 over 123m)   deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 0 to 3
  Normal  ScalingReplicaSet  6m33s (x2 over 123m)   deployment-controller  Scaled down replica set nginx-deployment-569f95f5cb from 10 to 8
  Normal  ScalingReplicaSet  6m33s (x2 over 123m)   deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 3 to 5
  Normal  ScalingReplicaSet  6m31s (x2 over 119m)   deployment-controller  Scaled down replica set nginx-deployment-569f95f5cb from 8 to 7
  Normal  ScalingReplicaSet  6m31s (x2 over 119m)   deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 5 to 6
  Normal  ScalingReplicaSet  6m30s (x2 over 117m)   deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 7 to 8
  Normal  ScalingReplicaSet  6m30s (x2 over 117m)   deployment-controller  Scaled down replica set nginx-deployment-569f95f5cb from 6 to 5
  Normal  ScalingReplicaSet  6m30s (x2 over 119m)   deployment-controller  Scaled up replica set nginx-deployment-8574879789 from 6 to 7
  Normal  ScalingReplicaSet  6m30s (x2 over 119m)   deployment-controller  Scaled down replica set nginx-deployment-569f95f5cb from 7 to 6
  Normal  ScalingReplicaSet  6m28s (x15 over 117m)  deployment-controller  (combined from similar events): Scaled down replica set nginx-deployment-569f95f5cb from 1 to 0
root@k3s-master:~# ^[[200~kubectl describe deploy nginx-deployment | grep Image
kubectl: command not found
root@k3s-master:~# kubectl describe deploy nginx-deployment | grep Image
    Image:         nginx:1.26
root@k3s-master:~# kubectl  get po
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-8574879789-2chfw   1/1     Running   0          10m
nginx-deployment-8574879789-4bz4c   1/1     Running   0          10m
nginx-deployment-8574879789-5jxbs   1/1     Running   0          10m
nginx-deployment-8574879789-6vw27   1/1     Running   0          10m
nginx-deployment-8574879789-bcd26   1/1     Running   0          10m
nginx-deployment-8574879789-dbnfc   1/1     Running   0          10m
nginx-deployment-8574879789-hkqwm   1/1     Running   0          10m
nginx-deployment-8574879789-m7lkl   1/1     Running   0          10m
nginx-deployment-8574879789-s87pl   1/1     Running   0          10m
nginx-deployment-8574879789-whrg9   1/1     Running   0          10m
nginx-rs-9m7gn                      1/1     Running   0          159m
nginx-rs-j49b6                      1/1     Running   0          159m
nginx-rs-wsnh9                      1/1     Running   0          159m
root@k3s-master:~# kubectl delete pod ^C
root@k3s-master:~# kubectl  get po nginx-deployment-8574879789-2chfw
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-8574879789-2chfw   1/1     Running   0          11m
root@k3s-master:~# kubectl get po
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-8574879789-2chfw   1/1     Running   0          12m
nginx-deployment-8574879789-4bz4c   1/1     Running   0          12m
nginx-deployment-8574879789-5jxbs   1/1     Running   0          12m
nginx-deployment-8574879789-6vw27   1/1     Running   0          12m
nginx-deployment-8574879789-bcd26   1/1     Running   0          12m
nginx-deployment-8574879789-dbnfc   1/1     Running   0          12m
nginx-deployment-8574879789-hkqwm   1/1     Running   0          12m
nginx-deployment-8574879789-m7lkl   1/1     Running   0          12m
nginx-deployment-8574879789-s87pl   1/1     Running   0          12m
nginx-deployment-8574879789-whrg9   1/1     Running   0          12m
nginx-rs-9m7gn                      1/1     Running   0          161m
nginx-rs-j49b6                      1/1     Running   0          161m
nginx-rs-wsnh9                      1/1     Running   0          161m
root@k3s-master:~# ^C
root@k3s-master:~# kubectl delete po ^C
root@k3s-master:~# kubectl get po nginx-deployment-8574879789-2chfw
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-8574879789-2chfw   1/1     Running   0          13m
root@k3s-master:~# ^C
root@k3s-master:~# kubectl delete po nginx-deployment-8574879789-2chfw
pod "nginx-deployment-8574879789-2chfw" deleted from default namespace
root@k3s-master:~# kubectl get po
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-8574879789-4bz4c   1/1     Running   0          14m
nginx-deployment-8574879789-5jxbs   1/1     Running   0          14m
nginx-deployment-8574879789-6vw27   1/1     Running   0          14m
nginx-deployment-8574879789-bcd26   1/1     Running   0          14m
nginx-deployment-8574879789-dbnfc   1/1     Running   0          14m
nginx-deployment-8574879789-hkqwm   1/1     Running   0          14m
nginx-deployment-8574879789-m7lkl   1/1     Running   0          14m
nginx-deployment-8574879789-qmdwh   1/1     Running   0          7s
nginx-deployment-8574879789-s87pl   1/1     Running   0          14m
nginx-deployment-8574879789-whrg9   1/1     Running   0          14m
nginx-rs-9m7gn                      1/1     Running   0          163m
nginx-rs-j49b6                      1/1     Running   0          163m
nginx-rs-wsnh9                      1/1     Running   0          163m
root@k3s-master:~#
