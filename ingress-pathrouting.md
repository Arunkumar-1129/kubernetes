# Kubernetes Ingress Path-Based Routing

## Objective

Configure an NGINX Ingress Controller to route requests based on URL paths.

---

## Prerequisites

- K3s Cluster
- NGINX Ingress Controller installed
- HTTPD Deployment and Service created
- Windows host machine for testing

---

## Step 1: Verify Ingress Resources

```bash
kubectl api-resources | grep ingress
```

### Output

```bash
ingressclasses        networking.k8s.io/v1
ingresses             networking.k8s.io/v1
ingressroutes         traefik.io/v1alpha1
ingressroutetcps      traefik.io/v1alpha1
ingressrouteudps      traefik.io/v1alpha1
```

---

## Step 2: Check Existing Ingress

```bash
kubectl get ing
```

### Output

```bash
No resources found in default namespace.
```

---

## Step 3: Verify Running Pods

```bash
kubectl get po -o wide
```

### Output

```bash
httpd-deploy-64569dfccf-9rzx6      Running
httpd-deploy-64569dfccf-rpm7w      Running
nginx-deploy-8b9dbd8c9-257tc       Running
nginx-deploy-8b9dbd8c9-s89zc       Running
phpmyadmin-deploy-*                Running
```

---

## Step 4: Create Ingress Manifest

### path-ing.yaml

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: web.arun.com
    http:
      paths:
      - path: /httpd
        pathType: Prefix
        backend:
          service:
            name: httpd-deploy-svc
            port:
              number: 80
```

---

## Step 5: Apply Ingress

```bash
kubectl apply -f path-ing.yaml
```

### Output

```bash
ingress.networking.k8s.io/path-based-ingress created
```

---

## Step 6: Verify Ingress

```bash
kubectl get ing -o wide
```

### Output

```bash
NAME                 CLASS   HOSTS          ADDRESS          PORTS
path-based-ingress   nginx   web.arun.com   192.168.142.12   80
```

---

## Step 7: Verify Ingress Controller

```bash
kubectl get all -n ingress-nginx
```

### Output

```bash
NAME
pod/ingress-nginx-controller-54569fb988-jtqpv

NAME
service/ingress-nginx-controller

TYPE
LoadBalancer

EXTERNAL-IP
192.168.142.243

PORTS
80:32331/TCP
443:30616/TCP
```

---

## Step 8: Verify Cluster Nodes

```bash
kubectl get node -o wide
```

### Output

```bash
k3s-master.sece.com    192.168.142.11
k3s-worker1.sece.com   192.168.142.12
k3s-worker2.sece.com   192.168.142.13
```

---

## Step 9: Configure DNS Mapping on Windows

Open Command Prompt as Administrator and run:

```cmd
echo 192.168.142.243 app.arun.in >> C:\Windows\System32\drivers\etc\hosts
```

For this lab:

```cmd
echo 192.168.142.243 web.arun.com >> C:\Windows\System32\drivers\etc\hosts
```

Verify:

```cmd
notepad C:\Windows\System32\drivers\etc\hosts
```

Entry should appear:

```text
192.168.142.243 web.arun.com
```

---

## Step 10: Test Ingress

### Without Path

```bash
curl web.arun.com
```

### Output

```html
404 Not Found
```

Reason:

The Ingress only defines the `/httpd` path.

---

### With Path

```bash
curl web.arun.com/httpd
```

### Output

```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
```

---

## Testing Using LoadBalancer IP

### Root URL

```bash
curl 192.168.142.243
```

### Output

```html
404 Not Found
```

### Path URL

```bash
curl 192.168.142.243/httpd
```

### Output

```html
404 Not Found
```

Reason:

Ingress routing depends on the Host header.

The rule is configured for:

```yaml
host: web.arun.com
```

Using only the IP address does not match the Ingress rule.

---

## Working Request Flow

```text
Browser
   |
   v
web.arun.com/httpd
   |
   v
Ingress Controller
   |
   v
httpd-deploy-svc
   |
   v
HTTPD Pods
```

---

## Verification Commands

```bash
kubectl get ing

kubectl get ing -o wide

kubectl get all -n ingress-nginx

kubectl get svc

kubectl get po -o wide

