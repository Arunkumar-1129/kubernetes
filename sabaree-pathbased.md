Below is a professional **GitHub README.md** for your **Kubernetes Ingress (Path-Based Routing) Lab** based on the commands and outputs from your session, including the DNS/hosts file configuration. Sources:  and 

---

# Kubernetes Ingress - Path Based Routing Lab

## Objective

Configure Kubernetes Ingress using NGINX Ingress Controller to route traffic based on URL paths.

### Routing Rules

| URL                         | Backend Service |
| --------------------------- | --------------- |
| `http://sebarees.com/nginx` | nginx-service   |
| `http://sebarees.com/php`   | php-service     |

---

# Lab Environment

| Component               | Value                    |
| ----------------------- | ------------------------ |
| Kubernetes Distribution | K3s                      |
| Ingress Controller      | NGINX Ingress Controller |
| LoadBalancer            | MetalLB                  |
| Master Node             | 192.168.218.129          |
| Worker Node 1           | 192.168.218.130          |
| Worker Node 2           | 192.168.218.131          |
| Ingress External IP     | 192.168.218.242          |

---

# Step 1: Clean Existing Resources

## Delete All Deployments

```bash
kubectl delete deploy --all
```

### Output

```bash
deployment.apps "httpd" deleted
deployment.apps "httpd-deploy" deleted
deployment.apps "nginx" deleted
deployment.apps "nginx-deploy" deleted
deployment.apps "nginx-deployment" deleted
deployment.apps "php" deleted
deployment.apps "phpmyadmin-deploy" deleted
```

---

## Delete All DaemonSets

```bash
kubectl delete ds --all
```

### Output

```bash
daemonset.apps "nginx-daemonset" deleted
```

---

## Delete All Services

```bash
kubectl delete svc --all
```

### Output

```bash
service "httpd" deleted
service "httpd-deploy-svc" deleted
service "kubernetes" deleted
service "nginx" deleted
service "nginx-deploy-svc" deleted
service "nginx-nodeport" deleted
service "nginx-service" deleted
service "php-service" deleted
service "phpmyadmin-deploy-svc" deleted
```

---

## Delete Standalone Pods

```bash
kubectl delete po nginx-pod nginx-pod2
```

### Output

```bash
pod "nginx-pod" deleted
pod "nginx-pod2" deleted
```

---

# Step 2: Verify Cluster Status

```bash
kubectl get all
```

### Output

```bash
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)
service/kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP
```

---

# Step 3: Create NGINX Deployment

## nginx-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      nodeSelector:
        name: sabaree

      containers:
      - name: nginx
        image: nginx:1.25

        ports:
        - containerPort: 80
```

Apply deployment:

```bash
kubectl create -f nginx-deployment.yaml
```

### Output

```bash
deployment.apps/nginx-deployment created
```

---

# Step 4: Create PHP Deployment

## php-deploy.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php

spec:
  replicas: 3

  selector:
    matchLabels:
      app: php

  template:
    metadata:
      labels:
        app: php

    spec:
      containers:
      - name: php
        image: phpmyadmin/phpmyadmin

        ports:
        - containerPort: 80
```

Apply deployment:

```bash
kubectl create -f php-deploy.yaml
```

### Output

```bash
deployment.apps/php created
```

---

# Step 5: Verify Deployments

```bash
kubectl get deploy
```

### Output

```bash
NAME               READY   UP-TO-DATE   AVAILABLE
nginx-deployment   3/3     3            3
php                3/3     3            3
```

---

# Step 6: Create ClusterIP Services

## nginx-service.yaml

```yaml
apiVersion: v1
kind: Service

metadata:
  name: nginx-service

spec:
  selector:
    app: nginx

  ports:
  - port: 80
    targetPort: 80

  type: ClusterIP
```

---

## php-svc.yaml

```yaml
apiVersion: v1
kind: Service

metadata:
  name: php-service

spec:
  selector:
    app: php

  ports:
  - port: 80

  type: ClusterIP
```

---

Apply Services

```bash
kubectl create -f nginx-service.yaml
kubectl create -f php-svc.yaml
```

### Output

```bash
service/nginx-service created
service/php-service created
```

---

# Step 7: Verify Services

