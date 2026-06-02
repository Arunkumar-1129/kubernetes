
vi daemonset.yaml


apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
  labels:
    app: nginx
    env: prod
spec:
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
        image: nginx:1.27
        ports:
        - containerPort: 80



kubectl apply -f daemonset.yaml
daemonset.apps/nginx-daemonset created
root@k3s-master:~# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS      AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
nginx-daemonset-678rl               1/1     Running   0             23s   10.42.1.50   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-nl9v8               1/1     Running   0             23s   10.42.2.53   k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-xr74t               1/1     Running   0             23s   10.42.0.68   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-2q9df   1/1     Running   1 (43m ago)   11h   10.42.1.46   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-4lfhk   1/1     Running   1 (43m ago)   11h   10.42.2.50   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-64vqq   1/1     Running   1 (43m ago)   11h   10.42.0.61   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-clzgq   1/1     Running   1 (43m ago)   11h   10.42.1.48   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-f8kt5   1/1     Running   1 (43m ago)   11h   10.42.2.52   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-g4nj9   1/1     Running   1 (43m ago)   11h   10.42.0.65   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-gff2q   1/1     Running   1 (43m ago)   11h   10.42.0.66   k3s-master.sece.com    <none>           <none>
nginx-deployment-86c8cd48f6-grhdx   1/1     Running   1 (43m ago)   11h   10.42.2.49   k3s-worker1.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-ngm7g   1/1     Running   1 (43m ago)   11h   10.42.1.49   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-86c8cd48f6-qpw5h   1/1     Running   1 (43m ago)   11h   10.42.2.51   k3s-worker1.sece.com   <none>           <none>
nginx-pod                           1/1     Running   1 (43m ago)   12h   10.42.1.47   k3s-worker2.sece.com   <none>           <none>


root@k3s-master:~# kubectl get ds
NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
nginx-daemonset   3         3         3       3            3           <none>          44s





Every 2.0s: kubectl get ds,po -o wide                                                                            k3s-master.sece.com: Tue Jun  2 04:32:00 2026

NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE     CONTAINERS        IMAGES       SELECTOR
daemonset.apps/nginx-daemonset   3         3         3       3            3           <none>          7m44s   nginx-container   nginx:1.27   app=nginx-app

NAME                                    READY   STATUS    RESTARTS      AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
pod/nginx-daemonset-678rl               1/1     Running   0             7m43s   10.42.1.50   k3s-worker2.sece.com   <none>           <none>
pod/nginx-daemonset-nl9v8               1/1     Running   0             7m43s   10.42.2.53   k3s-worker1.sece.com   <none>           <none>
pod/nginx-daemonset-xr74t               1/1     Running   0             7m43s   10.42.0.68   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-86c8cd48f6-2q9df   1/1     Running   1 (50m ago)   11h     10.42.1.46   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-4lfhk   1/1     Running   1 (50m ago)   11h     10.42.2.50   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-64vqq   1/1     Running   1 (51m ago)   11h     10.42.0.61   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-86c8cd48f6-clzgq   1/1     Running   1 (50m ago)   11h     10.42.1.48   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-f8kt5   1/1     Running   1 (50m ago)   11h     10.42.2.52   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-g4nj9   1/1     Running   1 (51m ago)   11h     10.42.0.65   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-86c8cd48f6-gff2q   1/1     Running   1 (51m ago)   11h     10.42.0.66   k3s-master.sece.com    <none>           <none>
pod/nginx-deployment-86c8cd48f6-grhdx   1/1     Running   1 (50m ago)   11h     10.42.2.49   k3s-worker1.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-ngm7g   1/1     Running   1 (50m ago)   11h     10.42.1.49   k3s-worker2.sece.com   <none>           <none>
pod/nginx-deployment-86c8cd48f6-qpw5h   1/1     Running   1 (50m ago)   11h     10.42.2.51   k3s-worker1.sece.com   <none>           <none>
pod/nginx-pod                           1/1     Running   1 (50m ago)   12h     10.42.1.47   k3s-worker2.sece.com   <none>           <none>