kubectl get node -o wide
```

---

## Result

Successfully configured Path-Based Routing using NGINX Ingress Controller.

URL:

http://web.arun.com/httpd

Response:

Apache HTTPD default page displayed successfully through the Ingress Controller.


```root@k3s-master:~# kubectl api-resources | grep ingress
ingressclasses                                   networking.k8s.io/v1                false        IngressClass
ingresses                           ing          networking.k8s.io/v1                true         Ingress
ingressroutes                                    traefik.io/v1alpha1                 true         IngressRoute
ingressroutetcps                                 traefik.io/v1alpha1                 true         IngressRouteTCP
ingressrouteudps                                 traefik.io/v1alpha1                 true         IngressRouteUDP
root@k3s-master:~#
root@k3s-master:~# kubectl get ing
No resources found in default namespace.
root@k3s-master:~# ls
apply            httpd-svc.yaml  nginx-deployment.yaml           nodeport-svc.yaml    php-deploy.yaml  php-svc1.yaml  pod.yaml
daemonset.yaml   ippool.yaml     nginx-nodeport-custom-svc.yaml  np-custom-svc.yaml   phpmy-svc.yaml   php-svc.yaml   service1.yaml
deployment.yaml  l2ad.yaml       nginx-rs.yaml                   php-deployment.yaml  phpmysvc.yaml    pod1.yaml      service.yaml
root@k3s-master:~# kubectl get po -o wide
NAME                                     READY   STATUS    RESTARTS      AGE     IP            NODE                   NOMINATED NODE   READINESS GATES
httpd-deploy-64569dfccf-9rzx6            1/1     Running   0             10h     10.42.0.113   k3s-master.sece.com    <none>           <none>
httpd-deploy-64569dfccf-rpm7w            1/1     Running   0             10h     10.42.2.109   k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-5r5nf        1/1     Running   0             13h     10.42.2.99    k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-cl9cp        1/1     Running   0             13h     10.42.2.102   k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-hspz8        1/1     Running   0             13h     10.42.2.101   k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-jkp5b        1/1     Running   0             13h     10.42.0.102   k3s-master.sece.com    <none>           <none>
httpd-deployment-666fd568bb-kzdpj        1/1     Running   0             13h     10.42.2.100   k3s-worker1.sece.com   <none>           <none>
httpd-deployment-666fd568bb-qz94n        1/1     Running   0             13h     10.42.1.128   k3s-worker2.sece.com   <none>           <none>
httpd-deployment-666fd568bb-r5h9c        1/1     Running   0             13h     10.42.0.104   k3s-master.sece.com    <none>           <none>
httpd-deployment-666fd568bb-vhlgz        1/1     Running   0             13h     10.42.1.130   k3s-worker2.sece.com   <none>           <none>
httpd-deployment-666fd568bb-vsfwb        1/1     Running   0             13h     10.42.0.103   k3s-master.sece.com    <none>           <none>
httpd-deployment-666fd568bb-xngqn        1/1     Running   0             13h     10.42.1.129   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-ffvld                    1/1     Running   4 (13h ago)   2d11h   10.42.2.97    k3s-worker1.sece.com   <none>           <none>
nginx-daemonset-mtkcm                    1/1     Running   4 (13h ago)   2d11h   10.42.1.123   k3s-worker2.sece.com   <none>           <none>
nginx-daemonset-s7qjj                    1/1     Running   4 (13h ago)   2d11h   10.42.0.99    k3s-master.sece.com    <none>           <none>
nginx-deploy-8b9dbd8c9-257tc             1/1     Running   0             10h     10.42.2.110   k3s-worker1.sece.com   <none>           <none>
nginx-deploy-8b9dbd8c9-s89zc             1/1     Running   0             10h     10.42.0.114   k3s-master.sece.com    <none>           <none>
nginx-deployment-55566ff79b-7ccnl        1/1     Running   3 (13h ago)   16h     10.42.1.124   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-55566ff79b-gwdp2        1/1     Running   3 (13h ago)   16h     10.42.1.125   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-55566ff79b-jdg89        1/1     Running   3 (13h ago)   16h     10.42.1.121   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-55566ff79b-v2btq        1/1     Running   3 (13h ago)   16h     10.42.1.122   k3s-worker2.sece.com   <none>           <none>
nginx-deployment-55566ff79b-z6d9n        1/1     Running   3 (13h ago)   16h     10.42.1.127   k3s-worker2.sece.com   <none>           <none>
nginx-pod                                1/1     Running   0             120m    10.42.1.134   k3s-worker2.sece.com   <none>           <none>
phpmyadmin-deploy-7c45dbf4dd-bdnf9       1/1     Running   0             10h     10.42.0.115   k3s-master.sece.com    <none>           <none>
phpmyadmin-deploy-7c45dbf4dd-mn95k       1/1     Running   0             10h     10.42.2.111   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-69gmj   1/1     Running   0             12h     10.42.2.104   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-78bxs   1/1     Running   0             12h     10.42.1.133   k3s-worker2.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-847f9   1/1     Running   0             12h     10.42.2.106   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-88cc6   1/1     Running   0             12h     10.42.1.131   k3s-worker2.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-jh2lj   1/1     Running   0             12h     10.42.2.103   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-l2j59   1/1     Running   0             12h     10.42.0.106   k3s-master.sece.com    <none>           <none>
phpmyadmin-deployment-6bfdf8478f-pqgrv   1/1     Running   0             12h     10.42.0.107   k3s-master.sece.com    <none>           <none>
phpmyadmin-deployment-6bfdf8478f-qcfm7   1/1     Running   0             12h     10.42.2.105   k3s-worker1.sece.com   <none>           <none>
phpmyadmin-deployment-6bfdf8478f-xf8cw   1/1     Running   0             12h     10.42.0.105   k3s-master.sece.com    <none>           <none>
phpmyadmin-deployment-6bfdf8478f-zg982   1/1     Running   0             12h     10.42.1.132   k3s-worker2.sece.com   <none>           <none>
root@k3s-master:~#
root@k3s-master:~# vi path-ing.yaml
root@k3s-master:~# kubectl apply -f path-ing.yaml
ingress.networking.k8s.io/path-based-ingress created
root@k3s-master:~# kubectl get ing -o wide
NAME                 CLASS   HOSTS          ADDRESS   PORTS   AGE
path-based-ingress   nginx   web.arun.com             80      8s
root@k3s-master:~# kubectl get all -n ingress-nginx
NAME                                            READY   STATUS    RESTARTS   AGE
pod/ingress-nginx-controller-54569fb988-jtqpv   1/1     Running   0          10h

