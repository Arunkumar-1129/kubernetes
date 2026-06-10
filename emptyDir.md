Here is a clean GitHub-ready Markdown document for your **Kubernetes EmptyDir Volume Lab** based on your terminal session. Source log: 

# Kubernetes EmptyDir Volume Lab

## Objective

Learn how `emptyDir` volumes work in Kubernetes by:

* Creating a Pod with an EmptyDir volume
* Mounting the volume inside an NGINX container
* Creating web content inside the volume
* Accessing the content through NGINX
* Verifying data persistence across container restarts
* Accessing the volume data directly from the worker node

---

# Lab Architecture

```text
+-----------------------+
|      Kubernetes       |
+-----------------------+
           |
           v
+-----------------------+
|      nginx-pod        |
|-----------------------|
| nginx container       |
|                       |
| /usr/share/nginx/html |
|          |            |
|          v            |
|     emptyDir Volume   |
+-----------------------+
           |
           v
Worker Node Filesystem

/var/lib/kubelet/pods/<pod-uid>/volumes/
```

---

# Step 1: Verify Existing Resources

```bash
kubectl get all
```

### Output

```bash
NAME                       READY   STATUS
pod/nginx-pod              1/1     Running
pod/php-6d75964bd5-cshjp   1/1     Running
pod/php-6d75964bd5-kz76d   1/1     Running
pod/php-6d75964bd5-mtnwl   1/1     Running
pod/sql-pod                1/1     Running
```

---

# Step 2: Clean Existing Resources

## Delete Deployment

```bash
kubectl delete deployment.apps/php
```

### Output

```bash
deployment.apps "php" deleted
```

---

## Delete Services

```bash
kubectl delete svc nginx-service php-service
```

### Output

```bash
service "nginx-service" deleted
service "php-service" deleted
```

---

## Delete Standalone Pods

```bash
kubectl delete po nginx-pod sql-pod
```

### Output

```bash
pod "nginx-pod" deleted
pod "sql-pod" deleted
```

---

# Step 3: Create EmptyDir Pod Manifest

## emptydir-vol.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod

spec:
  containers:
  - name: nginx-container
    image: nginx:latest

    volumeMounts:
    - name: mydata
      mountPath: /usr/share/nginx/html

  volumes:
  - name: mydata
    emptyDir: {}
```

---

# Step 4: Create Pod

```bash
kubectl apply -f emptydir-vol.yaml
```

### Output

```bash
pod/nginx-pod created
```

---

# Step 5: Verify Pod Status

```bash
kubectl get po
```

### Output

```bash
NAME        READY   STATUS
nginx-pod   1/1     Running
```

---

# Step 6: Check Pod Location

```bash
kubectl get po -o wide
```

### Output

```bash
NAME        READY   STATUS    IP            NODE
nginx-pod   1/1     Running   10.42.2.104   k3s-worker2.sece.com
```

---

# Step 7: Login Into Container

```bash
kubectl exec -it nginx-pod -- bash
```

---

# Step 8: Move to NGINX Web Directory

```bash
cd /usr/share/nginx/html
```

---

# Step 9: Create Web Page

```bash
cat > index.html
```

Enter:

```text
this is my web page,
edited on worker node 2
```

Press:

```text
Ctrl + C
```

---

# Step 10: Verify Content

```bash
cat index.html
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 11: Test Using Pod IP

Get Pod IP:

```bash
kubectl get po -o wide
```

### Output

```bash
10.42.2.104
```

Access NGINX:

```bash
curl 10.42.2.104
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 12: Verify EmptyDir Volume Configuration

```bash
kubectl get po -o yaml
```

Relevant section:

```yaml
volumeMounts:
- mountPath: /usr/share/nginx/html
  name: mydata

volumes:
- emptyDir: {}
  name: mydata
```

---

# Step 13: Find Pod UID

```bash
kubectl get po -o yaml | grep uid
```

### Output

```bash
uid: 68b25574-50c5-4aa5-93a7-b495a7caa1a1
```

---

# Step 14: Verify Data on Worker Node

Login to worker node.

```bash
sudo -i
```

Move to pod storage location:

```bash
cd /var/lib/kubelet/pods
```

List pods:

```bash
ls
```

### Output

```bash
16c6045b-e341-4d7e-b470-aa082b6e787f
3fc7aa3c-9ccc-4be1-87dd-814c411e0465
68b25574-50c5-4aa5-93a7-b495a7caa1a1
```

---

## Navigate to EmptyDir Volume

```bash
cd 68b25574-50c5-4aa5-93a7-b495a7caa1a1
cd volumes
cd kubernetes.io~empty-dir
cd mydata
```

List files:

```bash
ls
```

### Output

```bash
index.html
```

---

# Step 15: Verify Content on Worker Node

```bash
cat index.html
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 16: Edit Content Directly on Worker Node

