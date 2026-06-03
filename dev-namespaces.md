# Kubernetes Deployment in Namespace Lab

## Overview

This lab demonstrates how to deploy an Nginx application inside a custom namespace, inspect Pods, ReplicaSets and Deployments, view logs, scale the application, and perform Deployment rollouts and rollbacks.

---

## Create Deployment in Namespace

Create a file named `deployment.yaml`.

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: deployment
  namespace: dev
  labels:
    app: nginx
    env: prod

spec:
  replicas: 3

  strategy:
    type: Recreate

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
        image: nginx:1.26
        ports:
        - containerPort: 80
```

---

## Common YAML Error

Incorrect field:

```yaml
metadata:
  namespaces: dev
```

Error:

```bash
Error from server (BadRequest):
unknown field "metadata.namespaces"
```

Correct field:

```yaml
metadata:
  namespace: dev
```

---

## Apply Deployment

```bash
kubectl apply -f deployment.yaml
```

Output:

```bash
deployment.apps/deployment created
```

---

## Verify Pods in Namespace

```bash
kubectl get pods -n dev
```

Output:

```bash
NAME                          READY   STATUS
deployment-74b7cd9f45-2s7jz   1/1     Running
deployment-74b7cd9f45-jvdcn   1/1     Running
deployment-74b7cd9f45-vr6k2   1/1     Running
```

---

## View Deployment, ReplicaSet and Pods

```bash
kubectl get deploy,rs,po -o wide -n dev
```

Output:

```bash
NAME                         READY   UP-TO-DATE   AVAILABLE
deployment.apps/deployment   3/3     3            3

NAME                                    DESIRED   CURRENT   READY
replicaset.apps/deployment-74b7cd9f45   3         3         3

NAME                              READY   STATUS
pod/deployment-74b7cd9f45-2s7jz   1/1     Running
pod/deployment-74b7cd9f45-jvdcn   1/1     Running
pod/deployment-74b7cd9f45-vr6k2   1/1     Running
```

---

## Describe Pod

Without namespace:

```bash
kubectl describe pod deployment-74b7cd9f45-2s7jz
```

Output:

```bash
Error from server (NotFound)
```

Correct command:

```bash
kubectl describe pod deployment-74b7cd9f45-2s7jz -n dev
```

Information displayed:

- Pod Name
- Namespace
- Node
- IP Address
- Container Details
- Events
- Volume Information
- Conditions

---

## Describe ReplicaSet

Incorrect:

```bash
kubectl describe rs nginx-rs.yaml -n dev
```

Output:

```bash
Error from server (NotFound)
```

Correct:

```bash
kubectl describe rs nginx-rs -n dev
```

---

## Describe Deployment

Incorrect:

```bash
kubectl describe deploy nginx-deployment.yaml -n dev
```

Output:

```bash
Error from server (NotFound)
```

Correct:

```bash
kubectl describe deploy deployment -n dev
```

Output:

```text
Name: deployment
Namespace: dev
Replicas: 3 desired | 3 available
StrategyType: Recreate
```

---

## View Container Logs

Display Pod logs:

```bash
kubectl logs deployment-74b7cd9f45-2s7jz -n dev
```

Display logs from a specific container:

```bash
kubectl logs deployment-74b7cd9f45-2s7jz nginx-container -n dev
```

Sample Output:

```text
nginx/1.26.3
start worker processes
Container started
```

---

## Scale Deployment

Incorrect:

```bash
kubectl scale deployment nginx-deploy --replicas=5 -n dev
```

Output:

```bash
Error from server (NotFound)
```

Correct:

```bash
kubectl scale deployment deployment --replicas=5 -n dev
```

Scale down:

```bash
kubectl scale deployment deployment --replicas=3 -n dev
```

Scale up again:

```bash
kubectl scale deployment deployment --replicas=5 -n dev
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

## Rollout History

Incorrect:

```bash
kubectl rollout history deployment/nginx-deploy -n dev
```

