# Kubernetes ReplicaSet Lab

## Overview

This lab demonstrates the creation, verification, scaling, and management of a Kubernetes ReplicaSet using an Nginx container image.

---

## ReplicaSet Configuration

Create a file named `replicaset.yaml`.

```yaml
apiVersion: apps/v1
kind: ReplicaSet

metadata:
  name: nginx-replicaset
  labels:
    app: nginx
    env: prod

spec:
  replicas: 10

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
        image: nginx
        ports:
        - containerPort: 80
```

---

## Create ReplicaSet

Apply the configuration file:

```bash
kubectl create -f replicaset.yaml
```

Expected Output:

```bash
replicaset.apps/nginx-replicaset created
```

---

## Verify ReplicaSet Creation

View all ReplicaSets:

```bash
kubectl get rs
```

Example Output:

```bash
NAME               DESIRED   CURRENT   READY   AGE
nginx-replicaset   10        10        10      30s
```

---

## Verify Pods Created by ReplicaSet

```bash
kubectl get rs,po
```

Example Output:

```bash
NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-replicaset   10        10        10      30s

NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-replicaset-48nn7   1/1     Running   0          30s
pod/nginx-replicaset-4ds7q   1/1     Running   0          30s
pod/nginx-replicaset-4nn2c   1/1     Running   0          30s
pod/nginx-replicaset-9vp5s   1/1     Running   0          30s
pod/nginx-replicaset-c7wml   1/1     Running   0          30s
pod/nginx-replicaset-knwws   1/1     Running   0          30s
pod/nginx-replicaset-pb8xp   1/1     Running   0          30s
pod/nginx-replicaset-q8khg   1/1     Running   0          30s
pod/nginx-replicaset-vg75l   1/1     Running   0          30s
pod/nginx-replicaset-zbnnx   1/1     Running   0          30s
```

---

## View Detailed Information

```bash
kubectl describe rs nginx-replicaset
```

Sample Output:

```text
Name:         nginx-replicaset
Namespace:    default
Selector:     app=nginx-app
Labels:       app=nginx
              env=prod

Replicas:     10 current / 10 desired

Pod Template:
  Labels: app=nginx-app

Containers:
  nginx-container:
    Image: nginx
    Port: 80/TCP
```

---

## Display Additional Details

```bash
kubectl get rs nginx-replicaset -o wide
```

Example Output:

```bash
NAME               DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES   SELECTOR
nginx-replicaset   10        10        10      2m    nginx-container   nginx    app=nginx-app
```

---

## View Pod Placement Across Nodes

```bash
kubectl get rs,po -o wide
```

Example Output:

```bash
NAME                               DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES   SELECTOR
replicaset.apps/nginx-replicaset   10        10        10      2m    nginx-container   nginx    app=nginx-app

NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE
pod/nginx-replicaset-48nn7   1/1     Running   0          2m    192.168.1.54    node01
pod/nginx-replicaset-4ds7q   1/1     Running   0          2m    192.168.0.1     controlplane
...
```

---

## Scale ReplicaSet Up

Increase replicas from 10 to 15.

```bash
kubectl scale rs nginx-replicaset --replicas=15
```

Expected Output:

```bash
replicaset.apps/nginx-replicaset scaled
```

Verify:

```bash
kubectl get rs,po
```

Example Output:

```bash
NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-replicaset   15        15        15      6m
```

Additional Pods are automatically created.

---

## Scale ReplicaSet Down

Reduce replicas from 15 to 7.

```bash
kubectl scale rs nginx-replicaset --replicas=7
```

Expected Output:

```bash
replicaset.apps/nginx-replicaset scaled
```

Verify:

```bash
kubectl get rs,po -o wide
```

Example Output:

```bash
NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-replicaset   7         7         7       13m
```

Kubernetes automatically removes excess Pods and maintains the desired count.

---

## Common Errors

### Incorrect Command

```bash
kubectl replicaset nginx-replicaset --replicas=15
```

