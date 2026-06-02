
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


