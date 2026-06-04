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