Output:

```bash
error: unknown command "replicaset" for "kubectl"
```

### Correct Command

```bash
kubectl scale rs nginx-replicaset --replicas=15
```

---

## Useful Commands Reference

### Create ReplicaSet

```bash
kubectl create -f replicaset.yaml
```

### List ReplicaSets

```bash
kubectl get rs
```

### List Pods

```bash
kubectl get po
```

### List ReplicaSets and Pods

```bash
kubectl get rs,po
```

### Detailed ReplicaSet Information

```bash
kubectl describe rs nginx-replicaset
```

### Scale Up

```bash
kubectl scale rs nginx-replicaset --replicas=15
```

### Scale Down

```bash
kubectl scale rs nginx-replicaset --replicas=7
```

### Delete ReplicaSet

```bash
kubectl delete rs nginx-replicaset
```

---

## Conclusion

ReplicaSet ensures that the specified number of Pod replicas are always running. If a Pod fails or is deleted, ReplicaSet automatically creates a replacement Pod to maintain the desired state of the application.


root@controlplane:~$ vi replicaset.yaml 
root@controlplane:~$ cat replicaset.yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  labels:
    app: nginx
    env: prod
spec:
  replicas: 10
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
        image: nginx
        ports:
        - containerPort: 80
root@controlplane:~$ kubectl create -f replicaset.yaml          
replicaset.apps/nginx-replicaset created
root@controlplane:~$ kubectl get rs
NAME               DESIRED   CURRENT   READY   AGE
nginx-replicaset   10        10        6       16s
root@controlplane:~$ kubectl get rs,pd
error: the server doesn't have a resource type "pd"
root@controlplane:~$ kubectl get rs,po
NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-replicaset   10        10        10      30s

NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-replicaset-48nn7   1/1     Running   0          30s
pod/nginx-replicaset-4ds7q   1/1     Running   0          30s
pod/nginx-replicaset-4nn2c   1/1     Running   0          30s
pod/nginx-replicaset-9vp5s   1/1     Running   0          30s
pod/nginx-replicaset-c7wml   1/1     Running   0          30s
pod/nginx-replicaset-knwws   1/1     Running   0          30s
pod/nginx-replicaset-pb8xp   1/1     Running   0          30s
pod/nginx-replicaset-q8khg   1/1     Running   0          30s
pod/nginx-replicaset-vg75l   1/1     Running   0          30s
pod/nginx-replicaset-zbnnx   1/1     Running   0          30s
root@controlplane:~$ kubectl get rs,po -o wide
NAME                               DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES   SELECTOR
replicaset.apps/nginx-replicaset   10        10        10      64s   nginx-container   nginx    app=nginx-app

NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE           NOMINATED NODE   READINESS GATES
pod/nginx-replicaset-48nn7   1/1     Running   0          64s   192.168.1.54    node01         <none>           <none>
pod/nginx-replicaset-4ds7q   1/1     Running   0          64s   192.168.0.1     controlplane   <none>           <none>
pod/nginx-replicaset-4nn2c   1/1     Running   0          64s   192.168.1.18    node01         <none>           <none>
pod/nginx-replicaset-9vp5s   1/1     Running   0          64s   192.168.1.109   node01         <none>           <none>
pod/nginx-replicaset-c7wml   1/1     Running   0          64s   192.168.0.86    controlplane   <none>           <none>
pod/nginx-replicaset-knwws   1/1     Running   0          64s   192.168.0.126   controlplane   <none>           <none>
pod/nginx-replicaset-pb8xp   1/1     Running   0          64s   192.168.0.225   controlplane   <none>           <none>
pod/nginx-replicaset-q8khg   1/1     Running   0          64s   192.168.0.112   controlplane   <none>           <none>
pod/nginx-replicaset-vg75l   1/1     Running   0          64s   192.168.1.19    node01         <none>           <none>
pod/nginx-replicaset-zbnnx   1/1     Running   0          64s   192.168.1.108   node01         <none>           <none>
root@controlplane:~$ kubectl replicaset ngninx-replicaset --replicas 15
error: unknown command "replicaset" for "kubectl"
root@controlplane:~$ kubectl replicaset ngninx-replicaset --replicas=15
error: unknown command "replicaset" for "kubectl"
root@controlplane:~$ kubectl scale rs nginx-replicaset --replicas=15
replicaset.apps/nginx-replicaset scaled
root@controlplane:~$ kubectl get rs,po
NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-replicaset   15        15        15      6m55s

NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-replicaset-48nn7   1/1     Running   0          6m55s
pod/nginx-replicaset-4ds7q   1/1     Running   0          6m55s
pod/nginx-replicaset-4nn2c   1/1     Running   0          6m55s
pod/nginx-replicaset-9vp5s   1/1     Running   0          6m55s
pod/nginx-replicaset-c7wml   1/1     Running   0          6m55s
pod/nginx-replicaset-cgt2m   1/1     Running   0          28s
pod/nginx-replicaset-dsrgc   1/1     Running   0          28s
pod/nginx-replicaset-hmsbs   1/1     Running   0          28s
pod/nginx-replicaset-knwws   1/1     Running   0          6m55s
pod/nginx-replicaset-pb8xp   1/1     Running   0          6m55s
pod/nginx-replicaset-q8khg   1/1     Running   0          6m55s
pod/nginx-replicaset-tcpgx   1/1     Running   0          28s
pod/nginx-replicaset-vg75l   1/1     Running   0          6m55s
pod/nginx-replicaset-wqq4f   1/1     Running   0          28s
pod/nginx-replicaset-zbnnx   1/1     Running   0          6m55s
root@controlplane:~$ kubectl describe rs replicaset.yaml
Error from server (NotFound): replicasets.apps "replicaset.yaml" not found
root@controlplane:~$ ^C
root@controlplane:~$ kubectl describe rs nginx-replicaset
Name:         nginx-replicaset
Namespace:    default
Selector:     app=nginx-app
Labels:       app=nginx
              env=prod
Annotations:  <none>
Replicas:     15 current / 15 desired
Pods Status:  15 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx-app
  Containers:
   nginx-container:
    Image:         nginx
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:
  Type    Reason            Age                   From                   Message
  ----    ------            ----                  ----                   -------
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-zbnnx
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-pb8xp
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-4nn2c
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-4ds7q
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-9vp5s
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-q8khg
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-48nn7
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-knwws
  Normal  SuccessfulCreate  9m31s                 replicaset-controller  Created pod: nginx-replicaset-vg75l
  Normal  SuccessfulCreate  3m4s (x6 over 9m30s)  replicaset-controller  (combined from similar events): Created pod: nginx-replicaset-wqq4f
root@controlplane:~$ kubectl describe rs replicaset.yaml
Error from server (NotFound): replicasets.apps "replicaset.yaml" not found
root@controlplane:~$ kubectl get rs                
NAME               DESIRED   CURRENT   READY   AGE
nginx-replicaset   15        15        15      11m
root@controlplane:~$ kubectl get rs nginx-replicaset 
NAME               DESIRED   CURRENT   READY   AGE
nginx-replicaset   15        15        15      11m
root@controlplane:~$ kubectl get rs nginx-replicaset -o wide
NAME               DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES   SELECTOR
nginx-replicaset   15        15        15      11m   nginx-container   nginx    app=nginx-app
root@controlplane:~$ kubectl describe rs nginx-replicaset^C
root@controlplane:~$ kubectl get rs,po -o wide
NAME                               DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES   SELECTOR
replicaset.apps/nginx-replicaset   15        15        15      12m   nginx-container   nginx    app=nginx-app

