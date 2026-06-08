# Kubernetes HostPath Volume & Metrics Server Lab

## Overview

This lab demonstrates:

* Creating and using a **HostPath Volume** in Kubernetes
* Verifying volume mounts inside a Pod
* Checking Linux system resources
* Using **Metrics Server**
* Monitoring Node and Pod resource usage with `kubectl top`

Source log: 

---

## Prerequisites

* K3s Cluster
* 1 Master Node
* 2 Worker Nodes
* kubectl configured
* Metrics Server installed

---

# 1. Verify Existing Pods

```bash
kubectl get po
```

Output:

```text
NAME             READY   STATUS    RESTARTS
nginx-emptydir   1/1     Running   1
nginx-hostpath   1/1     Running   1
```

---

# 2. Create HostPath Pod

Apply the HostPath Pod manifest:

```bash
kubectl apply -f hostpath-pod.yaml
```

Output:

```text
pod/hostpath-demo created
```

---

# 3. Check Pod Status

```bash
kubectl get pod
```

Initially:

```text
hostpath-demo    0/1     ErrImagePull
```

After image pull completes:

```bash
kubectl get pod hostpath-demo -o wide
```

Output:

```text
NAME            READY   STATUS    IP            NODE
hostpath-demo   1/1     Running   10.42.2.142  k3s-worker1.sece.com
```

---

# 4. Verify HostPath Mount

Access the pod:

```bash
kubectl exec -it hostpath-demo -- sh
```

Check mounted filesystem:

```bash
mount | grep mnt
```

Output:

```text
/dev/mapper/ubuntu--vg-ubuntu--lv on /mnt type ext4
```

Verify storage:

```bash
df -h
```

Output:

```text
Filesystem                Size   Used   Avail
overlay                  11.2G   7.6G   3.0G
/dev/mapper/ubuntu--vg-ubuntu--lv
                          11.2G   7.6G   3.0G
```

Exit:

```bash
exit
```

---

# 5. Write Data to HostPath Volume

Create a file inside the mounted volume:

```bash
kubectl exec hostpath-demo -- sh -c \
'echo "Kubernetes HostPath Lab" > /mnt/hello.txt'
```

Verify:

```bash
kubectl exec hostpath-demo -- cat /mnt/hello.txt
```

Output:

```text
Kubernetes HostPath Lab
```

---

# 6. Linux System Information

## CPU Information

```bash
lscpu
```

Key Information:

```text
Architecture : x86_64
CPU(s)       : 2
Model Name   : 12th Gen Intel(R) Core(TM) i5-12500H
Hypervisor   : VMware
```

---

## Memory Information

```bash
free -h
```

Output:

```text
Mem:   3.8Gi   1.3Gi   1.1Gi   1.6Gi cache
Swap:  2.2Gi   0B      2.2Gi
```

---

## Block Devices

```bash
lsblk
```

Output:

```text
NAME                      SIZE
sda                       25G
├─sda2                     2G
└─sda3                    23G
  └─ubuntu--vg-ubuntu--lv 11.5G
```

---

# 7. Metrics Server Verification

Check Node Metrics:

```bash
kubectl top node
```

Output:

```text
NAME                   CPU   CPU%   MEMORY   MEMORY%
k3s-master.sece.com    77m   3%     1656Mi   42%
k3s-worker1.sece.com   25m   1%     1039Mi   26%
k3s-worker2.sece.com   20m   1%      837Mi   21%
```

This confirms Metrics Server is working correctly.

---

# 8. View Pod Resource Usage

```bash
kubectl top po
```

Output:

```text
NAME             CPU   MEMORY
hostpath-demo    0m    0Mi
nginx-emptydir   0m    8Mi
nginx-hostpath   0m    9Mi
```

---

# 9. View Resource Usage Across All Namespaces

```bash
kubectl top po -A
```

Sample Output:

```text
NAMESPACE        NAME                  CPU   MEMORY
default          hostpath-demo         0m    0Mi
default          nginx-emptydir        0m    8Mi
default          nginx-hostpath        0m    9Mi
kube-system      coredns               2m    68Mi
kube-system      metrics-server        4m    75Mi
kube-system      traefik               1m   124Mi
metallb-system   controller            2m    52Mi
```

---

# 10. Verify Metrics Server Pod

```bash
kubectl get po -A | grep metrics-server
```

Output:

```text
kube-system   metrics-server-786d997795-mljbj   1/1 Running
```

---

# Key Commands Summary

```bash
# Create HostPath Pod
kubectl apply -f hostpath-pod.yaml

# Check Pods
kubectl get pod
kubectl get pod -o wide

# Access Pod
kubectl exec -it hostpath-demo -- sh

# Verify Mount
mount | grep mnt
df -h

# Create File
kubectl exec hostpath-demo -- sh -c \
'echo "Kubernetes HostPath Lab" > /mnt/hello.txt'

# Read File
kubectl exec hostpath-demo -- cat /mnt/hello.txt

# Linux Resource Commands
lscpu
free -h
lsblk

# Metrics Server
kubectl top node
kubectl top po
kubectl top po -A

# Check Metrics Server Pod
kubectl get po -A | grep metrics-server
```

---

## Conclusion

In this lab, a **HostPath Volume** was successfully mounted into a Kubernetes Pod, data persistence was verified by creating a file inside the mounted directory, Linux system resources were inspected using `lscpu`, `free`, and `lsblk`, and cluster resource consumption was monitored using the Kubernetes **Metrics Server** with `kubectl top` commands. 
