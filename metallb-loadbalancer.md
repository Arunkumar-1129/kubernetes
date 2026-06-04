# K3s Cluster - MetalLB & Deployment Lab Session
**Date:** Thu Jun 4 2026 | **Host:** k3s-master (Ubuntu 24.04.4 LTS) | **User:** root

---

## System Information

```
System load:  0.31               Processes:              276
Usage of /:   71.2% of 11.21GB   Users logged in:        0
Memory usage: 25%                IPv4 address for ens33: 192.168.142.11
Swap usage:   0%
```

---

## 1. Switch to Root

```bash
arun@k3s-master:~$ sudo -i
root@k3s-master:~#
```

---

## 2. Install MetalLB v0.15.3

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
```

**Output:**
```
namespace/metallb-system unchanged
customresourcedefinition.apiextensions.k8s.io/bfdprofiles.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/bgpadvertisements.metallb.io configured
customresourcedefinition.apiextensions.k8s.io/bgppeers.metallb.io configured
customresourcedefinition.apiextensions.k8s.io/communities.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/configurationstates.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/ipaddresspools.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/l2advertisements.metallb.io configured
customresourcedefinition.apiextensions.k8s.io/servicebgpstatuses.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/servicel2statuses.metallb.io unchanged
serviceaccount/controller unchanged
serviceaccount/speaker unchanged
role.rbac.authorization.k8s.io/controller unchanged
role.rbac.authorization.k8s.io/pod-lister unchanged
clusterrole.rbac.authorization.k8s.io/metallb-system:controller unchanged
clusterrole.rbac.authorization.k8s.io/metallb-system:speaker configured
rolebinding.rbac.authorization.k8s.io/controller unchanged
rolebinding.rbac.authorization.k8s.io/pod-lister configured
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:controller unchanged
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:speaker unchanged
configmap/metallb-excludel2 unchanged
secret/metallb-webhook-cert unchanged
service/metallb-webhook-service unchanged
deployment.apps/controller configured
daemonset.apps/speaker configured
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration configured
```

---

## 3. Check MetalLB Pods (Initial - Some Still Creating)

```bash
kubectl get po -n metallb-system -o wide
```

**Output:**
```
NAME                                     READY   STATUS              RESTARTS   AGE   IP               NODE                   NOMINATED NODE   READINESS GATES
controller-595647bc76-c7flz              1/1     Running             0          17m   10.42.2.95       k3s-worker1.sece.com   <none>           <none>
controller-66bdd896c6-82xfx              0/1     ContainerCreating   0          11s   <none>           k3s-worker1.sece.com   <none>           <none>
frr-k8s-daemon-gd4jw                     0/5     Init:1/4            0          17m   192.168.142.13   k3s-worker2.sece.com   <none>           <none>
frr-k8s-daemon-gf9bw                     0/5     Init:1/4            0          17m   192.168.142.12   k3s-worker1.sece.com   <none>           <none>
frr-k8s-daemon-m5j6q                     0/5     Init:1/4            0          17m   192.168.142.11   k3s-master.sece.com    <none>           <none>
frr-k8s-statuscleaner-58d8956cbd-krxbl   0/1     ContainerCreating   0          17m   192.168.142.12   k3s-worker1.sece.com   <none>           <none>
speaker-n64fl                            0/1     Terminating         0          17m   192.168.142.12   k3s-worker1.sece.com   <none>           <none>
speaker-nptbh                            0/1     Terminating         0          17m   192.168.142.11   k3s-master.sece.com    <none>           <none>
speaker-rsz9v                            1/1     Running             0          17m   192.168.142.13   k3s-worker2.sece.com   <none>           <none>
```

---

## 4. Incorrect Namespace Command (Typo Error)

```bash
kubectl get all -n metallb -system
```

**Error:**
```
E0604 04:30:09.661448    8899 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list:
Get \"http://ystem/api?timeout=32s\": dial tcp: lookup ystem: Try again"
```
> **Note:** Typo — `-system` was split from `metallb`. Correct command is `kubectl get all -n metallb-system`.

---

## 5. Get All Resources in metallb-system Namespace

```bash
kubectl get all -n metallb-system
```

**Output:**
```
NAME                                         READY   STATUS              RESTARTS   AGE
pod/controller-595647bc76-c7flz              1/1     Running             0          18m
pod/controller-66bdd896c6-82xfx              0/1     Running             0          104s
pod/frr-k8s-daemon-gd4jw                     5/5     Running             0          18m
pod/frr-k8s-daemon-gf9bw                     5/5     Running             0          18m
pod/frr-k8s-daemon-m5j6q                     5/5     Running             0          18m
pod/frr-k8s-statuscleaner-58d8956cbd-krxbl   1/1     Running             0          18m
pod/speaker-94tqc                            0/1     Running             0          67s
pod/speaker-dv8x5                            0/1     ContainerCreating   0          24s
pod/speaker-rsz9v                            1/1     Running             0          18m

NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/frr-k8s-metrics-service   ClusterIP   10.43.238.144   <none>        9140/TCP,9141/TCP   18m
service/frr-k8s-webhook-service   ClusterIP   10.43.83.185    <none>        443/TCP             18m
service/metallb-webhook-service   ClusterIP   10.43.216.6     <none>        443/TCP             18m

NAME                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/frr-k8s-daemon   3         3         3       3            3           <none>                   18m
daemonset.apps/speaker          3         3         1       2            1           kubernetes.io/os=linux   18m

NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller              1/1     1            1           18m
deployment.apps/frr-k8s-statuscleaner   1/1     1            1           18m

NAME                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-595647bc76              1         1         1       18m
replicaset.apps/controller-66bdd896c6              1         1         0       104s
replicaset.apps/frr-k8s-statuscleaner-58d8956cbd   1         1         1       18m
```

---

## 6. Get Pods in Default Namespace

```bash
kubectl get po
```

**Output:**
```
NAME                                READY   STATUS    RESTARTS        AGE
nginx-daemonset-ffvld               1/1     Running   4 (8m17s ago)   46h
nginx-daemonset-mtkcm               1/1     Running   4 (8m14s ago)   46h
nginx-daemonset-s7qjj               1/1     Running   4 (8m30s ago)   46h
nginx-deployment-55566ff79b-7ccnl   1/1     Running   3 (8m14s ago)   167m
nginx-deployment-55566ff79b-gwdp2   1/1     Running   3 (8m14s ago)   167m
nginx-deployment-55566ff79b-jdg89   1/1     Running   3 (8m14s ago)   167m
nginx-deployment-55566ff79b-v2btq   1/1     Running   3 (8m14s ago)   167m
nginx-deployment-55566ff79b-z6d9n   1/1     Running   3 (8m14s ago)   167m
```

---

## 7. Describe All Pods in metallb-system

```bash
kubectl describe po -n metallb-system
```

### Pod: controller-66bdd896c6-82xfx

```
Name:             controller-66bdd896c6-82xfx
Namespace:        metallb-system
Node:             k3s-worker1.sece.com/192.168.142.12
Start Time:       Thu, 04 Jun 2026 04:28:41 +0000
Status:           Running
IP:               10.42.2.98
Controlled By:    ReplicaSet/controller-66bdd896c6
Image:            quay.io/metallb/controller:v0.15.3
Ports:            7472/TCP (monitoring), 9443/TCP (webhook-server)
State:            Running (Started: Thu, 04 Jun 2026 04:30:16 +0000)
Ready:            True
Restart Count:    0
```

**Events:**
```
Normal  Scheduled  5m24s  default-scheduler  Successfully assigned metallb-system/controller-66bdd896c6-82xfx to k3s-worker1.sece.com
Normal  Pulling    5m24s  kubelet            Pulling image "quay.io/metallb/controller:v0.15.3"
Normal  Pulled     3m49s  kubelet            Successfully pulled image "quay.io/metallb/controller:v0.15.3" in 1m35.027s. Image size: 23320938 bytes.
Normal  Created    3m49s  kubelet            Container created
Normal  Started    3m49s  kubelet            Container started
```

---

### Pod: frr-k8s-daemon-gd4jw (on k3s-worker2)

```
Name:       frr-k8s-daemon-gd4jw
Node:       k3s-worker2.sece.com/192.168.142.13
Status:     Running
IP:         192.168.142.13
Controlled By: DaemonSet/frr-k8s-daemon
```

**Init Containers:** cp-frr-files, cp-reloader, cp-metrics, cp-frr-status (all Completed)

**Running Containers:** controller, frr, frr-metrics, frr-status, reloader (all Ready)

**Key Events (image pull failures then success):**
```
Warning  Failed   21m  kubelet  Failed to pull image "quay.io/frrouting/frr:10.4.3": dial tcp: lookup cdn01.quay.io: Try again
Warning  Failed   21m  kubelet  Error: ErrImagePull
Normal   BackOff  21m  kubelet  Back-off pulling image "quay.io/frrouting/frr:10.4.3"
...
Normal   Pulled   6m45s  kubelet  Successfully pulled image "quay.io/frrouting/frr:10.4.3" in 2m25.01s. Image size: 90663535 bytes.
Normal   Pulled   4m36s  kubelet  Successfully pulled image "quay.io/metallb/frr-k8s:v0.0.25" in 2m8.106s. Image size: 119558058 bytes.
```

---

### Pod: frr-k8s-daemon-gf9bw (on k3s-worker1)

```
Name:       frr-k8s-daemon-gf9bw
Node:       k3s-worker1.sece.com/192.168.142.12
Status:     Running
IP:         192.168.142.12
Controlled By: DaemonSet/frr-k8s-daemon
```

**Init Containers:** cp-frr-files, cp-reloader, cp-metrics, cp-frr-status (all Completed)

**Running Containers:** controller, frr, frr-metrics, frr-status, reloader (all Ready)

**Key Events:**
```
Warning  Failed   12m  kubelet  Failed to pull image "quay.io/frrouting/frr:10.4.3": dial tcp: lookup quay.io: Try again
...
Normal   Pulled   6m36s  kubelet  Successfully pulled image "quay.io/frrouting/frr:10.4.3" in 2m37.006s. Image size: 90663535 bytes.
Normal   Pulled   5m13s  kubelet  Successfully pulled image "quay.io/metallb/frr-k8s:v0.0.25" in 1m21.911s. Image size: 119558058 bytes.
```

---

### Pod: frr-k8s-daemon-m5j6q (on k3s-master)

```
Name:       frr-k8s-daemon-m5j6q
Node:       k3s-master.sece.com/192.168.142.11
Status:     Running
IP:         192.168.142.11
Controlled By: DaemonSet/frr-k8s-daemon
```

**Init Containers:** cp-frr-files, cp-reloader, cp-metrics, cp-frr-status (all Completed)

**Running Containers:** controller, frr, frr-metrics, frr-status, reloader (all Ready)

**Key Events:**
```
Warning  Failed  22m  kubelet  Failed to pull image "quay.io/frrouting/frr:10.4.3": dial tcp: lookup quay.io: Try again
...
Normal   Pulled  5m26s  kubelet  Successfully pulled image "quay.io/frrouting/frr:10.4.3" in 3m54.658s. Image size: 90663535 bytes.
Normal   Pulled  4m4s   kubelet  Successfully pulled image "quay.io/metallb/frr-k8s:v0.0.25" in 1m20.321s. Image size: 119558058 bytes.
```

---

### Pod: frr-k8s-statuscleaner-58d8956cbd-krxbl

```
Name:       frr-k8s-statuscleaner-58d8956cbd-krxbl
Node:       k3s-worker1.sece.com/192.168.142.12
Status:     Running
IP:         192.168.142.12
Image:      quay.io/metallb/frr-k8s:v0.0.25
Port:       19443/TCP (webhook)
Ready:      True
```

**Key Events:**
```
Warning  Failed  22m  kubelet  Failed to pull image "quay.io/metallb/frr-k8s:v0.0.25": net/http: TLS handshake timeout
...
Normal   Pulled  5m13s  kubelet  Successfully pulled image "quay.io/metallb/frr-k8s:v0.0.25" in 3m59.304s. Image size: 119558058 bytes.
Normal   Started 5m13s  kubelet  Container started
```

---

### Pod: speaker-7rd2c (on k3s-worker2)

```
Name:       speaker-7rd2c
Node:       k3s-worker2.sece.com/192.168.142.13
Status:     Running
IP:         192.168.142.13
Image:      quay.io/metallb/speaker:v0.15.3
Ports:      7472/TCP (monitoring), 7946/TCP (memberlist-tcp), 7946/UDP (memberlist-udp)
Ready:      True
```

**Events:**
```
Normal  Scheduled  3m16s  default-scheduler  Successfully assigned metallb-system/speaker-7rd2c to k3s-worker2.sece.com
Normal  Pulling    3m16s  kubelet            Pulling image "quay.io/metallb/speaker:v0.15.3"
Normal  Pulled     2m46s  kubelet            Successfully pulled image in 29.977s. Image size: 51445238 bytes.
Normal  Started    2m46s  kubelet            Container started
```

---

### Pod: speaker-94tqc (on k3s-master)

```
Name:       speaker-94tqc
Node:       k3s-master.sece.com/192.168.142.11
Status:     Running
IP:         192.168.142.11
Image:      quay.io/metallb/speaker:v0.15.3
Ready:      True
```

**Events:**
```
Normal  Pulled   3m50s  kubelet  Successfully pulled image "quay.io/metallb/speaker:v0.15.3" in 57.492s. Image size: 51445238 bytes.
Normal  Started  3m50s  kubelet  Container started
```

---

### Pod: speaker-dv8x5 (on k3s-worker1)

```
Name:       speaker-dv8x5
Node:       k3s-worker1.sece.com/192.168.142.12
Status:     Running
IP:         192.168.142.12
Image:      quay.io/metallb/speaker:v0.15.3
Ready:      True
```

**Events:**
```
Normal  Pulled   3m29s  kubelet  Successfully pulled image "quay.io/metallb/speaker:v0.15.3" in 35.226s. Image size: 51445238 bytes.
Normal  Started  3m29s  kubelet  Container started
```

---

## 8. Verify All MetalLB Pods Running

```bash
kubectl get po -n metallb-system
```

**Output:**
```
NAME                                     READY   STATUS    RESTARTS   AGE
controller-66bdd896c6-82xfx              1/1     Running   0          6m
frr-k8s-daemon-gd4jw                     5/5     Running   0          22m
frr-k8s-daemon-gf9bw                     5/5     Running   0          22m
frr-k8s-daemon-m5j6q                     5/5     Running   0          22m
frr-k8s-statuscleaner-58d8956cbd-krxbl   1/1     Running   0          22m
speaker-7rd2c                            1/1     Running   0          3m51s
speaker-94tqc                            1/1     Running   0          5m23s
speaker-dv8x5                            1/1     Running   0          4m40s
```

---

## 9. Verify MetalLB Pods with Node Info

```bash
kubectl get po -n metallb-system -o wide
```

**Output:**
```
NAME                                     READY   STATUS    RESTARTS   AGE     IP               NODE
controller-66bdd896c6-82xfx              1/1     Running   0          7m33s   10.42.2.98       k3s-worker1.sece.com
frr-k8s-daemon-gd4jw                     5/5     Running   0          24m     192.168.142.13   k3s-worker2.sece.com
frr-k8s-daemon-gf9bw                     5/5     Running   0          24m     192.168.142.12   k3s-worker1.sece.com
frr-k8s-daemon-m5j6q                     5/5     Running   0          24m     192.168.142.11   k3s-master.sece.com
frr-k8s-statuscleaner-58d8956cbd-krxbl   1/1     Running   0          24m     192.168.142.12   k3s-worker1.sece.com
speaker-7rd2c                            1/1     Running   0          5m24s   192.168.142.13   k3s-worker2.sece.com
speaker-94tqc                            1/1     Running   0          6m56s   192.168.142.11   k3s-master.sece.com
speaker-dv8x5                            1/1     Running   0          6m13s   192.168.142.12   k3s-worker1.sece.com
```

---

## 10. Create IP Address Pool

```bash
vi ippool.yaml
kubectl apply -f ippool.yaml
```

**Output:**
```
ipaddresspool.metallb.io/first-pool created
```

---

## 11. Create L2 Advertisement

```bash
vi l2ad.yaml
kubectl create -f l2ad.yaml
```

**Output:**
```
l2advertisement.metallb.io/example created
```

---

## 12. Verify L2 Advertisement and IP Pool

```bash
# Typo - wrong command name
ubectl get l2advertisement -n metallb-system
# Error: Command 'ubectl' not found

