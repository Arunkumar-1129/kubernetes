Last login: Tue Jun  2 06:29:59 2026 from 192.168.142.1
arun@k3s-master:~$ sudo -i
[sudo] password for arun:
root@k3s-master:~# vi deployment.yaml
root@k3s-master:~# kubectl get node --sho
error: unknown flag: --sho
See 'kubectl get --help' for usage.
root@k3s-master:~# kubectl get node --labels
error: unknown flag: --labels
See 'kubectl get --help' for usage.
root@k3s-master:~# kubectl get node --show labels
error: unknown flag: --show
See 'kubectl get --help' for usage.
root@k3s-master:~# kubectl apply -f deployment.yaml
deployment.apps/deployment configured
root@k3s-master:~# kubectl get nodes
NAME                   STATUS   ROLES           AGE     VERSION
k3s-master.sece.com    Ready    control-plane   2d23h   v1.35.5+k3s1
k3s-worker1.sece.com   Ready    <none>          39h     v1.35.5+k3s1
k3s-worker2.sece.com   Ready    <none>          2d5h    v1.35.5+k3s1
root@k3s-master:~# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS        AGE    IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-ffvld               1/1     Running   0               162m   10.42.2.55   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm               1/1     Running   0               162m   10.42.1.54   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj               1/1     Running   0               162m   10.42.0.70   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-2q9df   1/1     Running   1 (5h33m ago)   16h    10.42.1.46   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-4lfhk   1/1     Running   1 (5h33m ago)   16h    10.42.2.50   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-64vqq   1/1     Running   1 (5h33m ago)   16h    10.42.0.61   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-clzgq   1/1     Running   1 (5h33m ago)   16h    10.42.1.48   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-f8kt5   1/1     Running   1 (5h33m ago)   16h    10.42.2.52   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-g4nj9   1/1     Running   1 (5h33m ago)   16h    10.42.0.65   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-gff2q   1/1     Running   1 (5h33m ago)   16h    10.42.0.66   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-grhdx   1/1     Running   1 (5h33m ago)   16h    10.42.2.49   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-ngm7g   1/1     Running   1 (5h33m ago)   16h    10.42.1.49   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-qpw5h   1/1     Running   1 (5h33m ago)   16h    10.42.2.51   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   1 (5h33m ago)   16h    10.42.1.47   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~#
root@k3s-master:~# cat deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
  namespace: dev
  labels:
    app: nginx
    env: prod
spec:
  strategy:
    type: Recreate
  replicas: 3
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      nodeName:  k3s-worker1
      containers:
      - name: nginx-container
        image: nginx:1.26
        ports:
        - containerPort: 80
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
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.29
        ports:
        - containerPort: 80
root@k3s-master:~# vi deployment.yaml
root@k3s-master:~# kubectl apply -f deployment.yaml
deployment.apps/deployment configured
root@k3s-master:~# kubectl get nodes
NAME                   STATUS   ROLES           AGE    VERSION
k3s-master.sece.com    Ready    control-plane   3d     v1.35.5+k3s1
k3s-worker1.sece.com   Ready    <none>          39h    v1.35.5+k3s1
k3s-worker2.sece.com   Ready    <none>          2d6h   v1.35.5+k3s1
root@k3s-master:~# kubectl label node k3s-worker1.sece.com env=test
node/k3s-worker1.sece.com labeled
root@k3s-master:~# kubectl get nodes --show-labels
NAME                   STATUS   ROLES           AGE    VERSION        LABELS
k3s-master.sece.com    Ready    control-plane   3d     v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-master.sece.com,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node.kubernetes.io/instance-type=k3s
k3s-worker1.sece.com   Ready    <none>          39h    v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,env=test,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker1.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
k3s-worker2.sece.com   Ready    <none>          2d6h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker2.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl delete deployment.apps/deployment
Error from server (NotFound): deployments.apps "deployment" not found
root@k3s-master:~#
root@k3s-master:~# kubectl get deploy
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   10/10   10           10          29h
root@k3s-master:~# vi nginx-deployment.yaml
root@k3s-master:~#
root@k3s-master:~# kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment configured
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl get deploy,rs,po -o wide
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES       SELECTOR
deployment.apps/nginx-deployment   10/10   10           10          29h   nginx        nginx:1.29   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES       SELECTOR
replicaset.apps/nginx-deployment-569f95f5cb   0         0         0       29h   nginx        nginx:1.25   app=nginx,pod-template-hash=569f95f5cb
replicaset.apps/nginx-deployment-5d8dbff9fb   10        10        10      10s   nginx        nginx:1.29   app=nginx,pod-template-hash=5d8dbff9fb
replicaset.apps/nginx-deployment-65dfbbb4d7   0         0         0       17h   nginx        nginx:1.28   app=nginx,pod-template-hash=65dfbbb4d7
replicaset.apps/nginx-deployment-8574879789   0         0         0       28h   nginx        nginx:1.26   app=nginx,pod-template-hash=8574879789
replicaset.apps/nginx-deployment-86c8cd48f6   0         0         0       16h   nginx        nginx:1.29   app=nginx,pod-template-hash=86c8cd48f6
replicaset.apps/nginx-deployment-fd956d49d    0         0         0       23h   nginx        nginx:1.27   app=nginx,pod-template-hash=fd956d49d

NAME                                    READY   STATUS    RESTARTS     AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-daemonset-ffvld               1/1     Running   0            3h10m   10.42.2.55   k3s-worker1.sece.com   <none>           <none>
pod/nginx-daemonset-mtkcm               1/1     Running   0            3h10m   10.42.1.54   k3s-worker2.sece.com   <none>           <none>
pod/nginx-daemonset-s7qjj               1/1     Running   0            3h10m   10.42.0.70   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-5d8dbff9fb-75d59   1/1     Running   0            10s     10.42.2.67   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-dmlff   1/1     Running   0            10s     10.42.2.63   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-jzhl8   1/1     Running   0            10s     10.42.2.66   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-mk4sc   1/1     Running   0            6s      10.42.2.72   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-ntxcn   1/1     Running   0            6s      10.42.2.71   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-qbp46   1/1     Running   0            6s      10.42.2.69   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-s2tvv   1/1     Running   0            6s      10.42.2.70   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-tfqdd   1/1     Running   0            10s     10.42.2.64   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-vkfxn   1/1     Running   0            7s      10.42.2.68   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-5d8dbff9fb-zr2z5   1/1     Running   0            10s     10.42.2.65   k3s-worker1.sece.com   <none>           <none>
pod/nginx-pod                           1/1     Running   1 (6h ago)   17h     10.42.1.47   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~# kubectl get nodes --show-labels
NAME                   STATUS   ROLES           AGE    VERSION        LABELS
k3s-master.sece.com    Ready    control-plane   3d     v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-master.sece.com,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node.kubernetes.io/instance-type=k3s
k3s-worker1.sece.com   Ready    <none>          39h    v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,env=test,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker1.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
k3s-worker2.sece.com   Ready    <none>          2d6h   v1.35.5+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3s-worker2.sece.com,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
root@k3s-master:~#