NAME                         READY   STATUS    RESTARTS   AGE    IP              NODE           NOMINATED NODE   READINESS GATES
pod/nginx-replicaset-48nn7   1/1     Running   0          12m    192.168.1.54    node01         <none>           <none>
pod/nginx-replicaset-4ds7q   1/1     Running   0          12m    192.168.0.1     controlplane   <none>           <none>
pod/nginx-replicaset-4nn2c   1/1     Running   0          12m    192.168.1.18    node01         <none>           <none>
pod/nginx-replicaset-9vp5s   1/1     Running   0          12m    192.168.1.109   node01         <none>           <none>
pod/nginx-replicaset-c7wml   1/1     Running   0          12m    192.168.0.86    controlplane   <none>           <none>
pod/nginx-replicaset-cgt2m   1/1     Running   0          6m4s   192.168.0.45    controlplane   <none>           <none>
pod/nginx-replicaset-dsrgc   1/1     Running   0          6m4s   192.168.1.191   node01         <none>           <none>
pod/nginx-replicaset-hmsbs   1/1     Running   0          6m4s   192.168.0.29    controlplane   <none>           <none>
pod/nginx-replicaset-knwws   1/1     Running   0          12m    192.168.0.126   controlplane   <none>           <none>
pod/nginx-replicaset-pb8xp   1/1     Running   0          12m    192.168.0.225   controlplane   <none>           <none>
pod/nginx-replicaset-q8khg   1/1     Running   0          12m    192.168.0.112   controlplane   <none>           <none>
pod/nginx-replicaset-tcpgx   1/1     Running   0          6m4s   192.168.1.34    node01         <none>           <none>
pod/nginx-replicaset-vg75l   1/1     Running   0          12m    192.168.1.19    node01         <none>           <none>
pod/nginx-replicaset-wqq4f   1/1     Running   0          6m4s   192.168.1.245   node01         <none>           <none>
pod/nginx-replicaset-zbnnx   1/1     Running   0          12m    192.168.1.108   node01         <none>           <none>
root@controlplane:~$ kubectl describe rs nginx-replicaset
Name:         nginx-replicaset
Namespace:    default
Selector:     app=nginx-app
Labels:       app=nginx
              env=prod
Annotations:  <none>
Replicas:     15 current / 15 desired
Pods Status:  15 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx-app
  Containers:
   nginx-container:
    Image:         nginx
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:
  Type    Reason            Age                  From                   Message
  ----    ------            ----                 ----                   -------
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-zbnnx
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-pb8xp
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-4nn2c
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-4ds7q
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-9vp5s
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-q8khg
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-48nn7
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-knwws
  Normal  SuccessfulCreate  12m                  replicaset-controller  Created pod: nginx-replicaset-vg75l
  Normal  SuccessfulCreate  6m21s (x6 over 12m)  replicaset-controller  (combined from similar events): Created pod: nginx-replicaset-wqq4f
root@controlplane:~$ kubectl scale rs nginx-replicaset --replicas=7 
replicaset.apps/nginx-replicaset scaled
root@controlplane:~$ kubectl get rs,po -o wide
NAME                               DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES   SELECTOR
replicaset.apps/nginx-replicaset   7         7         7       13m   nginx-container   nginx    app=nginx-app

NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE           NOMINATED NODE   READINESS GATES
pod/nginx-replicaset-48nn7   1/1     Running   0          13m   192.168.1.54    node01         <none>           <none>
pod/nginx-replicaset-4ds7q   1/1     Running   0          13m   192.168.0.1     controlplane   <none>           <none>
pod/nginx-replicaset-c7wml   1/1     Running   0          13m   192.168.0.86    controlplane   <none>           <none>
pod/nginx-replicaset-pb8xp   1/1     Running   0          13m   192.168.0.225   controlplane   <none>           <none>
pod/nginx-replicaset-q8khg   1/1     Running   0          13m   192.168.0.112   controlplane   <none>           <none>
pod/nginx-replicaset-vg75l   1/1     Running   0          13m   192.168.1.19    node01         <none>           <none>
pod/nginx-replicaset-zbnnx   1/1     Running   0          13m   192.168.1.108   node01         <none>           <none>
root@controlplane:~$ 
