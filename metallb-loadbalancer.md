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
