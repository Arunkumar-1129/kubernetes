# Kubernetes Taints and Tolerations Lab

## Overview

This lab demonstrates how to use Kubernetes Taints and Tolerations to control Pod scheduling on Nodes.

### Concepts

* **Taint**: Applied to a Node to repel Pods.
* **Toleration**: Applied to a Pod to allow scheduling on a tainted Node.

---

## Add a NoSchedule Taint

```bash
kubectl taint nodes <node-name> key=value:NoSchedule
```

### Example

```bash
kubectl taint nodes k3s-worker2.sece.com role=database:NoSchedule
```

### Purpose

Prevents new Pods from being scheduled on the node unless they have a matching toleration.

---

## Add a PreferNoSchedule Taint

```bash
kubectl taint nodes <node-name> key=value:PreferNoSchedule
```

### Example

```bash
kubectl taint nodes k3s-worker2.sece.com role=database:PreferNoSchedule
```

### Purpose

A soft scheduling restriction. The scheduler attempts to avoid the node but may still place Pods there if necessary.

---

## Add a NoExecute Taint

```bash
kubectl taint nodes <node-name> key=value:NoExecute
```

### Example

```bash
kubectl taint nodes k3s-worker2.sece.com role=database:NoExecute
```

### Purpose

* Prevents new Pods from being scheduled.
* Evicts existing Pods that do not tolerate the taint.

---

## Remove a Taint

```bash
kubectl taint nodes <node-name> key=value:NoSchedule-
```

### Example

```bash
kubectl taint nodes k3s-worker2.sece.com role=database:NoSchedule-
```

### Purpose

Removes the specified taint from the node and restores normal scheduling behavior.

---

## View Node Taints

```bash
kubectl describe node <node-name>
```

### Example

```bash
kubectl describe node k3s-worker2.sece.com
```

### Purpose

Displays detailed information about the node, including:

* Taints
* Labels
* Capacity
* Allocatable resources
* Conditions

---

## Check Pod Placement

```bash
kubectl get pods -o wide
```

### Purpose

Displays the node on which each Pod is running.

### Example Output

```text
NAME      READY   STATUS    NODE
nginx     1/1     Running   k3s-worker1
mysql     1/1     Running   k3s-worker2
```

---

## View Pod Events

```bash
kubectl describe pod <pod-name>
```

### Example

```bash
kubectl describe pod nginx
```

### Purpose

Displays detailed Pod information including scheduling events and error messages.

Useful for troubleshooting Pods stuck in the `Pending` state.

Example:

```text
0/3 nodes are available:
1 node had untolerated taint
```

---

## Watch Pod Scheduling in Real Time

```bash
kubectl get pods -w
```

### Purpose

Continuously monitors Pod status changes.

### Example Output

```text
nginx   Pending
nginx   ContainerCreating
nginx   Running
```

Stop watching with:

```bash
Ctrl + C
```

---

## Delete a Pod

```bash
kubectl delete pod <pod-name>
```

### Example

```bash
kubectl delete pod nginx
```

### Purpose

Deletes the specified Pod.

If the Pod is managed by a Deployment or ReplicaSet, Kubernetes automatically creates a replacement Pod.

---

## Taint Effects Summary

| Effect           | New Pods          | Existing Pods  |
| ---------------- | ----------------- | -------------- |
| NoSchedule       | Blocked           | Remain Running |
| PreferNoSchedule | Avoid if Possible | Remain Running |
| NoExecute        | Blocked           | Evicted        |

---

## Common Verification Commands

```bash
kubectl get nodes
kubectl get pods
kubectl get pods -o wide
kubectl describe node <node-name>
kubectl describe pod <pod-name>
```

---

## Typical Lab Workflow

```bash
# View nodes
kubectl get nodes

# Add taint
kubectl taint nodes <node-name> role=database:NoSchedule

# Verify taint
kubectl describe node <node-name>

# Create Pod
kubectl apply -f pod.yaml

# Watch scheduling
kubectl get pods -w

# Check node placement
kubectl get pods -o wide

# Troubleshoot if needed
kubectl describe pod <pod-name>

# Remove taint
kubectl taint nodes <node-name> role=database:NoSchedule-

# Delete Pod
kubectl delete pod <pod-name>
```

---

## Learning Outcome

After completing this lab, you will understand:

* Node taints
* Pod tolerations
* Scheduling restrictions
* Pod placement verification
* Troubleshooting scheduling issues
* The differences between NoSchedule, PreferNoSchedule, and NoExecute