```bash
vi index.html
```

Update content:

```text
this is my web page,
edited on worker node 2
```

Save and exit:

```bash
:wq
```

Verify:

```bash
cat index.html
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 17: Verify From Master Node

```bash
curl 10.42.2.104
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 18: Test Container Restart

Login to container:

```bash
kubectl exec -it nginx-pod -- bash
```

Kill PID 1:

```bash
kill 1
```

### Output

```bash
command terminated with exit code 137
```

---

Check pod status:

```bash
kubectl get po -o wide
```

### Output

```bash
NAME        READY   STATUS    RESTARTS
nginx-pod   1/1     Running   1
```

---

# Concept: Why Data Still Exists?

The container restarted, but:

```text
Pod = Same
Container = Recreated
emptyDir Volume = Same
```

Since the Pod was not deleted, Kubernetes kept the EmptyDir volume.

---

# What Happens If Pod Is Deleted?

Delete Pod:

```bash
kubectl delete po nginx-pod
```

### Output

```bash
pod "nginx-pod" deleted
```

Result:

```text
Pod removed
Container removed
emptyDir volume removed
Data lost
```

---

# Important EmptyDir Characteristics

| Feature                           | Description                       |
| --------------------------------- | --------------------------------- |
| Storage Location                  | Worker Node Filesystem            |
| Lifetime                          | Pod Lifetime                      |
| Shared Between Containers         | Yes                               |
| Persists Across Container Restart | Yes                               |
| Persists Across Pod Deletion      | No                                |
| Storage Type                      | Temporary                         |
| Use Case                          | Cache, Scratch Space, Shared Data |

---

# Key Commands Summary

```bash
kubectl apply -f emptydir-vol.yaml

kubectl get po

kubectl get po -o wide

kubectl exec -it nginx-pod -- bash

curl <pod-ip>

kubectl get po -o yaml

kubectl delete po nginx-pod

kill 1

cd /var/lib/kubelet/pods

cat index.html
```

---

# Learning Outcome

After completing this lab, you learned:

* What an EmptyDir volume is
* Where EmptyDir data is stored
* How to mount EmptyDir into a container
* How EmptyDir survives container restarts
* Why EmptyDir data is deleted when the Pod is deleted
* How Kubernetes stores volume data on worker nodes
* How to inspect EmptyDir volumes directly from the node filesystem

```Here is a clean GitHub-ready Markdown document for your **Kubernetes EmptyDir Volume Lab** based on your terminal session. Source log: 

# Kubernetes EmptyDir Volume Lab

## Objective

Learn how `emptyDir` volumes work in Kubernetes by:

* Creating a Pod with an EmptyDir volume
* Mounting the volume inside an NGINX container
* Creating web content inside the volume
* Accessing the content through NGINX
* Verifying data persistence across container restarts
* Accessing the volume data directly from the worker node

---

# Lab Architecture

```text
+-----------------------+
|      Kubernetes       |
+-----------------------+
           |
           v
+-----------------------+
|      nginx-pod        |
|-----------------------|
| nginx container       |
|                       |
| /usr/share/nginx/html |
|          |            |
|          v            |
|     emptyDir Volume   |
+-----------------------+
           |
           v
Worker Node Filesystem

/var/lib/kubelet/pods/<pod-uid>/volumes/
```

---

# Step 1: Verify Existing Resources

```bash
kubectl get all
```

### Output

```bash
NAME                       READY   STATUS
pod/nginx-pod              1/1     Running
pod/php-6d75964bd5-cshjp   1/1     Running
pod/php-6d75964bd5-kz76d   1/1     Running
pod/php-6d75964bd5-mtnwl   1/1     Running
pod/sql-pod                1/1     Running
```

---

# Step 2: Clean Existing Resources

## Delete Deployment

```bash
kubectl delete deployment.apps/php
```

### Output

```bash
deployment.apps "php" deleted
```

---

## Delete Services

```bash
kubectl delete svc nginx-service php-service
```

### Output

```bash
service "nginx-service" deleted
service "php-service" deleted
```

---

## Delete Standalone Pods

```bash
kubectl delete po nginx-pod sql-pod
```

### Output

```bash
pod "nginx-pod" deleted
pod "sql-pod" deleted
```

---

# Step 3: Create EmptyDir Pod Manifest

## emptydir-vol.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod

spec:
  containers:
  - name: nginx-container
    image: nginx:latest

    volumeMounts:
    - name: mydata
      mountPath: /usr/share/nginx/html

  volumes:
  - name: mydata
    emptyDir: {}
```

---

# Step 4: Create Pod

```bash
kubectl apply -f emptydir-vol.yaml
```

### Output

```bash
pod/nginx-pod created
```

---

