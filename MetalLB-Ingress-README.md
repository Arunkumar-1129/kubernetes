# MetalLB & Nginx Ingress Controller — Lab Guide

---

## 1. MetalLB Setup

### Install MetalLB

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
```

---

### Create IP Address Pool

```bash
vi ippool.yaml
```

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.44.240-192.168.44.250   # Change this IP range to match your network
```

```bash
kubectl create -f ippool.yaml
```

---

### Create L2 Advertisement

```bash
vi l2ad.yaml
```

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
```

```bash
kubectl create -f l2ad.yaml
```

---

## 2. Deploy Nginx Ingress Controller

### Install (choose one)

```bash
# Option 1 - v1.9.6
kubectl apply -f https://github.com/kubernetes/ingress-nginx/blob/controller-v1.9.6/deploy/static/provider/baremetal/deploy.yaml

# Option 2 - v1.13.4 (latest)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.4/deploy/static/provider/baremetal/deploy.yaml
```

### Change Service Type to LoadBalancer

```bash
kubectl -n ingress-nginx edit svc ingress-nginx-controller
```

> In the editor, change `type: ClusterIP` → `type: LoadBalancer`

---

## 3. Create Deployments

### Using kubectl imperative commands

```bash
kubectl create deployment httpd-deploy      --image=httpd      --replicas=2
kubectl create deployment nginx-deploy      --image=nginx      --replicas=2
kubectl create deployment phpmyadmin-deploy --image=phpmyadmin --replicas=2
```

### Using YAML manifests

#### nginx-deploy Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
  labels:
    app: nginx-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-deploy
  template:
    metadata:
      labels:
        app: nginx-deploy
    spec:
      containers:
      - image: nginx
        name: nginx-deploy
        ports:
        - containerPort: 80
```

#### httpd-deploy Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd-deploy
  labels:
    app: httpd-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd-deploy
  template:
    metadata:
      labels:
        app: httpd-deploy
    spec:
      containers:
      - image: httpd
        name: httpd-deploy
        ports:
        - containerPort: 80
```

---

## 4. Create Services

### ClusterIP Services

```bash
kubectl expose deployment nginx-deploy      --name nginx-deploy-svc      --type=ClusterIP --port 80 --target-port 80
kubectl expose deployment httpd-deploy      --name httpd-deploy-svc      --type=ClusterIP --port 80 --target-port 80
kubectl expose deployment phpmyadmin-deploy --name phpmyadmin-deploy-svc --type=ClusterIP --port 80 --target-port 80
```

### LoadBalancer Services

```bash
kubectl expose deployment nginx-deploy      --name nginx-deploy-svc      --type=LoadBalancer --port 80 --target-port 80
kubectl expose deployment httpd-deploy      --name httpd-deploy-svc      --type=LoadBalancer --port 80 --target-port 80
kubectl expose deployment phpmyadmin-deploy --name phpmyadmin-deploy-svc --type=LoadBalancer --port 80 --target-port 80
```

### NodePort Services (YAML)

#### nginx-deploy-svc

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-deploy
  name: nginx-deploy-svc
spec:
  type: NodePort
  selector:
    app: nginx-deploy
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
```

#### httpd-deploy-svc

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: httpd-deploy
  name: httpd-deploy-svc
spec:
  type: NodePort
  selector:
    app: httpd-deploy
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
```

---

## 5. Create Ingress Rules

### Types of Ingress

- **DefaultBackend** — catch-all fallback backend
- **Path Based Routing** — route by URL path (e.g. `/httpd`, `/nginx`)
- **Name Based Routing** — route by hostname (e.g. `nginx.veecube.com`)

---

### Name Based Routing

```bash
vi namebased-ingress.yaml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: namebased-kubernetes-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: "nginx.veecube.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: nginx-deploy-svc
            port:
              number: 80
  - host: "httpd.veecube.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: httpd-deploy-svc
            port:
              number: 80
```

```bash
kubectl apply -f namebased-ingress.yaml
```

---

### Path Based Routing — Option 1 (sece.com)

```bash
vi pathbased-ingress.yaml
```

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
  - host: "website.sece.com"
    http:
      paths:
      - path: /httpd
        pathType: Prefix
        backend:
          service:
            name: httpd-deploy-svc
            port:
              number: 80
      - path: /nginx
        pathType: Prefix
        backend:
          service:
            name: nginx-deploy-svc
            port:
              number: 80
      - path: /phpmyadmin
        pathType: Prefix
        backend:
          service:
            name: phpmyadmin-deploy-svc
            port:
              number: 80
```

```bash
kubectl apply -f pathbased-ingress.yaml
```

---

### Path Based Routing — Option 2 (veecube.com)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: pathbased-kubernetes-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: "web.veecube.com"
    http:
      paths:
      - path: /httpd
        pathType: Prefix
        backend:
          service:
            name: httpd-deploy-svc
            port:
              number: 80
      - path: /nginx
        pathType: Prefix
        backend:
          service:
            name: nginx-deploy-svc
            port:
              number: 80
      - path: /phpmyadmin
        pathType: Prefix
        backend:
          service:
            name: phpmyadmin-deploy-svc
            port:
              number: 8080
```

---

## Summary

| Step | Action | Command / File |
|------|--------|---------------|
| 1 | Install MetalLB | `kubectl apply -f <metallb-manifest>` |
| 2 | Create IP Pool | `ippool.yaml` → `kubectl create -f ippool.yaml` |
| 3 | Create L2 Advertisement | `l2ad.yaml` → `kubectl create -f l2ad.yaml` |
| 4 | Install Nginx Ingress | `kubectl apply -f <ingress-nginx-manifest>` |
| 5 | Set Ingress to LoadBalancer | `kubectl -n ingress-nginx edit svc ingress-nginx-controller` |
| 6 | Create Deployments | `kubectl create deployment ...` or YAML |
| 7 | Expose Services | `kubectl expose deployment ...` or YAML |
| 8 | Apply Ingress Rules | `namebased-ingress.yaml` / `pathbased-ingress.yaml` |