Output:

```bash
Error from server (NotFound)
```

Correct:

```bash
kubectl rollout history deployment/deployment -n dev
```

Output:

```bash
deployment.apps/deployment

REVISION  CHANGE-CAUSE
1         <none>
```

---

## Update Deployment Image

Update image version:

```bash
kubectl set image deployment/deployment nginx-container=nginx:1.25 -n dev
```

Output:

```bash
deployment.apps/deployment image updated
```

---

## Verify New Revision

```bash
kubectl rollout history deployment/deployment -n dev
```

Output:

```bash
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

---

## Check Rollout Status

```bash
kubectl rollout status deployment/deployment -n dev
```

Output:

```bash
deployment "deployment" successfully rolled out
```

---

## Rollback Deployment

```bash
kubectl rollout undo deployment/deployment -n dev
```

Output:

```bash
deployment.apps/deployment rolled back
```

---

## Useful Commands

### Apply Deployment

```bash
kubectl apply -f deployment.yaml
```

### View Pods

```bash
kubectl get pods -n dev
```

### View Deployments

```bash
kubectl get deploy -n dev
```

### View ReplicaSets

```bash
kubectl get rs -n dev
```

### View Deployment, ReplicaSets and Pods

```bash
kubectl get deploy,rs,po -o wide -n dev
```

### Describe Pod

```bash
kubectl describe pod <pod-name> -n dev
```

### Describe Deployment

```bash
kubectl describe deploy deployment -n dev
```

### View Logs

```bash
kubectl logs <pod-name> -n dev
```

### Scale Deployment

```bash
kubectl scale deployment deployment --replicas=5 -n dev
```

### View Rollout History

```bash
kubectl rollout history deployment/deployment -n dev
```

### Update Image

```bash
kubectl set image deployment/deployment nginx-container=nginx:1.25 -n dev
```

### Rollout Status

```bash
kubectl rollout status deployment/deployment -n dev
```

### Rollback

```bash
kubectl rollout undo deployment/deployment -n dev
```

---

## Conclusion

This lab demonstrated how to deploy an application inside a custom namespace, inspect Kubernetes resources, view container logs, scale Deployments, track rollout revisions, update container images, and perform Deployment rollbacks using Kubernetes Deployment objects. :contentReference[oaicite:0]{index=0}
 
 
 vi deployment.yaml
root@k3s-master:~# kubectl apply -f deployment.yaml
Error from server (BadRequest): error when creating "deployment.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: un                 known field "metadata.namespaces"
root@k3s-master:~# vi deployment.yaml
root@k3s-master:~# kubectl apply -f deployment.yaml
deployment.apps/deployment created
root@k3s-master:~# kubectl get pods -n dev
NAME                          READY   STATUS    RESTARTS   AGE
deployment-74b7cd9f45-2s7jz   1/1     Running   0          10s
deployment-74b7cd9f45-jvdcn   1/1     Running   0          10s
deployment-74b7cd9f45-vr6k2   1/1     Running   0          10s
nginx-rs-n5852                1/1     Running   0          95m
nginx-rs-qp66w                1/1     Running   0          95m
nginx-rs-zv9h6                1/1     Running   0          95m
root@k3s-master:~# kubectl get deploy,rs,po -o wide -n dev
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES       SELECTOR
deployment.apps/deployment   3/3     3            3           50s   nginx-container   nginx:1.26   app=nginx-app

NAME                                    DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES       SELECTOR
replicaset.apps/deployment-74b7cd9f45   3         3         3       49s   nginx-container   nginx:1.26   app=nginx-app,pod-template-hash=74b7cd9f45
replicaset.apps/nginx-rs                3         3         3       95m   nginx             nginx        app=nginx

NAME                              READY   STATUS    RESTARTS   AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
pod/deployment-74b7cd9f45-2s7jz   1/1     Running   0          50s   10.42.2.56   k3s-worker1.sece.com   <none>           <none>
pod/deployment-74b7cd9f45-jvdcn   1/1     Running   0          50s   10.42.1.55   k3s-worker2.sece.com   <none>           <none>
pod/deployment-74b7cd9f45-vr6k2   1/1     Running   0          50s   10.42.0.71   k3s-master.sece.com    <none>           <none>
pod/nginx-rs-n5852                1/1     Running   0          95m   10.42.1.53   k3s-worker2.sece.com   <none>           <none>
pod/nginx-rs-qp66w                1/1     Running   0          95m   10.42.2.54   k3s-worker1.sece.com   <none>           <none>
pod/nginx-rs-zv9h6                1/1     Running   0          95m   10.42.0.69   k3s-master.sece.com    <none>           <none>
root@k3s-master:~# kubectl describe pod ^C
root@k3s-master:~# kubectl describe pod deployment-74b7cd9f45-2s7jz
Error from server (NotFound): pods "deployment-74b7cd9f45-2s7jz" not found
root@k3s-master:~# kubectl describe pod/deployment-74b7cd9f45-2s7jz
Error from server (NotFound): pods "deployment-74b7cd9f45-2s7jz" not found
root@k3s-master:~# kubectl describe pod/deployment-74b7cd9f45-2s7jz -n dev
Name:             deployment-74b7cd9f45-2s7jz
Namespace:        dev
Priority:         0
Service Account:  default
Node:             k3s-worker1.sece.com/192.168.142.12
Start Time:       Tue, 02 Jun 2026 06:42:07 +0000
Labels:           app=nginx-app
                  pod-template-hash=74b7cd9f45
Annotations:      <none>
Status:           Running
IP:               10.42.2.56
IPs:
  IP:           10.42.2.56
Controlled By:  ReplicaSet/deployment-74b7cd9f45
Containers:
  nginx-container:
    Container ID:   containerd://75c40b58fb0892ad822d13695e13123cca47a252be52564fb4f78b620aea62f5
    Image:          nginx:1.26
    Image ID:       docker.io/library/nginx@sha256:41b194461e4bae16f9b25d68b0976ed4735b89ca625c89aad88e1c1c3b7e8860
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Tue, 02 Jun 2026 06:42:08 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hm64n (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-hm64n:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m44s  default-scheduler  Successfully assigned dev/deployment-74b7cd9f45-2s7jz to k3s-worker1.sece.com
  Normal  Pulled     2m44s  kubelet            spec.containers{nginx-container}: Container image "nginx:1.26" already present on machine and can be accessed b                 y the pod
  Normal  Created    2m44s  kubelet            spec.containers{nginx-container}: Container created
  Normal  Started    2m44s  kubelet            spec.containers{nginx-container}: Container started
root@k3s-master:~# kubectl describe rs nginx-rs.yaml
Error from server (NotFound): replicasets.apps "nginx-rs.yaml" not found
root@k3s-master:~# kubectl describe rs nginx-rs.yaml -n dev
Error from server (NotFound): replicasets.apps "nginx-rs.yaml" not found
root@k3s-master:~# kubectl describe rs nginx-rs -n dev
Name:         nginx-rs
Namespace:    dev
Selector:     app=nginx
Labels:       <none>
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:         nginx
    Port:          <none>
    Host Port:     <none>
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  99m   replicaset-controller  Created pod: nginx-rs-qp66w
  Normal  SuccessfulCreate  99m   replicaset-controller  Created pod: nginx-rs-n5852
  Normal  SuccessfulCreate  99m   replicaset-controller  Created pod: nginx-rs-zv9h6
root@k3s-master:~# kubectl describe deploy nginx-deployment.yaml -n dev
Error from server (NotFound): deployments.apps "nginx-deployment.yaml" not found
root@k3s-master:~# kubectl describe deploy deployment -n dev
Name:               deployment
Namespace:          dev
CreationTimestamp:  Tue, 02 Jun 2026 06:42:07 +0000
Labels:             app=nginx
                    env=prod
Annotations:        deployment.kubernetes.io/revision: 1
Selector:           app=nginx-app
Replicas:           3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:       Recreate
MinReadySeconds:    0
Pod Template:
  Labels:  app=nginx-app
  Containers:
   nginx-container:
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
OldReplicaSets:  <none>
NewReplicaSet:   deployment-74b7cd9f45 (3/3 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  5m21s  deployment-controller  Scaled up replica set deployment-74b7cd9f45 from 0 to 3
root@k3s-master:~# vi deployment.yaml
root@k3s-master:~# kubectl logs deployment-74b7cd9f45-2s7jz  -n dev
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/06/02 06:42:08 [notice] 1#1: using the "epoll" event method
2026/06/02 06:42:08 [notice] 1#1: nginx/1.26.3
2026/06/02 06:42:08 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2026/06/02 06:42:08 [notice] 1#1: OS: Linux 6.8.0-117-generic
2026/06/02 06:42:08 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/06/02 06:42:08 [notice] 1#1: start worker processes
2026/06/02 06:42:08 [notice] 1#1: start worker process 29
2026/06/02 06:42:08 [notice] 1#1: start worker process 30
root@k3s-master:~# kubectl logs deployment-74b7cd9f45-2s7jz nginx-container -n dev
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/06/02 06:42:08 [notice] 1#1: using the "epoll" event method
2026/06/02 06:42:08 [notice] 1#1: nginx/1.26.3
2026/06/02 06:42:08 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2026/06/02 06:42:08 [notice] 1#1: OS: Linux 6.8.0-117-generic
2026/06/02 06:42:08 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/06/02 06:42:08 [notice] 1#1: start worker processes
2026/06/02 06:42:08 [notice] 1#1: start worker process 29
2026/06/02 06:42:08 [notice] 1#1: start worker process 30
root@k3s-master:~# kubectl scale deployment nginx-deploy --replicas=5 -n dev
Error from server (NotFound): deployments.apps "nginx-deploy" not found
root@k3s-master:~# kubectl scale deployment deployment --replicas=5 -n dev
deployment.apps/deployment scaled
root@k3s-master:~# kubectl scale deployment deployment --replicas=3 -n dev
deployment.apps/deployment scaled
root@k3s-master:~# kubectl scale deployment deployment --replicas=5 -n dev
deployment.apps/deployment scaled
root@k3s-master:~# vi deployment.yaml
root@k3s-master:~# kubectl get ns
NAME              STATUS   AGE
default           Active   2d21h
dev               Active   108m
kube-node-lease   Active   2d21h
kube-public       Active   2d21h
kube-system       Active   2d21h
root@k3s-master:~# kubectl rollout history deployment/nginx-deploy -n dev
Error from server (NotFound): deployments.apps "nginx-deploy" not found
root@k3s-master:~# kubectl rollout history deployment/deployment -n dev
deployment.apps/deployment
REVISION  CHANGE-CAUSE
1         <none>

root@k3s-master:~# kubectl rollout history deployment/deployment -o wide -n dev
error: unable to match a printer suitable for the output format "wide", allowed formats are: go-template,go-template-file,json,jsonpath,jsonpath-as-json,jsonpath-file,kyaml,name,template,templatefile,yaml
root@k3s-master:~# kubectl set image deployment/nginx-deploy nginx-container=nginx:1.25 -n dev
Error from server (NotFound): deployments.apps "nginx-deploy" not found
root@k3s-master:~# kubectl set image deployment/deployment nginx-container=nginx:1.25 -n dev
deployment.apps/deployment image updated
root@k3s-master:~# kubectl rollout history deployment/deployment -n dev
deployment.apps/deployment
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

root@k3s-master:~# kubectl rollout status deployment/deployment -n dev
deployment "deployment" successfully rolled out
root@k3s-master:~# kubectl rollout undo deployment/deployment -n dev
deployment.apps/deployment rolled back