# Step 5: Verify Pod Status

```bash
kubectl get po
```

### Output

```bash
NAME        READY   STATUS
nginx-pod   1/1     Running
```

---

# Step 6: Check Pod Location

```bash
kubectl get po -o wide
```

### Output

```bash
NAME        READY   STATUS    IP            NODE
nginx-pod   1/1     Running   10.42.2.104   k3s-worker2.sece.com
```

---

# Step 7: Login Into Container

```bash
kubectl exec -it nginx-pod -- bash
```

---

# Step 8: Move to NGINX Web Directory

```bash
cd /usr/share/nginx/html
```

---

# Step 9: Create Web Page

```bash
cat > index.html
```

Enter:

```text
this is my web page,
edited on worker node 2
```

Press:

```text
Ctrl + C
```

---

# Step 10: Verify Content

```bash
cat index.html
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 11: Test Using Pod IP

Get Pod IP:

```bash
kubectl get po -o wide
```

### Output

```bash
10.42.2.104
```

Access NGINX:

```bash
curl 10.42.2.104
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 12: Verify EmptyDir Volume Configuration

```bash
kubectl get po -o yaml
```

Relevant section:

```yaml
volumeMounts:
- mountPath: /usr/share/nginx/html
  name: mydata

volumes:
- emptyDir: {}
  name: mydata
```

---

# Step 13: Find Pod UID

```bash
kubectl get po -o yaml | grep uid
```

### Output

```bash
uid: 68b25574-50c5-4aa5-93a7-b495a7caa1a1
```

---

# Step 14: Verify Data on Worker Node

Login to worker node.

```bash
sudo -i
```

Move to pod storage location:

```bash
cd /var/lib/kubelet/pods
```

List pods:

```bash
ls
```

### Output

```bash
16c6045b-e341-4d7e-b470-aa082b6e787f
3fc7aa3c-9ccc-4be1-87dd-814c411e0465
68b25574-50c5-4aa5-93a7-b495a7caa1a1
```

---

## Navigate to EmptyDir Volume

```bash
cd 68b25574-50c5-4aa5-93a7-b495a7caa1a1
cd volumes
cd kubernetes.io~empty-dir
cd mydata
```

List files:

```bash
ls
```

### Output

```bash
index.html
```

---

# Step 15: Verify Content on Worker Node

```bash
cat index.html
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 16: Edit Content Directly on Worker Node

```bash
vi index.html
```

Update content:

```text
this is my web page,
edited on worker node 2
```

Save and exit:

```bash
:wq
```

Verify:

```bash
cat index.html
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 17: Verify From Master Node

```bash
curl 10.42.2.104
```

### Output

```text
this is my web page,
edited on worker node 2
```

---

# Step 18: Test Container Restart

Login to container:

```bash
kubectl exec -it nginx-pod -- bash
```

Kill PID 1:

```bash
kill 1
```

### Output

```bash
command terminated with exit code 137
```

---

Check pod status:

```bash
kubectl get po -o wide
```

### Output

```bash
NAME        READY   STATUS    RESTARTS
nginx-pod   1/1     Running   1
```

---

# Concept: Why Data Still Exists?

The container restarted, but:

```text
Pod = Same
Container = Recreated
emptyDir Volume = Same
```

Since the Pod was not deleted, Kubernetes kept the EmptyDir volume.

---

# What Happens If Pod Is Deleted?

Delete Pod:

```bash
kubectl delete po nginx-pod
```

### Output

```bash
pod "nginx-pod" deleted
```

Result:

```text
Pod removed
Container removed
emptyDir volume removed
Data lost
```

---

# Important EmptyDir Characteristics

| Feature                           | Description                       |
| --------------------------------- | --------------------------------- |
| Storage Location                  | Worker Node Filesystem            |
| Lifetime                          | Pod Lifetime                      |
| Shared Between Containers         | Yes                               |
| Persists Across Container Restart | Yes                               |
| Persists Across Pod Deletion      | No                                |
| Storage Type                      | Temporary                         |
| Use Case                          | Cache, Scratch Space, Shared Data |

---

# Key Commands Summary

```bash
kubectl apply -f emptydir-vol.yaml

kubectl get po

kubectl get po -o wide

kubectl exec -it nginx-pod -- bash

curl <pod-ip>

kubectl get po -o yaml

kubectl delete po nginx-pod

kill 1

cd /var/lib/kubelet/pods

cat index.html
```

---

# Learning Outcome

After completing this lab, you learned:

* What an EmptyDir volume is
* Where EmptyDir data is stored
* How to mount EmptyDir into a container
* How EmptyDir survives container restarts
* Why EmptyDir data is deleted when the Pod is deleted
* How Kubernetes stores volume data on worker nodes
* How to inspect EmptyDir volumes directly from the node filesystem