kubectl get l2advertisement -n metallb-system
```

**Output:**
```
NAME      IPADDRESSPOOLS   IPADDRESSPOOL SELECTORS   INTERFACES
example
```

```bash
kubectl get ipaddresspool -n metallb-system
```

**Output:**
```
NAME         AUTO ASSIGN   AVOID BUGGY IPS   ADDRESSES
first-pool   true          false             ["192.168.142.240-192.168.142.250"]
```

---

## 13. View nginx-deployment.yaml

```bash
cat nginx-deployment.yaml
```

**Output:**
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
      app: arun
  template:
    metadata:
      labels:
        app: arun
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
```

---

## 14. Create httpd Deployment (with Fixes)

```bash
vi nginx-deployment.yaml

# Attempt 1 - selector mismatch error
kubectl create -f nginx-deployment.yaml
```
**Error:**
```
The Deployment "httpd-deployment" is invalid: spec.template.metadata.labels: Invalid value: {"app":"httpd"}:
`selector` does not match template `labels`
```

```bash
# After fixing the YAML (edited twice more)
vi nginx-deployment.yaml
kubectl create -f nginx-deployment.yaml
```

**Output:**
```
deployment.apps/httpd-deployment created
```

---

## 15. Watch httpd Deployment Pods

```bash
kubectl get po
```

**Output (initial):**
```
NAME                                READY   STATUS              RESTARTS      AGE
httpd-deployment-666fd568bb-5r5nf   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-cl9cp   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-hspz8   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-jkp5b   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-kzdpj   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-qz94n   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-r5h9c   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-vhlgz   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-vsfwb   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-xngqn   0/1     ContainerCreating   0             8s
nginx-daemonset-ffvld               1/1     Running             4 (25m ago)   46h
nginx-daemonset-mtkcm               1/1     Running             4 (25m ago)   46h
nginx-daemonset-s7qjj               1/1     Running             4 (25m ago)   46h
nginx-deployment-55566ff79b-7ccnl   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-gwdp2   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-jdg89   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-v2btq   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-z6d9n   1/1     Running             3 (25m ago)   3h4m
```

```bash
kubectl get po -w
```

**Output (watch — pods becoming Running):**
```
httpd-deployment-666fd568bb-qz94n   1/1     Running   0   29s
httpd-deployment-666fd568bb-vhlgz   1/1     Running   0   29s
httpd-deployment-666fd568bb-xngqn   1/1     Running   0   29s
httpd-deployment-666fd568bb-vsfwb   1/1     Running   0   31s
httpd-deployment-666fd568bb-jkp5b   1/1     Running   0   31s
httpd-deployment-666fd568bb-r5h9c   1/1     Running   0   31s
httpd-deployment-666fd568bb-5r5nf   1/1     Running   0   34s
httpd-deployment-666fd568bb-hspz8   1/1     Running   0   34s
httpd-deployment-666fd568bb-cl9cp   1/1     Running   0   34s
httpd-deployment-666fd568bb-kzdpj   1/1     Running   0   34s
```

---

## 16. Show Pod Labels

```bash
# Wrong flag attempts
kubectl get po --show -label   # Error: unknown flag: --show
kubectl get po --show -labels  # Error: unknown flag: --show

kubectl get po --show-labels
```

**Output:**
```
NAME                                READY   STATUS    RESTARTS      AGE     LABELS
httpd-deployment-666fd568bb-5r5nf   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-cl9cp   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-hspz8   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-jkp5b   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-kzdpj   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-qz94n   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-r5h9c   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-vhlgz   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-vsfwb   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-xngqn   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
nginx-daemonset-ffvld               1/1     Running   4 (27m ago)   46h     app=nginx-app,controller-revision-hash=74b7cd9f45,pod-template-generation=2
nginx-daemonset-mtkcm               1/1     Running   4 (27m ago)   46h     app=nginx-app,controller-revision-hash=74b7cd9f45,pod-template-generation=2
nginx-daemonset-s7qjj               1/1     Running   4 (28m ago)   46h     app=nginx-app,controller-revision-hash=74b7cd9f45,pod-template-generation=2
nginx-deployment-55566ff79b-7ccnl   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
nginx-deployment-55566ff79b-gwdp2   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
nginx-deployment-55566ff79b-jdg89   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
nginx-deployment-55566ff79b-v2btq   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
nginx-deployment-55566ff79b-z6d9n   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
```

---

## 17. Create httpd LoadBalancer Service

```bash
vi httpd-svc.yaml
kubectl apply -f httpd-svc.yaml
```

**Output:**
```
service/httpd-service created
```

```bash
# Wrong resource name attempts
kubectl get svc httpd-svc.yaml   # Error: services "httpd-svc.yaml" not found
kubectl get svc httpd-svc        # Error: services "httpd-svc" not found

kubectl get svc
```

**Output:**
```
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
httpd-service               LoadBalancer   10.43.153.1     192.168.142.241   80:30149/TCP   25s
kubernetes                  ClusterIP      10.43.0.1       <none>            443/TCP        4d19h
nginx-nodeport-custom-svc   NodePort       10.43.149.14    <none>            80:31010/TCP   11h
nginx-nodeport-svc          NodePort       10.43.218.6     <none>            80:31927/TCP   11h
nginx-svc                   ClusterIP      10.43.241.254   <none>            80/TCP         11h
```

> **Note:** MetalLB assigned External IP `192.168.142.241` to `httpd-service` from the pool `192.168.142.240-192.168.142.250`.

---

## 18. Check Endpoints (Typo Then Correct)

```bash
kubectl get enfpoints   # Error: server doesn't have a resource type "enfpoints"

kubectl get endpoints
```

**Output:**
```
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                        ENDPOINTS                                                  AGE
httpd-service               10.42.0.102:80,10.42.0.103:80,10.42.0.104:80 + 7 more...   44s
kubernetes                  192.168.142.11:6443                                        4d19h
nginx-nodeport-custom-svc   10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-nodeport-svc          10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-svc                   <none>                                                     11h
php-service                                                                            3m41s
```

---

## 19. Create phpMyAdmin Service (Multiple Attempts with Fixes)

### phpmy-svc.yaml — Errors Encountered

```bash
vi phpmy-svc.yaml
kubectl apply -f phpmy-svc.yaml
# Error: apiVersion not set  (typo: apiVerison instead of apiVersion)

# After several vi edits...
kubectl apply -f phpmy-svc.yaml
# Error: service in version "v1" cannot be handled as a Service: no kind "service" is registered
# (kind was lowercase "service" instead of "Service")

# After final fix:
kubectl apply -f phpmy-svc.yaml
```

**Output:**
```
service/php-service created
```

### Final phpmy-svc.yaml content:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: php-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
  selector:
    app: phpmyadmin
```

---

## 20. View php-deployment.yaml

```bash
cat php-deployment.yaml
```

**Output:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpmyadmin-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: phpmyadmin
  template:
    metadata:
      labels:
        app: phpmyadmin
    spec:
      containers:
      - name: phpmyadmin
        image: phpmyadmin/phpmyadmin
        ports:
        - containerPort: 80
```

---

## 21. Apply phpMyAdmin Deployment

```bash
kubectl apply -f php-deployment.yaml
```

**Output:**
```
deployment.apps/phpmyadmin-deployment configured
```

---

## 22. Apply Updated php-deploy.yaml and php-svc1.yaml

```bash
kubectl apply -f php-svc1.yaml
```
```
service/php-service unchanged
```

```bash
kubectl apply -f php-deploy.yaml
```
```
deployment.apps/phpmyadmin-deployment configured
```

---

## 23. Get All Services (Final State)

```bash
kubectl get svc
```

**Output:**
```
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
httpd-service               LoadBalancer   10.43.153.1     192.168.142.241   80:30149/TCP   23m
kubernetes                  ClusterIP      10.43.0.1       <none>            443/TCP        4d19h
nginx-nodeport-custom-svc   NodePort       10.43.149.14    <none>            80:31010/TCP   11h
nginx-nodeport-svc          NodePort       10.43.218.6     <none>            80:31927/TCP   11h
nginx-svc                   ClusterIP      10.43.241.254   <none>            80/TCP         12h
php-service                 LoadBalancer   10.43.119.79    192.168.142.242   80:30094/TCP   3m26s
```

> **Note:** MetalLB assigned External IP `192.168.142.242` to `php-service`.

---

## 24. Final Pod List with Node Distribution (-o wide)

```bash
kubectl get po -o wide
```

**Output:**
```
NAME                                     READY   STATUS    RESTARTS      AGE     IP            NODE
httpd-deployment-666fd568bb-5r5nf        1/1     Running   0             48m     10.42.2.99    k3s-worker1.sece.com
httpd-deployment-666fd568bb-cl9cp        1/1     Running   0             48m     10.42.2.102   k3s-worker1.sece.com
httpd-deployment-666fd568bb-hspz8        1/1     Running   0             48m     10.42.2.101   k3s-worker1.sece.com
httpd-deployment-666fd568bb-jkp5b        1/1     Running   0             48m     10.42.0.102   k3s-master.sece.com
httpd-deployment-666fd568bb-kzdpj        1/1     Running   0             48m     10.42.2.100   k3s-worker1.sece.com
httpd-deployment-666fd568bb-qz94n        1/1     Running   0             48m     10.42.1.128   k3s-worker2.sece.com
httpd-deployment-666fd568bb-r5h9c        1/1     Running   0             48m     10.42.0.104   k3s-master.sece.com
httpd-deployment-666fd568bb-vhlgz        1/1     Running   0             48m     10.42.1.130   k3s-worker2.sece.com
httpd-deployment-666fd568bb-vsfwb        1/1     Running   0             48m     10.42.0.103   k3s-master.sece.com
httpd-deployment-666fd568bb-xngqn        1/1     Running   0             48m     10.42.1.129   k3s-worker2.sece.com
nginx-daemonset-ffvld                    1/1     Running   4 (74m ago)   47h     10.42.2.97    k3s-worker1.sece.com
nginx-daemonset-mtkcm                    1/1     Running   4 (74m ago)   47h     10.42.1.123   k3s-worker2.sece.com
nginx-daemonset-s7qjj                    1/1     Running   4 (74m ago)   47h     10.42.0.99    k3s-master.sece.com
nginx-deployment-55566ff79b-7ccnl        1/1     Running   3 (74m ago)   3h53m   10.42.1.124   k3s-worker2.sece.com
nginx-deployment-55566ff79b-gwdp2        1/1     Running   3 (74m ago)   3h53m   10.42.1.125   k3s-worker2.sece.com
nginx-deployment-55566ff79b-jdg89        1/1     Running   3 (74m ago)   3h53m   10.42.1.121   k3s-worker2.sece.com
nginx-deployment-55566ff79b-v2btq        1/1     Running   3 (74m ago)   3h53m   10.42.1.122   k3s-worker2.sece.com
nginx-deployment-55566ff79b-z6d9n        1/1     Running   3 (74m ago)   3h53m   10.42.1.127   k3s-worker2.sece.com
phpmyadmin-deployment-6bfdf8478f-69gmj   1/1     Running   0             28m     10.42.2.104   k3s-worker1.sece.com
phpmyadmin-deployment-6bfdf8478f-78bxs   1/1     Running   0             28m     10.42.1.133   k3s-worker2.sece.com
phpmyadmin-deployment-6bfdf8478f-847f9   1/1     Running   0             28m     10.42.2.106   k3s-worker1.sece.com
phpmyadmin-deployment-6bfdf8478f-88cc6   1/1     Running   0             28m     10.42.1.131   k3s-worker2.sece.com
phpmyadmin-deployment-6bfdf8478f-jh2lj   1/1     Running   0             28m     10.42.2.103   k3s-worker1.sece.com
phpmyadmin-deployment-6bfdf8478f-l2j59   1/1     Running   0             28m     10.42.0.106   k3s-master.sece.com
phpmyadmin-deployment-6bfdf8478f-pqgrv   1/1     Running   0             28m     10.42.0.107   k3s-master.sece.com
phpmyadmin-deployment-6bfdf8478f-qcfm7   1/1     Running   0             28m     10.42.2.105   k3s-worker1.sece.com
phpmyadmin-deployment-6bfdf8478f-xf8cw   1/1     Running   0             28m     10.42.0.105   k3s-master.sece.com
phpmyadmin-deployment-6bfdf8478f-zg982   1/1     Running   0             28m     10.42.1.132   k3s-worker2.sece.com
```