```bash
kubectl get svc
```

### Output

```bash
NAME            TYPE        CLUSTER-IP
kubernetes      ClusterIP   10.43.0.1
nginx-service   ClusterIP   10.43.164.189
php-service     ClusterIP   10.43.94.62
```

---

# Step 8: Verify Endpoints

```bash
kubectl get endpoints
```

### Output

```bash
NAME            ENDPOINTS
nginx-service   10.42.2.82:80,10.42.2.83:80,10.42.2.84:80
php-service     10.42.2.85:80,10.42.2.86:80
```

---

# Step 9: Create Path Based Ingress

## path-based-ingress.yaml

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: vsphere-path-based-ingress

  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /

spec:
  ingressClassName: nginx

  rules:
  - host: "sebarees.com"

    http:
      paths:

      - path: /nginx
        pathType: Prefix

        backend:
          service:
            name: nginx-service
            port:
              number: 80

      - path: /php
        pathType: Prefix

        backend:
          service:
            name: php-service
            port:
              number: 80
```

Apply Ingress:

```bash
kubectl create -f path-based-ingress.yaml
```

### Output

```bash
ingress.networking.k8s.io/vsphere-path-based-ingress created
```

---

# Step 10: Verify Ingress

```bash
kubectl get ing
```

### Output

```bash
NAME                         CLASS   HOSTS
vsphere-path-based-ingress   nginx   sebarees.com
```

---

# Step 11: Verify Ingress Controller

```bash
kubectl get all -n ingress-nginx
```

### Output

```bash
NAME
pod/ingress-nginx-controller-54569fb988-gmght

NAME
service/ingress-nginx-controller

EXTERNAL-IP
192.168.218.242
```

---

# Step 12: Configure Local DNS Resolution

Edit Windows Hosts File:

```text
C:\Windows\System32\drivers\etc\hosts
```

Add:

```text
192.168.218.242 sebarees.com
192.168.218.242 dhinesh.com
192.168.218.242 dharshini.com
```

---

# Step 13: Test Ingress

## Root Path

```bash
curl sebarees.com
```

### Output

```html
404 Not Found
```

Expected because `/` route is not configured.

---

## NGINX Application

```bash
curl sebarees.com/nginx
```

### Output

```html
<!DOCTYPE html>
<html>
<title>Welcome to nginx!</title>
...
</html>
```

Success ✅

---

## PHPMyAdmin Application

```bash
curl sebarees.com/php
```

### Output

```html
<title>phpMyAdmin</title>
```

Success ✅

---

# Verify Complete Setup

```bash
kubectl get deploy,rs,po,svc,ing -o wide
```

### Output

```bash
DEPLOYMENTS
nginx-deployment   3/3
php                3/3

SERVICES
nginx-service
php-service

INGRESS
vsphere-path-based-ingress
```

---

# Traffic Flow

```text
Client Browser
       |
       |
       v
http://sebarees.com/nginx
http://sebarees.com/php
       |
       v
NGINX Ingress Controller
192.168.218.242
       |
       +--------------------+
       |                    |
       v                    v
nginx-service          php-service
       |                    |
       v                    v
nginx pods          phpmyadmin pods
```

---

# Important Commands Summary

```bash
kubectl delete deploy --all

kubectl delete ds --all

kubectl delete svc --all

kubectl delete po nginx-pod nginx-pod2

kubectl create -f nginx-deployment.yaml

kubectl create -f php-deploy.yaml

kubectl create -f nginx-service.yaml

kubectl create -f php-svc.yaml

kubectl create -f path-based-ingress.yaml

kubectl get deploy

kubectl get svc

kubectl get endpoints

kubectl get ing

kubectl get all -n ingress-nginx

curl sebarees.com/nginx

curl sebarees.com/php
```

---

# Learning Outcome

After completing this lab you learned:

* How Ingress works in Kubernetes
* Difference between Service and Ingress
* How to deploy NGINX and PHP applications
* How ClusterIP Services are used by Ingress
* How path-based routing works
* How NGINX Ingress Controller routes traffic
* How to configure local DNS using the hosts file
* How to troubleshoot Ingress using Services, Endpoints, and Controller logs
* How external requests reach backend Pods through Ingress Controller