NAME                                         TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                      AGE
service/ingress-nginx-controller             LoadBalancer   10.43.199.179   192.168.142.243   80:32331/TCP,443:30616/TCP   10h
service/ingress-nginx-controller-admission   ClusterIP      10.43.187.31    <none>            443/TCP                      10h

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           10h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-54569fb988   1         1         1       10h
root@k3s-master:~#
root@k3s-master:~# vi /etc/hosts
root@k3s-master:~#
root@k3s-master:~# kubectl get ing -o wide
NAME                 CLASS   HOSTS          ADDRESS          PORTS   AGE
path-based-ingress   nginx   web.arun.com   192.168.142.12   80      109s
root@k3s-master:~# kubectl get node -o wide
NAME                   STATUS   ROLES           AGE     VERSION        INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k3s-master.sece.com    Ready    control-plane   5d8h    v1.35.5+k3s1   192.168.142.11   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.3-k3s1
k3s-worker1.sece.com   Ready    <none>          4d      v1.35.5+k3s1   192.168.142.12   <none>        Ubuntu 24.04.4 LTS   6.8.0-124-generic   containerd://2.2.3-k3s1
k3s-worker2.sece.com   Ready    <none>          4d14h   v1.35.5+k3s1   192.168.142.13   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.3-k3s1
root@k3s-master:~#
root@k3s-master:~# curl web.arun.com
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
root@k3s-master:~# cat path-ing.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: "web.arun.com"
    http:
      paths:
      - path: /httpd
        pathType: Prefix
        backend:
          service:
            name: httpd-deploy-svc
            port:
              number: 80
root@k3s-master:~# curl web.arun.com/httpd
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# curl 192.168.142.243
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
root@k3s-master:~# curl 192.168.142.243/httpd
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
root@k3s-master:~# cat path-ing.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: "web.arun.com"
    http:
      paths:
      - path: /httpd
        pathType: Prefix
        backend:
          service:
            name: httpd-deploy-svc
            port:
              number: 80
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# kubectl get all -n ingress-nginx
NAME                                            READY   STATUS    RESTARTS   AGE
pod/ingress-nginx-controller-54569fb988-jtqpv   1/1     Running   0          11h

NAME                                         TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                      AGE
service/ingress-nginx-controller             LoadBalancer   10.43.199.179   192.168.142.243   80:32331/TCP,443:30616/TCP   11h
service/ingress-nginx-controller-admission   ClusterIP      10.43.187.31    <none>            443/TCP                      11h

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           11h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-54569fb988   1         1         1       11h
root@k3s-master:~#
root@k3s-master:~# kubectl get ing
NAME                 CLASS   HOSTS          ADDRESS          PORTS   AGE
path-based-ingress   nginx   web.arun.com   192.168.142.12   80      9m3s
root@k3s-master:~#
root@k3s-master:~#
root@k3s-master:~# curl web.arun.com
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
root@k3s-master:~# curl web.arun.com/httpd
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
root@k3s-master:~#
root@k3s-master:~#