---

## 25. Final Endpoints Verification

```bash
kubectl get endpoints
```

**Output:**
```
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                        ENDPOINTS                                                  AGE
httpd-service               10.42.0.102:80,10.42.0.103:80,10.42.0.104:80 + 7 more...   43m
kubernetes                  192.168.142.11:6443                                        4d20h
nginx-nodeport-custom-svc   10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-nodeport-svc          10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   12h
nginx-svc                   <none>                                                     12h
php-service                 10.42.0.105:80,10.42.0.106:80,10.42.0.107:80 + 7 more...   24m
```

---

## Summary

| Resource | Details |
|---|---|
| Cluster | k3s-master + k3s-worker1 + k3s-worker2 |
| MetalLB Version | v0.15.3 (FRR mode) |
| IP Pool | `192.168.142.240 – 192.168.142.250` |
| httpd-service (LoadBalancer) | External IP: `192.168.142.241` |
| php-service (LoadBalancer) | External IP: `192.168.142.242` |
| httpd-deployment replicas | 10 pods (label: `app=httpd`) |
| phpmyadmin-deployment replicas | 10 pods (label: `app=phpmyadmin`) |
| nginx-deployment replicas | 5 pods (label: `app=arun`) |
| nginx-daemonset | 3 pods — 1 per node (label: `app=nginx-app`) |


