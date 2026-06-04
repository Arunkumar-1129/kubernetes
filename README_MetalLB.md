# MetalLB Installation and Verification on K3s Cluster

## Objective

Install MetalLB in a K3s cluster and verify that all MetalLB components are running successfully.

---

## Step 1: Switch to Root User

### Command

```bash
sudo -i
```

### Output

```bash
root@k3s-master:~#
```

---

## Step 2: Install MetalLB

### Command

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
```

### Output

```text
namespace/metallb-system unchanged
deployment.apps/controller configured
daemonset.apps/speaker configured
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration configured
```
(remaining CRD/resource outputs omitted for brevity)

---

## Step 3: Verify MetalLB Pods

### Command

```bash
kubectl get po -n metallb-system -o wide
```

### Output

```text
controller-595647bc76-c7flz              1/1 Running
controller-66bdd896c6-82xfx              0/1 ContainerCreating
frr-k8s-daemon-gd4jw                     0/5 Init:1/4
frr-k8s-daemon-gf9bw                     0/5 Init:1/4
frr-k8s-daemon-m5j6q                     0/5 Init:1/4
speaker-rsz9v                            1/1 Running
```

---

## Step 4: Verify All MetalLB Resources

### Incorrect Command

```bash
kubectl get all -n metallb -system
```

### Error

```text
lookup ystem: Try again
```

### Correct Command

```bash
kubectl get all -n metallb-system
```

---

## Step 5: Verify Existing Cluster Pods

### Command

```bash
kubectl get po
```

### Output

```text
nginx-daemonset-ffvld
nginx-daemonset-mtkcm
nginx-daemonset-s7qjj
nginx-deployment-55566ff79b-7ccnl
nginx-deployment-55566ff79b-gwdp2
nginx-deployment-55566ff79b-jdg89
nginx-deployment-55566ff79b-v2btq
nginx-deployment-55566ff79b-z6d9n
```

---

## Step 6: Troubleshoot MetalLB Pods

### Command

```bash
kubectl describe po -n metallb-system
```

### Observed Errors

```text
ErrImagePull
ImagePullBackOff
TLS handshake timeout
lookup quay.io: Try again
```

### Resolution

Images were eventually pulled successfully and all FRR containers reached the Running state.

---

## Result

- MetalLB installed successfully.
- Controller deployment running.
- FRR DaemonSet running across cluster nodes.
- Speaker pods deployed.
- Cluster ready for LoadBalancer services.