kubectl delete pod/nginx-daemonset-w2rxg


creating namespace in the name of dev

root@k3s-master:~# vi nginx-rs.yaml
root@k3s-master:~# kubectl create ns dev
namespace/dev created
root@k3s-master:~# kubectl apply -f nginx-rs.yaml
replicaset.apps/nginx-rs created
root@k3s-master:~# kubectl get rs -n dev
NAME       DESIRED   CURRENT   READY   AGE
nginx-rs   3         3         0       10s
root@k3s-master:~# kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS       AGE
default       nginx-daemonset-7t6qp                     1/1     Running     0              7m42s
default       nginx-daemonset-nl9v8                     1/1     Running     0              43m
default       nginx-daemonset-xr74t                     1/1     Running     0              43m
default       nginx-deployment-86c8cd48f6-2q9df         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-4lfhk         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-64vqq         1/1     Running     1 (87m ago)    11h
default       nginx-deployment-86c8cd48f6-clzgq         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-f8kt5         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-g4nj9         1/1     Running     1 (87m ago)    11h
default       nginx-deployment-86c8cd48f6-gff2q         1/1     Running     1 (87m ago)    11h
default       nginx-deployment-86c8cd48f6-grhdx         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-ngm7g         1/1     Running     1 (86m ago)    11h
default       nginx-deployment-86c8cd48f6-qpw5h         1/1     Running     1 (86m ago)    11h
default       nginx-pod                                 1/1     Running     1 (86m ago)    12h
dev           nginx-rs-n5852                            1/1     Running     0              51s
dev           nginx-rs-qp66w                            1/1     Running     0              51s
dev           nginx-rs-zv9h6                            1/1     Running     0              51s
kube-system   coredns-8db54c48d-v6ck2                   1/1     Running     4 (87m ago)    2d19h
kube-system   helm-install-traefik-crd-rhl5l            0/1     Completed   0              2d19h
kube-system   helm-install-traefik-hgnt2                0/1     Completed   2              2d19h
kube-system   local-path-provisioner-5d9d9885bc-d9ws6   1/1     Running     4 (87m ago)    2d19h
kube-system   metrics-server-786d997795-mljbj           1/1     Running     4 (87m ago)    2d19h
kube-system   svclb-traefik-56ac0f3b-7pm7z              2/2     Running     8 (87m ago)    2d19h
kube-system   svclb-traefik-56ac0f3b-gz5x8              2/2     Running     6 (86m ago)    35h
kube-system   svclb-traefik-56ac0f3b-jt47t              2/2     Running     10 (86m ago)   2d1h
kube-system   traefik-9bcdbbd9-ztprx                    1/1     Running     4 (87m ago)    2d19h
root@k3s-master:~# kubectl get pods
NAME                                READY   STATUS    RESTARTS      AGE
nginx-daemonset-7t6qp               1/1     Running   0             8m37s
nginx-daemonset-nl9v8               1/1     Running   0             44m
nginx-daemonset-xr74t               1/1     Running   0             44m
nginx-deployment-86c8cd48f6-2q9df   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-4lfhk   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-64vqq   1/1     Running   1 (88m ago)   11h
nginx-deployment-86c8cd48f6-clzgq   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-f8kt5   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-g4nj9   1/1     Running   1 (88m ago)   11h
nginx-deployment-86c8cd48f6-gff2q   1/1     Running   1 (88m ago)   11h
nginx-deployment-86c8cd48f6-grhdx   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-ngm7g   1/1     Running   1 (87m ago)   11h
nginx-deployment-86c8cd48f6-qpw5h   1/1     Running   1 (87m ago)   11h
nginx-pod                           1/1     Running   1 (87m ago)   12h
root@k3s-master:~# kubectl get pod -n dev
NAME             READY   STATUS    RESTARTS   AGE
nginx-rs-n5852   1/1     Running   0          2m14s
nginx-rs-qp66w   1/1     Running   0          2m14s
nginx-rs-zv9h6   1/1     Running   0          2m14s