```

Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-117-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Jun  4 04:26:06 AM UTC 2026

  System load:  0.31               Processes:              276
  Usage of /:   71.2% of 11.21GB   Users logged in:        0
  Memory usage: 25%                IPv4 address for ens33: 192.168.142.11
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings


Last login: Thu Jun  4 04:19:09 2026 from 192.168.142.1
arun@k3s-master:~$ sudo -i
[sudo] password for arun:
root@k3s-master:~# root
Command 'root' not found, but can be installed with:
snap install root-framework
root@k3s-master:~# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
namespace/metallb-system unchanged
customresourcedefinition.apiextensions.k8s.io/bfdprofiles.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/bgpadvertisements.metallb.io configured
customresourcedefinition.apiextensions.k8s.io/bgppeers.metallb.io configured
customresourcedefinition.apiextensions.k8s.io/communities.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/configurationstates.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/ipaddresspools.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/l2advertisements.metallb.io configured
customresourcedefinition.apiextensions.k8s.io/servicebgpstatuses.metallb.io unchanged
customresourcedefinition.apiextensions.k8s.io/servicel2statuses.metallb.io unchanged
serviceaccount/controller unchanged
serviceaccount/speaker unchanged
role.rbac.authorization.k8s.io/controller unchanged
role.rbac.authorization.k8s.io/pod-lister unchanged
clusterrole.rbac.authorization.k8s.io/metallb-system:controller unchanged
clusterrole.rbac.authorization.k8s.io/metallb-system:speaker configured
rolebinding.rbac.authorization.k8s.io/controller unchanged
rolebinding.rbac.authorization.k8s.io/pod-lister configured
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:controller unchanged
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:speaker unchanged
configmap/metallb-excludel2 unchanged
secret/metallb-webhook-cert unchanged
service/metallb-webhook-service unchanged
deployment.apps/controller configured
daemonset.apps/speaker configured
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration configured
root@k3s-master:~# kubectl get po -n metallb-system -o wide
NAME                                     READY   STATUS              RESTARTS   AGE   IP               NODE                   NOMINATED NODE   READINESS GATES
controller-595647bc76-c7flz              1/1     Running             0          17m   10.42.2.95       k3s-worker1.sece.com   <none>           <none>
controller-66bdd896c6-82xfx              0/1     ContainerCreating   0          11s   <none>           k3s-worker1.sece.com   <none>           <none>
frr-k8s-daemon-gd4jw                     0/5     Init:1/4            0          17m   192.168.142.13   k3s-worker2.sece.com   <none>           <none>
frr-k8s-daemon-gf9bw                     0/5     Init:1/4            0          17m   192.168.142.12   k3s-worker1.sece.com   <none>           <none>
frr-k8s-daemon-m5j6q                     0/5     Init:1/4            0          17m   192.168.142.11   k3s-master.sece.com    <none>           <none>
frr-k8s-statuscleaner-58d8956cbd-krxbl   0/1     ContainerCreating   0          17m   192.168.142.12   k3s-worker1.sece.com   <none>           <none>
speaker-n64fl                            0/1     Terminating         0          17m   192.168.142.12   k3s-worker1.sece.com   <none>           <none>
speaker-nptbh                            0/1     Terminating         0          17m   192.168.142.11   k3s-master.sece.com    <none>           <none>
speaker-rsz9v                            1/1     Running             0          17m   192.168.142.13   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~# kubectl get all -n metallb -system
E0604 04:30:09.661448    8899 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://ystem/api?timeout=32s\": dial tcp: lookup ystem: Try again"
^[[AE0604 04:30:14.666144    8899 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://ystem/api?timeout=32s\": dial tcp: lookup ystem: Try again"
^[[D^[[A^[[A^[[A^[[A^[[A^C
root@k3s-master:~# kubectl get all -n metallb-system
NAME                                         READY   STATUS              RESTARTS   AGE
pod/controller-595647bc76-c7flz              1/1     Running             0          18m
pod/controller-66bdd896c6-82xfx              0/1     Running             0          104s
pod/frr-k8s-daemon-gd4jw                     5/5     Running             0          18m
pod/frr-k8s-daemon-gf9bw                     5/5     Running             0          18m
pod/frr-k8s-daemon-m5j6q                     5/5     Running             0          18m
pod/frr-k8s-statuscleaner-58d8956cbd-krxbl   1/1     Running             0          18m
pod/speaker-94tqc                            0/1     Running             0          67s
pod/speaker-dv8x5                            0/1     ContainerCreating   0          24s
pod/speaker-rsz9v                            1/1     Running             0          18m

NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/frr-k8s-metrics-service   ClusterIP   10.43.238.144   <none>        9140/TCP,9141/TCP   18m
service/frr-k8s-webhook-service   ClusterIP   10.43.83.185    <none>        443/TCP             18m
service/metallb-webhook-service   ClusterIP   10.43.216.6     <none>        443/TCP             18m

NAME                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/frr-k8s-daemon   3         3         3       3            3           <none>                   18m
daemonset.apps/speaker          3         3         1       2            1           kubernetes.io/os=linux   18m

NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller              1/1     1            1           18m
deployment.apps/frr-k8s-statuscleaner   1/1     1            1           18m

NAME                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-595647bc76              1         1         1       18m
replicaset.apps/controller-66bdd896c6              1         1         0       104s
replicaset.apps/frr-k8s-statuscleaner-58d8956cbd   1         1         1       18m
root@k3s-master:~# kubectl get po
NAME                                READY   STATUS    RESTARTS        AGE
nginx-daemonset-ffvld               1/1     Running   4 (8m17s ago)   46h
nginx-daemonset-mtkcm               1/1     Running   4 (8m14s ago)   46h
nginx-daemonset-s7qjj               1/1     Running   4 (8m30s ago)   46h
nginx-deployment-55566ff79b-7ccnl   1/1     Running   3 (8m14s ago)   167m
nginx-deployment-55566ff79b-gwdp2   1/1     Running   3 (8m14s ago)   167m
nginx-deployment-55566ff79b-jdg89   1/1     Running   3 (8m14s ago)   167m
nginx-deployment-55566ff79b-v2btq   1/1     Running   3 (8m14s ago)   167m
nginx-deployment-55566ff79b-z6d9n   1/1     Running   3 (8m14s ago)   167m
root@k3s-master:~# kubectl describe po -n metallb-system
Name:             controller-66bdd896c6-82xfx
Namespace:        metallb-system
Priority:         0
Service Account:  controller
Node:             k3s-worker1.sece.com/192.168.142.12
Start Time:       Thu, 04 Jun 2026 04:28:41 +0000
Labels:           app=metallb
                  component=controller
                  pod-template-hash=66bdd896c6
Annotations:      prometheus.io/port: 7472
                  prometheus.io/scrape: true
Status:           Running
IP:               10.42.2.98
IPs:
  IP:           10.42.2.98
Controlled By:  ReplicaSet/controller-66bdd896c6
Containers:
  controller:
    Container ID:  containerd://981f54bf8162a2976c4089cd53ba0fca812ff89088cafc905d1ab7be860dec6c
    Image:         quay.io/metallb/controller:v0.15.3
    Image ID:      quay.io/metallb/controller@sha256:6698ccc54c380913816ed1fd0758637ec87dd79da419c4ab170a2c26c158ab89
    Ports:         7472/TCP (monitoring), 9443/TCP (webhook-server)
    Host Ports:    0/TCP (monitoring), 0/TCP (webhook-server)
    Args:
      --port=7472
      --log-level=info
      --tls-min-version=VersionTLS12
    State:          Running
      Started:      Thu, 04 Jun 2026 04:30:16 +0000
    Ready:          True
    Restart Count:  0
    Liveness:       http-get http://:monitoring/metrics delay=10s timeout=1s period=10s #success=1 #failure=3
    Readiness:      http-get http://:monitoring/metrics delay=10s timeout=1s period=10s #success=1 #failure=3
    Environment:
      METALLB_ML_SECRET_NAME:  memberlist
      METALLB_DEPLOYMENT:      controller
    Mounts:
      /tmp/k8s-webhook-server/serving-certs from cert (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-lwp5g (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  cert:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  metallb-webhook-cert
    Optional:    false
  kube-api-access-lwp5g:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              kubernetes.io/os=linux
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  5m24s  default-scheduler  Successfully assigned metallb-system/controller-66bdd896c6-82xfx to k3s-worker1.sece.com
  Normal  Pulling    5m24s  kubelet            spec.containers{controller}: Pulling image "quay.io/metallb/controller:v0.15.3"
  Normal  Pulled     3m49s  kubelet            spec.containers{controller}: Successfully pulled image "quay.io/metallb/controller:v0.15.3" in 1m35.027s (1m35.027s including waiting). Image size: 23320938 bytes.
  Normal  Created    3m49s  kubelet            spec.containers{controller}: Container created
  Normal  Started    3m49s  kubelet            spec.containers{controller}: Container started


Name:             frr-k8s-daemon-gd4jw
Namespace:        metallb-system
Priority:         0
Service Account:  frr-k8s-daemon
Node:             k3s-worker2.sece.com/192.168.142.13
Start Time:       Thu, 04 Jun 2026 04:11:46 +0000
Labels:           app=frr-k8s
                  app.kubernetes.io/component=frr-k8s
                  control-plane=frr-k8s
                  controller-revision-hash=6b9589ffbc
                  pod-template-generation=1
Annotations:      kubectl.kubernetes.io/default-container: frr-k8s
Status:           Running
IP:               192.168.142.13
IPs:
  IP:           192.168.142.13
Controlled By:  DaemonSet/frr-k8s-daemon
Init Containers:
  cp-frr-files:
    Container ID:  containerd://f6901bf90c71a3446c96afcc0a67d6eece3c474d54f637e27a078e60d493e87b
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -rLf /tmp/frr/* /etc/frr/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:27:20 +0000
      Finished:     Thu, 04 Jun 2026 04:27:20 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /tmp/frr from frr-startup (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
  cp-reloader:
    Container ID:  containerd://660304db6c32d8885c325bb43738423f0d1331d96d2b47d1bd5fe47e95dbfbe5
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-reloader.sh /etc/frr_reloader/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:29:29 +0000
      Finished:     Thu, 04 Jun 2026 04:29:29 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_reloader from reloader (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
  cp-metrics:
    Container ID:  containerd://e4210007a59ef41546ba04e4b109b83a15e0a56c6c29dc64038f2f9f8e81c30d
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-metrics /etc/frr_metrics/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:29:32 +0000
      Finished:     Thu, 04 Jun 2026 04:29:32 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_metrics from metrics (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
  cp-frr-status:
    Container ID:  containerd://8f355c17e9d11170793ae879ce04898405d47bbeeb60f9d736bc3cb67804a23c
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-status /etc/frr_status/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:29:33 +0000
      Finished:     Thu, 04 Jun 2026 04:29:33 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_status from frr-status (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
Containers:
  controller:
    Container ID:  containerd://2ac2d494dfbd91649c98aff727dab134f2380688aed1fccb78a1593df550b322
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          9140/TCP (metricshttps)
    Host Port:     9140/TCP (metricshttps)
    Command:
      /frr-k8s
    Args:
      --metrics-bind-address=0.0.0.0:9140
      --node-name=$(NODE_NAME)
      --namespace=$(NAMESPACE)
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:29:34 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:      10m
      memory:   64Mi
    Liveness:   http-get http://127.0.0.1:7572/healthz delay=15s timeout=1s period=20s #success=1 #failure=3
    Readiness:  http-get http://127.0.0.1:7572/readyz delay=5s timeout=1s period=10s #success=1 #failure=3
    Environment:
      FRR_CONFIG_FILE:        /etc/frr_reloader/frr.conf
      FRR_RELOADER_PID_FILE:  /etc/frr_reloader/reloader.pid
      NODE_NAME:               (v1:spec.nodeName)
      NAMESPACE:              metallb-system (v1:metadata.namespace)
    Mounts:
      /etc/frr_reloader from reloader (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
  frr:
    Container ID:  containerd://3a99d9c1158558ccbfc1af8674cd913c93f9f44e4da4ec286b7e269941760df1
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      /sbin/tini -- /usr/lib/frr/docker-start
    State:          Running
      Started:      Thu, 04 Jun 2026 04:29:34 +0000
    Ready:          True
    Restart Count:  0
    Liveness:       http-get https://127.0.0.1:9141/livez delay=0s timeout=1s period=5s #success=1 #failure=3
    Startup:        http-get https://127.0.0.1:9141/livez delay=0s timeout=1s period=5s #success=1 #failure=30
    Environment:
      TINI_SUBREAPER:  true
    Mounts:
      /etc/frr from frr-conf (rw)
      /var/lib/frr from frr-lib (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
      /var/tmp/frr from frr-tmp (rw)
  frr-metrics:
    Container ID:  containerd://e2292cf9478d75c34fef32bfbe057129a1d5dec90042700b3c7f98ae2d214cea
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Ports:         9141/TCP (frrmetricshttps), 7573/TCP (frr-metrics)
    Host Ports:    9141/TCP (frrmetricshttps), 7573/TCP (frr-metrics)
    Command:
      /etc/frr_metrics/frr-metrics
    Args:
      --metrics-port=9141
      --metrics-bind-address=0.0.0.0
    State:          Running
      Started:      Thu, 04 Jun 2026 04:29:34 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_metrics from metrics (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
  frr-status:
    Container ID:  containerd://9cd803f06a211365fd4784f5326cac872f4e55e84e45448bf7ee93e8cde4a3c7
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /etc/frr_status/frr-status
    Args:
      --node-name=$(NODE_NAME)
      --namespace=$(NAMESPACE)
      --pod-name=$(POD_NAME)
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:29:34 +0000
    Ready:          True
    Restart Count:  0
    Environment:
      NODE_NAME:   (v1:spec.nodeName)
      NAMESPACE:  metallb-system (v1:metadata.namespace)
      POD_NAME:   frr-k8s-daemon-gd4jw (v1:metadata.name)
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_status from frr-status (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
  reloader:
    Container ID:  containerd://a1d02804ed25369d06a304840735e5e11d40aeeafe145aaabb86fa0cc336206f
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /etc/frr_reloader/frr-reloader.sh
    State:          Running
      Started:      Thu, 04 Jun 2026 04:29:34 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_reloader from reloader (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8xnxv (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  frr-sockets:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-startup:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      frr-k8s-frr-startup
    Optional:  false
  frr-conf:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  reloader:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  metrics:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-status:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-lib:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-tmp:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  kube-api-access-8xnxv:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                             node-role.kubernetes.io/master:NoSchedule op=Exists
                             node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/network-unavailable:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type     Reason          Age                 From               Message
  ----     ------          ----                ----               -------
  Normal   Scheduled       22m                 default-scheduler  Successfully assigned metallb-system/frr-k8s-daemon-gd4jw to k3s-worker2.sece.com
  Warning  Failed          21m                 kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://cdn01.quay.io/quayio-production-s3/sha256/a2/a2071e30319b366f2204dfcbb32f148113bb8da966a3344b6f59325e3cd1f99a?X-Amz-Algorithm=%5BREDACTED%5D&X-Amz-Credential=%5BREDACTED%5D&X-Amz-Date=%5BREDACTED%5D&X-Amz-Expires=%5BREDACTED%5D&X-Amz-Signature=%5BREDACTED%5D&X-Amz-SignedHeaders=%5BREDACTED%5D&akamai_signature=%5BREDACTED%5D&namespace=%5BREDACTED%5D&region=%5BREDACTED%5D&repo_name=%5BREDACTED%5D": dial tcp: lookup cdn01.quay.io: Try again
  Warning  Failed          21m (x2 over 21m)   kubelet            spec.initContainers{cp-frr-files}: Error: ErrImagePull
  Warning  Failed          21m                 kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to resolve reference "quay.io/frrouting/frr:10.4.3": failed to do request: Head "https://quay.io/v2/frrouting/frr/manifests/10.4.3": net/http: TLS handshake timeout
  Normal   BackOff         21m (x2 over 21m)   kubelet            spec.initContainers{cp-frr-files}: Back-off pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          21m (x2 over 21m)   kubelet            spec.initContainers{cp-frr-files}: Error: ImagePullBackOff
  Normal   Pulling         20m (x3 over 22m)   kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Normal   Pulling         15m                 kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Normal   SandboxChanged  15m                 kubelet            Pod sandbox changed, it will be killed and re-created.
  Normal   Pulling         12m (x5 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          12m (x5 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to resolve reference "quay.io/frrouting/frr:10.4.3": failed to do request: Head "https://quay.io/v2/frrouting/frr/manifests/10.4.3": dial tcp: lookup quay.io: Try again
  Warning  Failed          12m (x5 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Error: ErrImagePull
  Normal   BackOff         11m (x12 over 14m)  kubelet            spec.initContainers{cp-frr-files}: Back-off pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          11m (x12 over 14m)  kubelet            spec.initContainers{cp-frr-files}: Error: ImagePullBackOff
  Normal   SandboxChanged  9m11s               kubelet            Pod sandbox changed, it will be killed and re-created.
  Normal   Pulling         9m10s               kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Normal   Started         6m45s               kubelet            spec.initContainers{cp-frr-files}: Container started
  Normal   Created         6m45s               kubelet            spec.initContainers{cp-frr-files}: Container created
  Normal   Pulled          6m45s               kubelet            spec.initContainers{cp-frr-files}: Successfully pulled image "quay.io/frrouting/frr:10.4.3" in 2m25.01s (2m25.01s including waiting). Image size: 90663535 bytes.
  Normal   Pulling         6m44s               kubelet            spec.initContainers{cp-reloader}: Pulling image "quay.io/metallb/frr-k8s:v0.0.25"
  Normal   Pulled          4m36s               kubelet            spec.initContainers{cp-reloader}: Successfully pulled image "quay.io/metallb/frr-k8s:v0.0.25" in 2m8.106s (2m8.106s including waiting). Image size: 119558058 bytes.
  Normal   Created         4m36s               kubelet            spec.initContainers{cp-reloader}: Container created
  Normal   Started         4m36s               kubelet            spec.initContainers{cp-reloader}: Container started
  Normal   Pulled          4m33s               kubelet            spec.initContainers{cp-metrics}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Created         4m33s               kubelet            spec.initContainers{cp-metrics}: Container created
  Normal   Started         4m33s               kubelet            spec.initContainers{cp-metrics}: Container started
  Normal   Created         4m32s               kubelet            spec.initContainers{cp-frr-status}: Container created
  Normal   Pulled          4m32s               kubelet            spec.initContainers{cp-frr-status}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Started         4m32s               kubelet            spec.initContainers{cp-frr-status}: Container started
  Normal   Pulled          4m31s               kubelet            spec.containers{controller}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Created         4m31s               kubelet            spec.containers{controller}: Container created
  Normal   Started         4m31s               kubelet            spec.containers{controller}: Container started
  Normal   Pulled          4m31s               kubelet            spec.containers{frr}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod
  Normal   Created         4m31s               kubelet            spec.containers{frr}: Container created
  Normal   Started         4m31s               kubelet            spec.containers{frr}: Container started
  Normal   Pulled          4m31s               kubelet            spec.containers{frr-metrics}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod
  Normal   Created         4m31s               kubelet            spec.containers{frr-metrics}: Container created
  Normal   Started         4m31s               kubelet            spec.containers{frr-metrics}: Container started
  Normal   Pulled          4m31s               kubelet            spec.containers{frr-status}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod


Name:             frr-k8s-daemon-gf9bw
Namespace:        metallb-system
Priority:         0
Service Account:  frr-k8s-daemon
Node:             k3s-worker1.sece.com/192.168.142.12
Start Time:       Thu, 04 Jun 2026 04:11:46 +0000
Labels:           app=frr-k8s
                  app.kubernetes.io/component=frr-k8s
                  control-plane=frr-k8s
                  controller-revision-hash=6b9589ffbc
                  pod-template-generation=1
Annotations:      kubectl.kubernetes.io/default-container: frr-k8s
Status:           Running
IP:               192.168.142.12
IPs:
  IP:           192.168.142.12
Controlled By:  DaemonSet/frr-k8s-daemon
Init Containers:
  cp-frr-files:
    Container ID:  containerd://65a9be9a1c86ec3ac11cf3c9970caffd9d252e91bf666b157979b61ed3ce1a2c
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -rLf /tmp/frr/* /etc/frr/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:27:29 +0000
      Finished:     Thu, 04 Jun 2026 04:27:29 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /tmp/frr from frr-startup (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
  cp-reloader:
    Container ID:  containerd://efcfd2e5e34b042ccbc1d2f44be7d0fcf23bff0a3c4191a3e772a9b7ff0bcaab
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-reloader.sh /etc/frr_reloader/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:28:52 +0000
      Finished:     Thu, 04 Jun 2026 04:28:52 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_reloader from reloader (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
  cp-metrics:
    Container ID:  containerd://524fe20dcdce959824c03299cdd48bef25cb4464f23b3e3a6ae9047d4b637e91
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-metrics /etc/frr_metrics/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:28:53 +0000
      Finished:     Thu, 04 Jun 2026 04:28:53 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_metrics from metrics (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
  cp-frr-status:
    Container ID:  containerd://249e926c8ee0998a70c9254b110fea0de2079cb442ee5fa079e0e1a976c8f930
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-status /etc/frr_status/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:28:54 +0000
      Finished:     Thu, 04 Jun 2026 04:28:54 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_status from frr-status (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
Containers:
  controller:
    Container ID:  containerd://c0af64e1944bae03924cb6a66712d88955acc7301b7cf5784ede08b68650dbc5
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          9140/TCP (metricshttps)
    Host Port:     9140/TCP (metricshttps)
    Command:
      /frr-k8s
    Args:
      --metrics-bind-address=0.0.0.0:9140
      --node-name=$(NODE_NAME)
      --namespace=$(NAMESPACE)
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:28:55 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:      10m
      memory:   64Mi
    Liveness:   http-get http://127.0.0.1:7572/healthz delay=15s timeout=1s period=20s #success=1 #failure=3
    Readiness:  http-get http://127.0.0.1:7572/readyz delay=5s timeout=1s period=10s #success=1 #failure=3
    Environment:
      FRR_CONFIG_FILE:        /etc/frr_reloader/frr.conf
      FRR_RELOADER_PID_FILE:  /etc/frr_reloader/reloader.pid
      NODE_NAME:               (v1:spec.nodeName)
      NAMESPACE:              metallb-system (v1:metadata.namespace)
    Mounts:
      /etc/frr_reloader from reloader (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
  frr:
    Container ID:  containerd://9b00903ad80a8b6acdbb40f9cba980085b99bff2e6869112b1c73a80265310fb
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      /sbin/tini -- /usr/lib/frr/docker-start
    State:          Running
      Started:      Thu, 04 Jun 2026 04:28:55 +0000
    Ready:          True
    Restart Count:  0
    Liveness:       http-get https://127.0.0.1:9141/livez delay=0s timeout=1s period=5s #success=1 #failure=3
    Startup:        http-get https://127.0.0.1:9141/livez delay=0s timeout=1s period=5s #success=1 #failure=30
    Environment:
      TINI_SUBREAPER:  true
    Mounts:
      /etc/frr from frr-conf (rw)
      /var/lib/frr from frr-lib (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
      /var/tmp/frr from frr-tmp (rw)
  frr-metrics:
    Container ID:  containerd://f90551f366df4c0f170ff8cd3f578c7c56224dad4ee1f8188f6151cb03effcb0
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Ports:         9141/TCP (frrmetricshttps), 7573/TCP (frr-metrics)
    Host Ports:    9141/TCP (frrmetricshttps), 7573/TCP (frr-metrics)
    Command:
      /etc/frr_metrics/frr-metrics
    Args:
      --metrics-port=9141
      --metrics-bind-address=0.0.0.0
    State:          Running
      Started:      Thu, 04 Jun 2026 04:28:55 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_metrics from metrics (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
  frr-status:
    Container ID:  containerd://dffe66642e5c6a6550b39962d89c4a13d941b7acf557b922923317f4b19daee0
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /etc/frr_status/frr-status
    Args:
      --node-name=$(NODE_NAME)
      --namespace=$(NAMESPACE)
      --pod-name=$(POD_NAME)
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:28:55 +0000
    Ready:          True
    Restart Count:  0
    Environment:
      NODE_NAME:   (v1:spec.nodeName)
      NAMESPACE:  metallb-system (v1:metadata.namespace)
      POD_NAME:   frr-k8s-daemon-gf9bw (v1:metadata.name)
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_status from frr-status (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
  reloader:
    Container ID:  containerd://6bcf08ed64b1207b9bdc799d3214e64fa741789b5c17998963b76d7f3c2ac17f
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /etc/frr_reloader/frr-reloader.sh
    State:          Running
      Started:      Thu, 04 Jun 2026 04:28:55 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_reloader from reloader (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rmwb9 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  frr-sockets:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-startup:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      frr-k8s-frr-startup
    Optional:  false
  frr-conf:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  reloader:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  metrics:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-status:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-lib:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-tmp:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  kube-api-access-rmwb9:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                             node-role.kubernetes.io/master:NoSchedule op=Exists
                             node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/network-unavailable:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type     Reason          Age                 From               Message
  ----     ------          ----                ----               -------
  Normal   Scheduled       22m                 default-scheduler  Successfully assigned metallb-system/frr-k8s-daemon-gf9bw to k3s-worker1.sece.com
  Normal   Pulling         22m                 kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Normal   SandboxChanged  15m                 kubelet            Pod sandbox changed, it will be killed and re-created.
  Normal   Pulling         12m (x5 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          12m (x5 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to resolve reference "quay.io/frrouting/frr:10.4.3": failed to do request: Head "https://quay.io/v2/frrouting/frr/manifests/10.4.3": dial tcp: lookup quay.io: Try again
  Warning  Failed          12m (x5 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Error: ErrImagePull
  Normal   BackOff         11m (x14 over 15m)  kubelet            spec.initContainers{cp-frr-files}: Back-off pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          11m (x14 over 15m)  kubelet            spec.initContainers{cp-frr-files}: Error: ImagePullBackOff
  Normal   SandboxChanged  9m13s               kubelet            Pod sandbox changed, it will be killed and re-created.
  Normal   Pulling         9m13s               kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Normal   Pulled          6m36s               kubelet            spec.initContainers{cp-frr-files}: Successfully pulled image "quay.io/frrouting/frr:10.4.3" in 2m37.006s (2m37.006s including waiting). Image size: 90663535 bytes.
  Normal   Created         6m36s               kubelet            spec.initContainers{cp-frr-files}: Container created
  Normal   Started         6m36s               kubelet            spec.initContainers{cp-frr-files}: Container started
  Normal   Pulling         6m35s               kubelet            spec.initContainers{cp-reloader}: Pulling image "quay.io/metallb/frr-k8s:v0.0.25"
  Normal   Pulled          5m13s               kubelet            spec.initContainers{cp-reloader}: Successfully pulled image "quay.io/metallb/frr-k8s:v0.0.25" in 1m21.911s (1m21.911s including waiting). Image size: 119558058 bytes.
  Normal   Created         5m13s               kubelet            spec.initContainers{cp-reloader}: Container created
  Normal   Started         5m13s               kubelet            spec.initContainers{cp-reloader}: Container started
  Normal   Pulled          5m12s               kubelet            spec.initContainers{cp-metrics}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Created         5m12s               kubelet            spec.initContainers{cp-metrics}: Container created
  Normal   Started         5m12s               kubelet            spec.initContainers{cp-metrics}: Container started
  Normal   Pulled          5m11s               kubelet            spec.initContainers{cp-frr-status}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Created         5m11s               kubelet            spec.initContainers{cp-frr-status}: Container created
  Normal   Started         5m11s               kubelet            spec.initContainers{cp-frr-status}: Container started
  Normal   Pulled          5m10s               kubelet            spec.containers{controller}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Created         5m10s               kubelet            spec.containers{controller}: Container created
  Normal   Started         5m10s               kubelet            spec.containers{controller}: Container started
  Normal   Pulled          5m10s               kubelet            spec.containers{frr}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod
  Normal   Created         5m10s               kubelet            spec.containers{frr}: Container created
  Normal   Started         5m10s               kubelet            spec.containers{frr}: Container started
  Normal   Pulled          5m10s               kubelet            spec.containers{frr-metrics}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod
  Normal   Created         5m10s               kubelet            spec.containers{frr-metrics}: Container created
  Normal   Started         5m10s               kubelet            spec.containers{frr-metrics}: Container started
  Normal   Pulled          5m10s               kubelet            spec.containers{frr-status}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod


Name:             frr-k8s-daemon-m5j6q
Namespace:        metallb-system
Priority:         0
Service Account:  frr-k8s-daemon
Node:             k3s-master.sece.com/192.168.142.11
Start Time:       Thu, 04 Jun 2026 04:11:46 +0000
Labels:           app=frr-k8s
                  app.kubernetes.io/component=frr-k8s
                  control-plane=frr-k8s
                  controller-revision-hash=6b9589ffbc
                  pod-template-generation=1
Annotations:      kubectl.kubernetes.io/default-container: frr-k8s
Status:           Running
IP:               192.168.142.11
IPs:
  IP:           192.168.142.11
Controlled By:  DaemonSet/frr-k8s-daemon
Init Containers:
  cp-frr-files:
    Container ID:  containerd://5a44b5665f4402d50dc5d29f711730605e214b85e98af2c9df36e2bdd9f1f2c9
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -rLf /tmp/frr/* /etc/frr/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:28:39 +0000
      Finished:     Thu, 04 Jun 2026 04:28:39 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /tmp/frr from frr-startup (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
  cp-reloader:
    Container ID:  containerd://4eaecdf68fe34075a1022a5f423b8bba34d12599b1bd603dd1379f41ea97e0ce
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-reloader.sh /etc/frr_reloader/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:30:01 +0000
      Finished:     Thu, 04 Jun 2026 04:30:01 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_reloader from reloader (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
  cp-metrics:
    Container ID:  containerd://95b11f9b917640a6b44e60c7c6457f23c4636b35f99e3f07093045bf0c0c30a6
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-metrics /etc/frr_metrics/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:30:02 +0000
      Finished:     Thu, 04 Jun 2026 04:30:02 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_metrics from metrics (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
  cp-frr-status:
    Container ID:  containerd://ff219a61911f902ccd158d33769d54a9dd8d26277356e7c6c68c82b9d78d5c60
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      cp -f /frr-status /etc/frr_status/
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 04 Jun 2026 04:30:03 +0000
      Finished:     Thu, 04 Jun 2026 04:30:03 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr_status from frr-status (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
Containers:
  controller:
    Container ID:  containerd://b7baf2b1da9206035d7ab94cc7bf6e2267fc810ab2dc14a5b9ad1bcfc838efe4
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          9140/TCP (metricshttps)
    Host Port:     9140/TCP (metricshttps)
    Command:
      /frr-k8s
    Args:
      --metrics-bind-address=0.0.0.0:9140
      --node-name=$(NODE_NAME)
      --namespace=$(NAMESPACE)
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:30:04 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:      10m
      memory:   64Mi
    Liveness:   http-get http://127.0.0.1:7572/healthz delay=15s timeout=1s period=20s #success=1 #failure=3
    Readiness:  http-get http://127.0.0.1:7572/readyz delay=5s timeout=1s period=10s #success=1 #failure=3
    Environment:
      FRR_CONFIG_FILE:        /etc/frr_reloader/frr.conf
      FRR_RELOADER_PID_FILE:  /etc/frr_reloader/reloader.pid
      NODE_NAME:               (v1:spec.nodeName)
      NAMESPACE:              metallb-system (v1:metadata.namespace)
    Mounts:
      /etc/frr_reloader from reloader (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
  frr:
    Container ID:  containerd://9ac7e3e224d6d7d65c6c3f3078532885acb65e6c8d9863b57beb18d325873188
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      /sbin/tini -- /usr/lib/frr/docker-start
    State:          Running
      Started:      Thu, 04 Jun 2026 04:30:04 +0000
    Ready:          True
    Restart Count:  0
    Liveness:       http-get https://127.0.0.1:9141/livez delay=0s timeout=1s period=5s #success=1 #failure=3
    Startup:        http-get https://127.0.0.1:9141/livez delay=0s timeout=1s period=5s #success=1 #failure=30
    Environment:
      TINI_SUBREAPER:  true
    Mounts:
      /etc/frr from frr-conf (rw)
      /var/lib/frr from frr-lib (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
      /var/tmp/frr from frr-tmp (rw)
  frr-metrics:
    Container ID:  containerd://ac3b828a7fef7dca9834237336dc74b44287bda0c8c9f9d495ad8aa0892be8a2
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Ports:         9141/TCP (frrmetricshttps), 7573/TCP (frr-metrics)
    Host Ports:    9141/TCP (frrmetricshttps), 7573/TCP (frr-metrics)
    Command:
      /etc/frr_metrics/frr-metrics
    Args:
      --metrics-port=9141
      --metrics-bind-address=0.0.0.0
    State:          Running
      Started:      Thu, 04 Jun 2026 04:30:04 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_metrics from metrics (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
  frr-status:
    Container ID:  containerd://315c85c6490c8e1228af68d8a7f022eb7d862628a4b7ecb9b55d7badc964ef1a
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /etc/frr_status/frr-status
    Args:
      --node-name=$(NODE_NAME)
      --namespace=$(NAMESPACE)
      --pod-name=$(POD_NAME)
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:30:04 +0000
    Ready:          True
    Restart Count:  0
    Environment:
      NODE_NAME:   (v1:spec.nodeName)
      NAMESPACE:  metallb-system (v1:metadata.namespace)
      POD_NAME:   frr-k8s-daemon-m5j6q (v1:metadata.name)
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_status from frr-status (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
  reloader:
    Container ID:  containerd://5189d67713a895fada06ea38b5ef0efc7751a3ec056205a88bf0215e06e1047c
    Image:         quay.io/frrouting/frr:10.4.3
    Image ID:      quay.io/frrouting/frr@sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df
    Port:          <none>
    Host Port:     <none>
    Command:
      /etc/frr_reloader/frr-reloader.sh
    State:          Running
      Started:      Thu, 04 Jun 2026 04:30:04 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/frr from frr-conf (rw)
      /etc/frr_reloader from reloader (rw)
      /var/run/frr from frr-sockets (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c8f9v (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  frr-sockets:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-startup:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      frr-k8s-frr-startup
    Optional:  false
  frr-conf:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  reloader:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  metrics:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-status:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-lib:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  frr-tmp:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  kube-api-access-c8f9v:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                             node-role.kubernetes.io/master:NoSchedule op=Exists
                             node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/network-unavailable:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type     Reason          Age                 From               Message
  ----     ------          ----                ----               -------
  Normal   Scheduled       22m                 default-scheduler  Successfully assigned metallb-system/frr-k8s-daemon-m5j6q to k3s-master.sece.com
  Warning  Failed          22m                 kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://quay.io/v2/frrouting/frr/manifests/sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df": dial tcp: lookup quay.io: Try again
  Warning  Failed          21m                 kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://cdn01.quay.io/quayio-production-s3/sha256/a2/a2071e30319b366f2204dfcbb32f148113bb8da966a3344b6f59325e3cd1f99a?X-Amz-Algorithm=%5BREDACTED%5D&X-Amz-Credential=%5BREDACTED%5D&X-Amz-Date=%5BREDACTED%5D&X-Amz-Expires=%5BREDACTED%5D&X-Amz-Signature=%5BREDACTED%5D&X-Amz-SignedHeaders=%5BREDACTED%5D&akamai_signature=%5BREDACTED%5D&namespace=%5BREDACTED%5D&region=%5BREDACTED%5D&repo_name=%5BREDACTED%5D": dial tcp: lookup cdn01.quay.io: Try again
  Warning  Failed          20m                 kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to resolve reference "quay.io/frrouting/frr:10.4.3": failed to do request: Head "https://quay.io/v2/frrouting/frr/manifests/10.4.3": dial tcp: lookup quay.io: Try again
  Normal   Pulling         20m (x4 over 22m)   kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          19m (x4 over 22m)   kubelet            spec.initContainers{cp-frr-files}: Error: ErrImagePull
  Warning  Failed          19m                 kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://quay.io/v2/frrouting/frr/manifests/sha256:8745af1f9bbbc26ab11d99ccdf35e07aa3427a199749bef0cd6bb5132bb130df": read tcp 192.168.142.11:48298->34.232.60.145:443: read: connection reset by peer
  Normal   BackOff         19m (x7 over 22m)   kubelet            spec.initContainers{cp-frr-files}: Back-off pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          19m (x7 over 22m)   kubelet            spec.initContainers{cp-frr-files}: Error: ImagePullBackOff
  Normal   SandboxChanged  15m                 kubelet            Pod sandbox changed, it will be killed and re-created.
  Warning  Failed          15m                 kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to resolve reference "quay.io/frrouting/frr:10.4.3": failed to do request: Head "https://quay.io/v2/frrouting/frr/manifests/10.4.3": net/http: TLS handshake timeout
  Normal   Pulling         12m (x5 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          12m (x5 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Error: ErrImagePull
  Warning  Failed          12m (x4 over 15m)   kubelet            spec.initContainers{cp-frr-files}: Failed to pull image "quay.io/frrouting/frr:10.4.3": failed to pull and unpack image "quay.io/frrouting/frr:10.4.3": failed to resolve reference "quay.io/frrouting/frr:10.4.3": failed to do request: Head "https://quay.io/v2/frrouting/frr/manifests/10.4.3": dial tcp: lookup quay.io: Try again
  Normal   BackOff         11m (x15 over 15m)  kubelet            spec.initContainers{cp-frr-files}: Back-off pulling image "quay.io/frrouting/frr:10.4.3"
  Warning  Failed          11m (x15 over 15m)  kubelet            spec.initContainers{cp-frr-files}: Error: ImagePullBackOff
  Normal   SandboxChanged  9m21s               kubelet            Pod sandbox changed, it will be killed and re-created.
  Normal   Pulling         9m20s               kubelet            spec.initContainers{cp-frr-files}: Pulling image "quay.io/frrouting/frr:10.4.3"
  Normal   Started         5m26s               kubelet            spec.initContainers{cp-frr-files}: Container started
  Normal   Created         5m26s               kubelet            spec.initContainers{cp-frr-files}: Container created
  Normal   Pulled          5m26s               kubelet            spec.initContainers{cp-frr-files}: Successfully pulled image "quay.io/frrouting/frr:10.4.3" in 3m54.658s (3m54.658s including waiting). Image size: 90663535 bytes.
  Normal   Pulling         5m25s               kubelet            spec.initContainers{cp-reloader}: Pulling image "quay.io/metallb/frr-k8s:v0.0.25"
  Normal   Pulled          4m4s                kubelet            spec.initContainers{cp-reloader}: Successfully pulled image "quay.io/metallb/frr-k8s:v0.0.25" in 1m20.321s (1m20.321s including waiting). Image size: 119558058 bytes.
  Normal   Created         4m4s                kubelet            spec.initContainers{cp-reloader}: Container created
  Normal   Started         4m4s                kubelet            spec.initContainers{cp-reloader}: Container started
  Normal   Pulled          4m3s                kubelet            spec.initContainers{cp-metrics}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Created         4m3s                kubelet            spec.initContainers{cp-metrics}: Container created
  Normal   Started         4m3s                kubelet            spec.initContainers{cp-metrics}: Container started
  Normal   Created         4m2s                kubelet            spec.initContainers{cp-frr-status}: Container created
  Normal   Pulled          4m2s                kubelet            spec.initContainers{cp-frr-status}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Started         4m2s                kubelet            spec.initContainers{cp-frr-status}: Container started
  Normal   Created         4m1s                kubelet            spec.containers{frr}: Container created
  Normal   Created         4m1s                kubelet            spec.containers{controller}: Container created
  Normal   Started         4m1s                kubelet            spec.containers{controller}: Container started
  Normal   Pulled          4m1s                kubelet            spec.containers{frr}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod
  Normal   Pulled          4m1s                kubelet            spec.containers{controller}: Container image "quay.io/metallb/frr-k8s:v0.0.25" already present on machine and can be accessed by the pod
  Normal   Started         4m1s                kubelet            spec.containers{frr}: Container started
  Normal   Pulled          4m1s                kubelet            spec.containers{frr-metrics}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod
  Normal   Created         4m1s                kubelet            spec.containers{frr-metrics}: Container created
  Normal   Started         4m1s                kubelet            spec.containers{frr-metrics}: Container started
  Normal   Pulled          4m1s                kubelet            spec.containers{frr-status}: Container image "quay.io/frrouting/frr:10.4.3" already present on machine and can be accessed by the pod
  Normal   Created         4m1s                kubelet            spec.containers{frr-status}: Container created


Name:             frr-k8s-statuscleaner-58d8956cbd-krxbl
Namespace:        metallb-system
Priority:         0
Service Account:  frr-k8s-daemon
Node:             k3s-worker1.sece.com/192.168.142.12
Start Time:       Thu, 04 Jun 2026 04:11:46 +0000
Labels:           app=frr-k8s-webhook-server
                  app.kubernetes.io/component=statuscleaner
                  control-plane=statuscleaner
                  pod-template-hash=58d8956cbd
Annotations:      kubectl.kubernetes.io/default-container: frr-k8s-webhook-server
Status:           Running
IP:               192.168.142.12
IPs:
  IP:           192.168.142.12
Controlled By:  ReplicaSet/frr-k8s-statuscleaner-58d8956cbd
Containers:
  frr-k8s-statuscleaner:
    Container ID:  containerd://3e145884ea94cb3d335c857eabd65ac93bc66ed6435304b1bd1b2bba2a2dd0c3
    Image:         quay.io/metallb/frr-k8s:v0.0.25
    Image ID:      quay.io/metallb/frr-k8s@sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4
    Port:          19443/TCP (webhook)
    Host Port:     19443/TCP (webhook)
    Command:
      /statuscleaner
    Args:
      --log-level=info
      --namespace=$(NAMESPACE)
    State:          Running
      Started:      Thu, 04 Jun 2026 04:28:52 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:      10m
      memory:   64Mi
    Liveness:   http-get https://:webhook/healthz delay=15s timeout=1s period=20s #success=1 #failure=3
    Readiness:  http-get https://:webhook/healthz delay=5s timeout=1s period=10s #success=1 #failure=3
    Environment:
      NAMESPACE:  metallb-system (v1:metadata.namespace)
    Mounts:
      /tmp/k8s-webhook-server/serving-certs from cert (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-kr2m6 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  cert:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  frr-k8s-webhook-server-cert
    Optional:    false
  kube-api-access-kr2m6:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                             node-role.kubernetes.io/master:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason          Age                 From               Message
  ----     ------          ----                ----               -------
  Normal   Scheduled       22m                 default-scheduler  Successfully assigned metallb-system/frr-k8s-statuscleaner-58d8956cbd-krxbl to k3s-worker1.sece.com
  Warning  Failed          22m                 kubelet            spec.containers{frr-k8s-statuscleaner}: Failed to pull image "quay.io/metallb/frr-k8s:v0.0.25": failed to pull and unpack image "quay.io/metallb/frr-k8s:v0.0.25": failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://quay.io/v2/metallb/frr-k8s/manifests/sha256:1cb06fb2d5538c9f9b20d3adf00da8d1e6cb0166bc15df8add0d9efe578641a4": net/http: TLS handshake timeout
  Warning  Failed          22m                 kubelet            spec.containers{frr-k8s-statuscleaner}: Error: ErrImagePull
  Normal   BackOff         22m                 kubelet            spec.containers{frr-k8s-statuscleaner}: Back-off pulling image "quay.io/metallb/frr-k8s:v0.0.25"
  Warning  Failed          22m                 kubelet            spec.containers{frr-k8s-statuscleaner}: Error: ImagePullBackOff
  Normal   Pulling         21m (x2 over 22m)   kubelet            spec.containers{frr-k8s-statuscleaner}: Pulling image "quay.io/metallb/frr-k8s:v0.0.25"
  Normal   SandboxChanged  15m                 kubelet            Pod sandbox changed, it will be killed and re-created.
  Normal   Pulling         12m (x5 over 15m)   kubelet            spec.containers{frr-k8s-statuscleaner}: Pulling image "quay.io/metallb/frr-k8s:v0.0.25"
  Warning  Failed          12m (x5 over 15m)   kubelet            spec.containers{frr-k8s-statuscleaner}: Failed to pull image "quay.io/metallb/frr-k8s:v0.0.25": failed to pull and unpack image "quay.io/metallb/frr-k8s:v0.0.25": failed to resolve reference "quay.io/metallb/frr-k8s:v0.0.25": failed to do request: Head "https://quay.io/v2/metallb/frr-k8s/manifests/v0.0.25": dial tcp: lookup quay.io: Try again
  Warning  Failed          12m (x5 over 15m)   kubelet            spec.containers{frr-k8s-statuscleaner}: Error: ErrImagePull
  Normal   BackOff         11m (x14 over 15m)  kubelet            spec.containers{frr-k8s-statuscleaner}: Back-off pulling image "quay.io/metallb/frr-k8s:v0.0.25"
  Warning  Failed          11m (x14 over 15m)  kubelet            spec.containers{frr-k8s-statuscleaner}: Error: ImagePullBackOff
  Normal   SandboxChanged  9m13s               kubelet            Pod sandbox changed, it will be killed and re-created.
  Normal   Pulling         9m13s               kubelet            spec.containers{frr-k8s-statuscleaner}: Pulling image "quay.io/metallb/frr-k8s:v0.0.25"
  Normal   Pulled          5m13s               kubelet            spec.containers{frr-k8s-statuscleaner}: Successfully pulled image "quay.io/metallb/frr-k8s:v0.0.25" in 3m59.304s (3m59.304s including waiting). Image size: 119558058 bytes.
  Normal   Created         5m13s               kubelet            spec.containers{frr-k8s-statuscleaner}: Container created
  Normal   Started         5m13s               kubelet            spec.containers{frr-k8s-statuscleaner}: Container started


Name:             speaker-7rd2c
Namespace:        metallb-system
Priority:         0
Service Account:  speaker
Node:             k3s-worker2.sece.com/192.168.142.13
Start Time:       Thu, 04 Jun 2026 04:30:49 +0000
Labels:           app=metallb
                  component=speaker
                  controller-revision-hash=7dd8d8ffbb
                  pod-template-generation=2
Annotations:      prometheus.io/port: 7472
                  prometheus.io/scrape: true
Status:           Running
IP:               192.168.142.13
IPs:
  IP:           192.168.142.13
Controlled By:  DaemonSet/speaker
Containers:
  speaker:
    Container ID:  containerd://f86a56e35e79a5c1c9f905ca62ff0f748880091ffc76e16ff4e1aab507cf43b2
    Image:         quay.io/metallb/speaker:v0.15.3
    Image ID:      quay.io/metallb/speaker@sha256:c6a5b25b2e1fba610a57b2db4bb8141d7c133569d561a8cc29e38ca5113efbc4
    Ports:         7472/TCP (monitoring), 7946/TCP (memberlist-tcp), 7946/UDP (memberlist-udp)
    Host Ports:    7472/TCP (monitoring), 7946/TCP (memberlist-tcp), 7946/UDP (memberlist-udp)
    Args:
      --port=7472
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:31:19 +0000
    Ready:          True
    Restart Count:  0
    Liveness:       http-get http://:monitoring/metrics delay=10s timeout=1s period=10s #success=1 #failure=3
    Readiness:      http-get http://:monitoring/metrics delay=10s timeout=1s period=10s #success=1 #failure=3
    Environment:
      METALLB_NODE_NAME:            (v1:spec.nodeName)
      METALLB_POD_NAME:            speaker-7rd2c (v1:metadata.name)
      METALLB_HOST:                 (v1:status.hostIP)
      METALLB_ML_BIND_ADDR:         (v1:status.podIP)
      METALLB_ML_LABELS:           app=metallb,component=speaker
      METALLB_ML_SECRET_KEY_PATH:  /etc/ml_secret_key
    Mounts:
      /etc/metallb from metallb-excludel2 (ro)
      /etc/ml_secret_key from memberlist (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-j7rvz (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  memberlist:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  memberlist
    Optional:    false
  metallb-excludel2:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      metallb-excludel2
    Optional:  false
  kube-api-access-j7rvz:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              kubernetes.io/os=linux
Tolerations:                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                             node-role.kubernetes.io/master:NoSchedule op=Exists
                             node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/network-unavailable:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m16s  default-scheduler  Successfully assigned metallb-system/speaker-7rd2c to k3s-worker2.sece.com
  Normal  Pulling    3m16s  kubelet            spec.containers{speaker}: Pulling image "quay.io/metallb/speaker:v0.15.3"
  Normal  Pulled     2m46s  kubelet            spec.containers{speaker}: Successfully pulled image "quay.io/metallb/speaker:v0.15.3" in 29.977s (29.977s including waiting). Image size: 51445238 bytes.
  Normal  Created    2m46s  kubelet            spec.containers{speaker}: Container created
  Normal  Started    2m46s  kubelet            spec.containers{speaker}: Container started


Name:             speaker-94tqc
Namespace:        metallb-system
Priority:         0
Service Account:  speaker
Node:             k3s-master.sece.com/192.168.142.11
Start Time:       Thu, 04 Jun 2026 04:29:17 +0000
Labels:           app=metallb
                  component=speaker
                  controller-revision-hash=7dd8d8ffbb
                  pod-template-generation=2
Annotations:      prometheus.io/port: 7472
                  prometheus.io/scrape: true
Status:           Running
IP:               192.168.142.11
IPs:
  IP:           192.168.142.11
Controlled By:  DaemonSet/speaker
Containers:
  speaker:
    Container ID:  containerd://0ec3181e0a163dbe635f693009fc3f2eace9c7b98cc5374e2879238655abf2ce
    Image:         quay.io/metallb/speaker:v0.15.3
    Image ID:      quay.io/metallb/speaker@sha256:c6a5b25b2e1fba610a57b2db4bb8141d7c133569d561a8cc29e38ca5113efbc4
    Ports:         7472/TCP (monitoring), 7946/TCP (memberlist-tcp), 7946/UDP (memberlist-udp)
    Host Ports:    7472/TCP (monitoring), 7946/TCP (memberlist-tcp), 7946/UDP (memberlist-udp)
    Args:
      --port=7472
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:30:15 +0000
    Ready:          True
    Restart Count:  0
    Liveness:       http-get http://:monitoring/metrics delay=10s timeout=1s period=10s #success=1 #failure=3
    Readiness:      http-get http://:monitoring/metrics delay=10s timeout=1s period=10s #success=1 #failure=3
    Environment:
      METALLB_NODE_NAME:            (v1:spec.nodeName)
      METALLB_POD_NAME:            speaker-94tqc (v1:metadata.name)
      METALLB_HOST:                 (v1:status.hostIP)
      METALLB_ML_BIND_ADDR:         (v1:status.podIP)
      METALLB_ML_LABELS:           app=metallb,component=speaker
      METALLB_ML_SECRET_KEY_PATH:  /etc/ml_secret_key
    Mounts:
      /etc/metallb from metallb-excludel2 (ro)
      /etc/ml_secret_key from memberlist (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-l44bl (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  memberlist:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  memberlist
    Optional:    false
  metallb-excludel2:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      metallb-excludel2
    Optional:  false
  kube-api-access-l44bl:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              kubernetes.io/os=linux
Tolerations:                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                             node-role.kubernetes.io/master:NoSchedule op=Exists
                             node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/network-unavailable:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  4m48s  default-scheduler  Successfully assigned metallb-system/speaker-94tqc to k3s-master.sece.com
  Normal  Pulling    4m48s  kubelet            spec.containers{speaker}: Pulling image "quay.io/metallb/speaker:v0.15.3"
  Normal  Pulled     3m50s  kubelet            spec.containers{speaker}: Successfully pulled image "quay.io/metallb/speaker:v0.15.3" in 57.492s (57.492s including waiting). Image size: 51445238 bytes.
  Normal  Created    3m50s  kubelet            spec.containers{speaker}: Container created
  Normal  Started    3m50s  kubelet            spec.containers{speaker}: Container started


Name:             speaker-dv8x5
Namespace:        metallb-system
Priority:         0
Service Account:  speaker
Node:             k3s-worker1.sece.com/192.168.142.12
Start Time:       Thu, 04 Jun 2026 04:30:00 +0000
Labels:           app=metallb
                  component=speaker
                  controller-revision-hash=7dd8d8ffbb
                  pod-template-generation=2
Annotations:      prometheus.io/port: 7472
                  prometheus.io/scrape: true
Status:           Running
IP:               192.168.142.12
IPs:
  IP:           192.168.142.12
Controlled By:  DaemonSet/speaker
Containers:
  speaker:
    Container ID:  containerd://3d8022ccd13544098f699d80c93d86dfcf11f11361c2288bb277ab04b3542513
    Image:         quay.io/metallb/speaker:v0.15.3
    Image ID:      quay.io/metallb/speaker@sha256:c6a5b25b2e1fba610a57b2db4bb8141d7c133569d561a8cc29e38ca5113efbc4
    Ports:         7472/TCP (monitoring), 7946/TCP (memberlist-tcp), 7946/UDP (memberlist-udp)
    Host Ports:    7472/TCP (monitoring), 7946/TCP (memberlist-tcp), 7946/UDP (memberlist-udp)
    Args:
      --port=7472
      --log-level=info
    State:          Running
      Started:      Thu, 04 Jun 2026 04:30:36 +0000
    Ready:          True
    Restart Count:  0
    Liveness:       http-get http://:monitoring/metrics delay=10s timeout=1s period=10s #success=1 #failure=3
    Readiness:      http-get http://:monitoring/metrics delay=10s timeout=1s period=10s #success=1 #failure=3
    Environment:
      METALLB_NODE_NAME:            (v1:spec.nodeName)
      METALLB_POD_NAME:            speaker-dv8x5 (v1:metadata.name)
      METALLB_HOST:                 (v1:status.hostIP)
      METALLB_ML_BIND_ADDR:         (v1:status.podIP)
      METALLB_ML_LABELS:           app=metallb,component=speaker
      METALLB_ML_SECRET_KEY_PATH:  /etc/ml_secret_key
    Mounts:
      /etc/metallb from metallb-excludel2 (ro)
      /etc/ml_secret_key from memberlist (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ckdld (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  memberlist:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  memberlist
    Optional:    false
  metallb-excludel2:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      metallb-excludel2
    Optional:  false
  kube-api-access-ckdld:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              kubernetes.io/os=linux
Tolerations:                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                             node-role.kubernetes.io/master:NoSchedule op=Exists
                             node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/network-unavailable:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  4m4s   default-scheduler  Successfully assigned metallb-system/speaker-dv8x5 to k3s-worker1.sece.com
  Normal  Pulling    4m4s   kubelet            spec.containers{speaker}: Pulling image "quay.io/metallb/speaker:v0.15.3"
  Normal  Pulled     3m29s  kubelet            spec.containers{speaker}: Successfully pulled image "quay.io/metallb/speaker:v0.15.3" in 35.226s (35.226s including waiting). Image size: 51445238 bytes.
  Normal  Created    3m29s  kubelet            spec.containers{speaker}: Container created
  Normal  Started    3m29s  kubelet            spec.containers{speaker}: Container started
root@k3s-master:~# kubectl get po
NAME                                READY   STATUS    RESTARTS        AGE
nginx-daemonset-ffvld               1/1     Running   4 (9m34s ago)   46h
nginx-daemonset-mtkcm               1/1     Running   4 (9m31s ago)   46h
nginx-daemonset-s7qjj               1/1     Running   4 (9m47s ago)   46h
nginx-deployment-55566ff79b-7ccnl   1/1     Running   3 (9m31s ago)   168m
nginx-deployment-55566ff79b-gwdp2   1/1     Running   3 (9m31s ago)   168m
nginx-deployment-55566ff79b-jdg89   1/1     Running   3 (9m31s ago)   168m
nginx-deployment-55566ff79b-v2btq   1/1     Running   3 (9m31s ago)   168m
nginx-deployment-55566ff79b-z6d9n   1/1     Running   3 (9m31s ago)   168m
root@k3s-master:~# kubectl get po -n metallb-system
NAME                                     READY   STATUS    RESTARTS   AGE
controller-66bdd896c6-82xfx              1/1     Running   0          6m
frr-k8s-daemon-gd4jw                     5/5     Running   0          22m
frr-k8s-daemon-gf9bw                     5/5     Running   0          22m
frr-k8s-daemon-m5j6q                     5/5     Running   0          22m
frr-k8s-statuscleaner-58d8956cbd-krxbl   1/1     Running   0          22m
speaker-7rd2c                            1/1     Running   0          3m51s
speaker-94tqc                            1/1     Running   0          5m23s
speaker-dv8x5                            1/1     Running   0          4m40s
root@k3s-master:~# kubectl get po -n metallb-system -o wide
NAME                                     READY   STATUS    RESTARTS   AGE     IP               NODE                   NOMINATED NODE   READINESS GATES
controller-66bdd896c6-82xfx              1/1     Running   0          7m33s   10.42.2.98       k3s-worker1.sece.com   <none>           <none>
frr-k8s-daemon-gd4jw                     5/5     Running   0          24m     192.168.142.13   k3s-worker2.sece.com   <none>           <none>
frr-k8s-daemon-gf9bw                     5/5     Running   0          24m     192.168.142.12   k3s-worker1.sece.com   <none>           <none>
frr-k8s-daemon-m5j6q                     5/5     Running   0          24m     192.168.142.11   k3s-master.sece.com    <none>           <none>
frr-k8s-statuscleaner-58d8956cbd-krxbl   1/1     Running   0          24m     192.168.142.12   k3s-worker1.sece.com   <none>           <none>
speaker-7rd2c                            1/1     Running   0          5m24s   192.168.142.13   k3s-worker2.sece.com   <none>           <none>
speaker-94tqc                            1/1     Running   0          6m56s   192.168.142.11   k3s-master.sece.com    <none>           <none>
speaker-dv8x5                            1/1     Running   0          6m13s   192.168.142.12   k3s-worker1.sece.com   <none>           <none>
root@k3s-master:~# vi ippool.yaml
root@k3s-master:~# kubectl apply -f ippool.yaml
ipaddresspool.metallb.io/first-pool created
root@k3s-master:~# vi l2ad.yaml
root@k3s-master:~# kubectl create -f l2ad.yaml
l2advertisement.metallb.io/example created
root@k3s-master:~# ubectl get l2advertisement -n metallb-system
Command 'ubectl' not found, did you mean:
  command 'kubectl' from snap kubectl (1.35.5)
  command 'usectl' from snap usectl (1.1.3)
See 'snap info <snapname>' for additional versions.
root@k3s-master:~# kubectl get l2advertisement -n metallb-system
NAME      IPADDRESSPOOLS   IPADDRESSPOOL SELECTORS   INTERFACES
example
root@k3s-master:~# kubectl get ipaddresspool -n metallb-system
NAME         AUTO ASSIGN   AVOID BUGGY IPS   ADDRESSES
first-pool   true          false             ["192.168.142.240-192.168.142.250"]
root@k3s-master:~# kubectl get l2advertisement -n metallb-system
NAME      IPADDRESSPOOLS   IPADDRESSPOOL SELECTORS   INTERFACES
example
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
      app: arun
  template:
    metadata:
      labels:
        app: arun
    spec:
      nodeSelector:
        env: test
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~# kubectl create -f nginx-deployment.yaml
The Deployment "httpd-deployment" is invalid: spec.template.metadata.labels: Invalid value: {"app":"httpd"}: `selector` does not match template `labels`
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~# kubectl create -f nginx-deployment.yaml
The Deployment "httpd-deployment" is invalid: spec.template.metadata.labels: Invalid value: {"app":"httpd"}: `selector` does not match template `labels`
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~# kubectl create -f nginx-deployment.yaml
deployment.apps/httpd-deployment created
root@k3s-master:~# kubectl get po
NAME                                READY   STATUS              RESTARTS      AGE
httpd-deployment-666fd568bb-5r5nf   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-cl9cp   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-hspz8   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-jkp5b   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-kzdpj   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-qz94n   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-r5h9c   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-vhlgz   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-vsfwb   0/1     ContainerCreating   0             8s
httpd-deployment-666fd568bb-xngqn   0/1     ContainerCreating   0             8s
nginx-daemonset-ffvld               1/1     Running             4 (25m ago)   46h
nginx-daemonset-mtkcm               1/1     Running             4 (25m ago)   46h
nginx-daemonset-s7qjj               1/1     Running             4 (25m ago)   46h
nginx-deployment-55566ff79b-7ccnl   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-gwdp2   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-jdg89   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-v2btq   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-z6d9n   1/1     Running             3 (25m ago)   3h4m
root@k3s-master:~# kubectl get po -w
NAME                                READY   STATUS              RESTARTS      AGE
httpd-deployment-666fd568bb-5r5nf   0/1     ContainerCreating   0             29s
httpd-deployment-666fd568bb-cl9cp   0/1     ContainerCreating   0             29s
httpd-deployment-666fd568bb-hspz8   0/1     ContainerCreating   0             29s
httpd-deployment-666fd568bb-jkp5b   0/1     ContainerCreating   0             29s
httpd-deployment-666fd568bb-kzdpj   0/1     ContainerCreating   0             29s
httpd-deployment-666fd568bb-qz94n   1/1     Running             0             29s
httpd-deployment-666fd568bb-r5h9c   0/1     ContainerCreating   0             29s
httpd-deployment-666fd568bb-vhlgz   1/1     Running             0             29s
httpd-deployment-666fd568bb-vsfwb   0/1     ContainerCreating   0             29s
httpd-deployment-666fd568bb-xngqn   1/1     Running             0             29s
nginx-daemonset-ffvld               1/1     Running             4 (25m ago)   46h
nginx-daemonset-mtkcm               1/1     Running             4 (25m ago)   46h
nginx-daemonset-s7qjj               1/1     Running             4 (26m ago)   46h
nginx-deployment-55566ff79b-7ccnl   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-gwdp2   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-jdg89   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-v2btq   1/1     Running             3 (25m ago)   3h4m
nginx-deployment-55566ff79b-z6d9n   1/1     Running             3 (25m ago)   3h4m
httpd-deployment-666fd568bb-vsfwb   1/1     Running             0             31s
httpd-deployment-666fd568bb-jkp5b   1/1     Running             0             31s
httpd-deployment-666fd568bb-r5h9c   1/1     Running             0             31s
httpd-deployment-666fd568bb-5r5nf   1/1     Running             0             34s
httpd-deployment-666fd568bb-hspz8   1/1     Running             0             34s
httpd-deployment-666fd568bb-cl9cp   1/1     Running             0             34s
httpd-deployment-666fd568bb-kzdpj   1/1     Running             0             34s
^Croot@k3s-master:~# kubectl get po --show -label
error: unknown flag: --show
See 'kubectl get --help' for usage.
root@k3s-master:~# kubectl get po --show -labels
error: unknown flag: --show
See 'kubectl get --help' for usage.
root@k3s-master:~# kubectl get po --show-labels
NAME                                READY   STATUS    RESTARTS      AGE     LABELS
httpd-deployment-666fd568bb-5r5nf   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-cl9cp   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-hspz8   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-jkp5b   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-kzdpj   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-qz94n   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-r5h9c   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-vhlgz   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-vsfwb   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
httpd-deployment-666fd568bb-xngqn   1/1     Running   0             2m18s   app=httpd,pod-template-hash=666fd568bb
nginx-daemonset-ffvld               1/1     Running   4 (27m ago)   46h     app=nginx-app,controller-revision-hash=74b7cd9f45,pod-template-generation=2
nginx-daemonset-mtkcm               1/1     Running   4 (27m ago)   46h     app=nginx-app,controller-revision-hash=74b7cd9f45,pod-template-generation=2
nginx-daemonset-s7qjj               1/1     Running   4 (28m ago)   46h     app=nginx-app,controller-revision-hash=74b7cd9f45,pod-template-generation=2
nginx-deployment-55566ff79b-7ccnl   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
nginx-deployment-55566ff79b-gwdp2   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
nginx-deployment-55566ff79b-jdg89   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
nginx-deployment-55566ff79b-v2btq   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
nginx-deployment-55566ff79b-z6d9n   1/1     Running   3 (27m ago)   3h6m    app=arun,pod-template-hash=55566ff79b
root@k3s-master:~# vi httpd-svc.yaml
root@k3s-master:~# kubectl apply -f httpd-svc.yaml
service/httpd-service created
root@k3s-master:~# kubectl get svc httpd-svc.yaml
Error from server (NotFound): services "httpd-svc.yaml" not found
root@k3s-master:~# kubectl get svc httpd-svc
Error from server (NotFound): services "httpd-svc" not found
root@k3s-master:~# kubectl get svc
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
httpd-service               LoadBalancer   10.43.153.1     192.168.142.241   80:30149/TCP   25s
kubernetes                  ClusterIP      10.43.0.1       <none>            443/TCP        4d19h
nginx-nodeport-custom-svc   NodePort       10.43.149.14    <none>            80:31010/TCP   11h
nginx-nodeport-svc          NodePort       10.43.218.6     <none>            80:31927/TCP   11h
nginx-svc                   ClusterIP      10.43.241.254   <none>            80/TCP         11h
root@k3s-master:~# kubectl get enfpoints
error: the server doesn't have a resource type "enfpoints"
root@k3s-master:~# kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                        ENDPOINTS                                                  AGE
httpd-service               10.42.0.102:80,10.42.0.103:80,10.42.0.104:80 + 7 more...   44s
kubernetes                  192.168.142.11:6443                                        4d19h
nginx-nodeport-custom-svc   10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-nodeport-svc          10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-svc                   <none>                                                     11h
root@k3s-master:~# kubectl get po
NAME                                READY   STATUS    RESTARTS      AGE
httpd-deployment-666fd568bb-5r5nf   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-cl9cp   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-hspz8   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-jkp5b   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-kzdpj   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-qz94n   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-r5h9c   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-vhlgz   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-vsfwb   1/1     Running   0             7m50s
httpd-deployment-666fd568bb-xngqn   1/1     Running   0             7m50s
nginx-daemonset-ffvld               1/1     Running   4 (33m ago)   46h
nginx-daemonset-mtkcm               1/1     Running   4 (33m ago)   46h
nginx-daemonset-s7qjj               1/1     Running   4 (33m ago)   46h
nginx-deployment-55566ff79b-7ccnl   1/1     Running   3 (33m ago)   3h12m
nginx-deployment-55566ff79b-gwdp2   1/1     Running   3 (33m ago)   3h12m
nginx-deployment-55566ff79b-jdg89   1/1     Running   3 (33m ago)   3h12m
nginx-deployment-55566ff79b-v2btq   1/1     Running   3 (33m ago)   3h12m
nginx-deployment-55566ff79b-z6d9n   1/1     Running   3 (33m ago)   3h12m
root@k3s-master:~# vi httpd-svc.yaml
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# vi php-deployment.yaml

[1]+  Stopped                 vi php-deployment.yaml
root@k3s-master:~# vi php-deployment.yaml
root@k3s-master:~# vi php-deployment.yaml

[2]+  Stopped                 vi php-deployment.yaml
root@k3s-master:~# vi php-deployment.yaml
root@k3s-master:~# kubectl apply -f php-svc.yaml
error: the path "php-svc.yaml" does not exist
root@k3s-master:~# kubectl apply -f phpmyadmin-svc.yaml
error: the path "phpmyadmin-svc.yaml" does not exist
root@k3s-master:~# kubectl apply -f phpmy-svc.yaml
error: error validating "phpmy-svc.yaml": error validating data: apiVersion not set; if you choose to ignore these errors, turn validation off with --validate=false
root@k3s-master:~# kubectl get svvc
error: the server doesn't have a resource type "svvc"
root@k3s-master:~# kubectl get svc
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
httpd-service               LoadBalancer   10.43.153.1     192.168.142.241   80:30149/TCP   12m
kubernetes                  ClusterIP      10.43.0.1       <none>            443/TCP        4d19h
nginx-nodeport-custom-svc   NodePort       10.43.149.14    <none>            80:31010/TCP   11h
nginx-nodeport-svc          NodePort       10.43.218.6     <none>            80:31927/TCP   11h
nginx-svc                   ClusterIP      10.43.241.254   <none>            80/TCP         12h
root@k3s-master:~# kubectl apply -f phpmy-svc.yaml
error: error validating "phpmy-svc.yaml": error validating data: apiVersion not set; if you choose to ignore these errors, turn validation off with --validate=false
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# kubectl apply -f phpmy-svc.yaml
error: error validating "phpmy-svc.yaml": error validating data: apiVersion not set; if you choose to ignore these errors, turn validation off with --validate=false
root@k3s-master:~# cat php-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpmyadmin-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: phpmyadmin
  template:
    metadata:
      labels:
        app: phpmyadmin
    spec:
      containers:
      - name: phpmyadmin
        image: phpmyadmin/phpmyadmin
        ports:
        - containerPort: 80
root@k3s-master:~# vi phpmy-svc.yaml

[3]+  Stopped                 vi phpmy-svc.yaml
root@k3s-master:~# cat php-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpmyadmin-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: phpmyadmin
  template:
    metadata:
      labels:
        app: phpmyadmin
    spec:
      containers:
      - name: phpmyadmin
        image: phpmyadmin/phpmyadmin
        ports:
        - containerPort: 80
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# cat phpmy-svc.yaml
apiVerison: v1
kind: service
metadata:
  name: php-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
  selector:
    app: phpmyadmin
root@k3s-master:~# kubectl apply -f phpmy-svc.yaml
error: error validating "phpmy-svc.yaml": error validating data: apiVersion not set; if you choose to ignore these errors, turn validation off with --validate=false
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# cat phpmy-svc.yaml
apiVerison: v1
kind: service
metadata:
  name: php-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
  selector:
    app: phpmyadmin
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# kubectl apply -f phpmy-svc.yaml
error: error validating "phpmy-svc.yaml": error validating data: apiVersion not set; if you choose to ignore these errors, turn validation off with --validate=false
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# kubectl apply -f phpmy-svc.yaml
Error from server (BadRequest): error when creating "phpmy-svc.yaml": service in version "v1" cannot be handled as a Service: no kind "service" is registered for version "v1" in scheme "k8s.io/apimachinery@v1.35.5-k3s1/pkg/runtime/scheme.go:111"
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# kubectl apply -f phpmy-svc.yaml
Error from server (BadRequest): error when creating "phpmy-svc.yaml": service in version "v1" cannot be handled as a Service: no kind "service" is registered for version "v1" in scheme "k8s.io/apimachinery@v1.35.5-k3s1/pkg/runtime/scheme.go:111"
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# kubectl apply -f phpmy-svc.yaml
service/php-service created
root@k3s-master:~# cat php-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpmyadmin-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: phpmyadmin
  template:
    metadata:
      labels:
        app: phpmyadmin
    spec:
      containers:
      - name: phpmyadmin
        image: phpmyadmin/phpmyadmin
        ports:
        - containerPort: 80
root@k3s-master:~# kubectl apply -f php-deployment.yaml
deployment.apps/phpmyadmin-deployment configured
root@k3s-master:~# cat php-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpmyadmin-deployment
spec:
  strategy:
    type: RollingUpdate
  replicas: 10
  selector:
    matchLabels:
      app: phpmyadmin
  template:
    metadata:
      labels:
        app: phpmyadmin
    spec:
      containers:
      - name: phpmyadmin
        image: phpmyadmin/phpmyadmin
        ports:
        - containerPort: 80
root@k3s-master:~# kubectl get svc
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
httpd-service               LoadBalancer   10.43.153.1     192.168.142.241   80:30149/TCP   23m
kubernetes                  ClusterIP      10.43.0.1       <none>            443/TCP        4d19h
nginx-nodeport-custom-svc   NodePort       10.43.149.14    <none>            80:31010/TCP   11h
nginx-nodeport-svc          NodePort       10.43.218.6     <none>            80:31927/TCP   11h
nginx-svc                   ClusterIP      10.43.241.254   <none>            80/TCP         12h
php-service                 LoadBalancer   10.43.119.79    192.168.142.242   80:30094/TCP   3m26s
root@k3s-master:~# kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                        ENDPOINTS                                                  AGE
httpd-service               10.42.0.102:80,10.42.0.103:80,10.42.0.104:80 + 7 more...   23m
kubernetes                  192.168.142.11:6443                                        4d19h
nginx-nodeport-custom-svc   10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-nodeport-svc          10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-svc                   <none>                                                     12h
php-service                                                                            3m41s
root@k3s-master:~# ^C
root@k3s-master:~# vi php-svc.yaml

[4]+  Stopped                 vi php-svc.yaml
root@k3s-master:~# vi phpmy-svc.yaml
root@k3s-master:~# vi php-svc.yaml
root@k3s-master:~# vi php-svc.yaml
root@k3s-master:~# vi php-svc1.yaml
root@k3s-master:~# vi php-svc1.yaml
root@k3s-master:~# vi php-deploy.yaml
root@k3s-master:~# kubectl apply -f p
php-deployment.yaml  php-deploy.yaml      phpmy-svc.yaml       php-svc1.yaml        php-svc.yaml         pod.yaml
root@k3s-master:~# kubectl apply -f php-svc1.yaml
service/php-service unchanged
root@k3s-master:~# kubectl apply -f php-deploy.yaml
deployment.apps/phpmyadmin-deployment configured
root@k3s-master:~# kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                        ENDPOINTS                                                  AGE
httpd-service               10.42.0.102:80,10.42.0.103:80,10.42.0.104:80 + 7 more...   30m
kubernetes                  192.168.142.11:6443                                        4d19h
nginx-nodeport-custom-svc   10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-nodeport-svc          10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-svc                   <none>                                                     12h
php-service                                                                            10m
root@k3s-master:~# vi php-svc1.yaml
root@k3s-master:~# vi phpmysvc.yaml
root@k3s-master:~# kubectl apply -f phpmysvc.yaml
service/php-service unchanged
root@k3s-master:~# ^C
root@k3s-master:~#
root@k3s-master:~# kubectl get po -o wide
NAME                                     READY   STATUS    RESTARTS      AGE     IP            NODE                   NOMINATED NODE   READINESS GATES
httpd-deployment-666fd568bb-5r5nf        1/1     Running   0             48m     10.42.2.99    k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-cl9cp        1/1     Running   0             48m     10.42.2.102   k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-hspz8        1/1     Running   0             48m     10.42.2.101   k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-jkp5b        1/1     Running   0             48m     10.42.0.102   k3s-master.sece.com    <none>           <none>
httpd-deployment-666fd568bb-kzdpj        1/1     Running   0             48m     10.42.2.100   k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-qz94n        1/1     Running   0             48m     10.42.1.128   k3s-worker2.sece.com   <none>           <none>
httpd-deployment-666fd568bb-r5h9c        1/1     Running   0             48m     10.42.0.104   k3s-master.sece.com    <none>           <none>
httpd-deployment-666fd568bb-vhlgz        1/1     Running   0             48m     10.42.1.130   k3s-worker2.sece.com   <none>           <none>
httpd-deployment-666fd568bb-vsfwb        1/1     Running   0             48m     10.42.0.103   k3s-master.sece.com    <none>           <none>
httpd-deployment-666fd568bb-xngqn        1/1     Running   0             48m     10.42.1.129   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-ffvld                    1/1     Running   4 (74m ago)   47h     10.42.2.97    k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm                    1/1     Running   4 (74m ago)   47h     10.42.1.123   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj                    1/1     Running   4 (74m ago)   47h     10.42.0.99    k3s-master.sece.com    <none>           <none>
nginx-deployment-55566ff79b-7ccnl        1/1     Running   3 (74m ago)   3h53m   10.42.1.124   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-55566ff79b-gwdp2        1/1     Running   3 (74m ago)   3h53m   10.42.1.125   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-55566ff79b-jdg89        1/1     Running   3 (74m ago)   3h53m   10.42.1.121   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-55566ff79b-v2btq        1/1     Running   3 (74m ago)   3h53m   10.42.1.122   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-55566ff79b-z6d9n        1/1     Running   3 (74m ago)   3h53m   10.42.1.127   k3s-worker2.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-69gmj   1/1     Running   0             28m     10.42.2.104   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-78bxs   1/1     Running   0             28m     10.42.1.133   k3s-worker2.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-847f9   1/1     Running   0             28m     10.42.2.106   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-88cc6   1/1     Running   0             28m     10.42.1.131   k3s-worker2.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-jh2lj   1/1     Running   0             28m     10.42.2.103   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-l2j59   1/1     Running   0             28m     10.42.0.106   k3s-master.sece.com    <none>           <none>
phpmyadmin-deployment-6bfdf8478f-pqgrv   1/1     Running   0             28m     10.42.0.107   k3s-master.sece.com    <none>           <none>
phpmyadmin-deployment-6bfdf8478f-qcfm7   1/1     Running   0             28m     10.42.2.105   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-xf8cw   1/1     Running   0             28m     10.42.0.105   k3s-master.sece.com    <none>           <none>
phpmyadmin-deployment-6bfdf8478f-zg982   1/1     Running   0             28m     10.42.1.132   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                        ENDPOINTS                                                  AGE
httpd-service               10.42.0.102:80,10.42.0.103:80,10.42.0.104:80 + 7 more...   43m
kubernetes                  192.168.142.11:6443                                        4d20h
nginx-nodeport-custom-svc   10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   11h
nginx-nodeport-svc          10.42.1.121:80,10.42.1.122:80,10.42.1.124:80 + 2 more...   12h
nginx-svc                   <none>                                                     12h
php-service                 10.42.0.105:80,10.42.0.106:80,10.42.0.107:80 + 7 more...   24m
root@k3s-master:~#


