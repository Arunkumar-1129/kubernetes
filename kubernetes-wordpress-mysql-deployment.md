# Deploying WordPress + MySQL on Kubernetes (StatefulSet + Persistent Storage)

A complete step-by-step walkthrough of deploying a production-style WordPress application backed by a MySQL StatefulSet on a Kubernetes cluster, using headless services, PersistentVolumeClaims, Secrets, and NodePort access.

---

## Table of Contents

1. [Create the Namespace](#1-create-the-namespace)
2. [Inspect the Storage Class](#2-inspect-the-storage-class)
3. [Create the MySQL Secret](#3-create-the-mysql-secret)
4. [Create the MySQL Headless Service](#4-create-the-mysql-headless-service)
5. [Deploy MySQL as a StatefulSet](#5-deploy-mysql-as-a-statefulset)
6. [Verify MySQL PVC and Pod](#6-verify-mysql-pvc-and-pod)
7. [Test DNS Resolution and MySQL Connectivity](#7-test-dns-resolution-and-mysql-connectivity)
8. [Create the WordPress PersistentVolumeClaim](#8-create-the-wordpress-persistentvolumeclaim)
9. [Deploy WordPress](#9-deploy-wordpress)
10. [Expose WordPress via NodePort Service](#10-expose-wordpress-via-nodeport-service)
11. [Verify All Resources](#11-verify-all-resources)
12. [Test Pod Rescheduling (Resilience Check)](#12-test-pod-rescheduling-resilience-check)
13. [Exec into MySQL Pod and Verify Data Persistence](#13-exec-into-mysql-pod-and-verify-data-persistence)
14. [WordPress Admin Dashboard](#14-wordpress-admin-dashboard)
15. [Manifest Reference](#15-manifest-reference)

---

## 1. Create the Namespace

All resources for this deployment live in a dedicated `wordpress` namespace.

```bash
kubectl create ns wordpress
```

**Output:**
```
namespace/wordpress created
```

Verify it exists among all namespaces:

```bash
kubectl get ns
```

**Output:**
```
NAME                 STATUS   AGE
cilium-secrets       Active   24d
default              Active   24d
kube-node-lease      Active   24d
kube-public          Active   24d
kube-system          Active   24d
local-path-storage   Active   24d
wordpress            Active   14s
```

> **Note:** `cilium-secrets` and `local-path-storage` are pre-existing system namespaces. The new `wordpress` namespace is 14 seconds old.

---

## 2. Inspect the Storage Class

Before creating PVCs, check which StorageClasses are available:

```bash
kubectl get sc
```

**Output:**
```
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  24d
```

| Field | Value | Meaning |
|---|---|---|
| `NAME` | `local-path` | The default StorageClass |
| `PROVISIONER` | `rancher.io/local-path` | Uses node-local storage (Rancher) |
| `RECLAIMPOLICY` | `Delete` | PV is deleted when PVC is deleted |
| `VOLUMEBINDINGMODE` | `WaitForFirstConsumer` | PV is only provisioned when a Pod is scheduled |
| `ALLOWVOLUMEEXPANSION` | `false` | Volume cannot be resized after creation |

> We will use `local-path` as `storageClassName` in all PVCs.

---

## 3. Create the MySQL Secret

Kubernetes Secrets store sensitive data like passwords. We use `stringData` so the password is readable in plain text in the YAML (Kubernetes base64-encodes it internally).

**`mysql-secrets.yaml`:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: wordpress
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: root123
```

Apply it:

```bash
kubectl apply -f mysql-secrets.yaml
```

**Output:**
```
secret/mysql-secret created
```

> **Common mistake:** The first attempt used the wrong filename (`mysql-secret.yaml` instead of `mysql-secrets.yaml`) and a YAML syntax error on line 5 — both corrected before a successful apply.

Verify the secret was created:

```bash
kubectl get secret -n wordpress
```

**Output:**
```
NAME           TYPE     DATA   AGE
mysql-secret   Opaque   1      8s
```

The `DATA` column shows `1`, meaning one key (`MYSQL_ROOT_PASSWORD`) is stored.

---

## 4. Create the MySQL Headless Service

A **headless service** (`clusterIP: None`) enables DNS-based pod discovery — required for StatefulSets so each pod gets a stable DNS name like `mysql-0.mysql.wordpress.svc.cluster.local`.

**`mysql-headless-svc.yaml`:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: wordpress
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

Apply:

```bash
kubectl apply -f mysql-headless-svc.yaml
```

**Output:**
```
service/mysql created
```

Verify:

```bash
kubectl get svc -n wordpress
```

**Output:**
```
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
mysql   ClusterIP   None         <none>        3306/TCP   10s
```

`CLUSTER-IP: None` confirms this is a headless service. Traffic goes directly to pod IPs, not through a virtual IP.

---

## 5. Deploy MySQL as a StatefulSet

A **StatefulSet** is the correct workload type for databases because it:
- Gives each pod a stable, predictable hostname (e.g., `mysql-0`)
- Creates per-pod PVCs via `volumeClaimTemplates`
- Ensures ordered, graceful pod startup and deletion

**`mysql-sts.yaml`:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: wordpress
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_DATABASE
          value: wordpress
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: local-path
      resources:
        requests:
          storage: 5Gi
```

Apply:

```bash
kubectl apply -f mysql-sts.yaml
```

**Output:**
```
statefulset.apps/mysql created
```

Watch the StatefulSet come up (it may take 30–90 seconds for the image to pull and the pod to initialise):

```bash
kubectl get sts -n wordpress
```

**Output (after pod is Running):**
```
NAME    READY   AGE
mysql   1/1     74s
```

`READY: 1/1` means the single replica is healthy.

---

## 6. Verify MySQL PVC and Pod

The StatefulSet auto-created a PVC named `mysql-data-mysql-0` (pattern: `<volumeClaimTemplate name>-<pod name>`):

```bash
kubectl get pvc -n wordpress
```

**Output:**
```
NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mysql-data-mysql-0   Bound    pvc-b7bae0a3-bd9d-48a6-ac64-93abde40fb8d   5Gi        RWO            local-path     <unset>                 86s
```

| Field | Value | Meaning |
|---|---|---|
| `STATUS` | `Bound` | Successfully provisioned and attached |
| `CAPACITY` | `5Gi` | 5 GiB allocated as requested |
| `ACCESS MODES` | `RWO` | ReadWriteOnce — mounted by one node at a time |
| `STORAGECLASS` | `local-path` | Uses node-local Rancher provisioner |

Check the pod:

```bash
kubectl get pods -n wordpress
```

**Output:**
```
NAME      READY   STATUS    RESTARTS   AGE
mysql-0   1/1     Running   0          104s
```

---

## 7. Test DNS Resolution and MySQL Connectivity

Launch a temporary Ubuntu pod inside the `wordpress` namespace to test internal cluster DNS and MySQL access:

```bash
kubectl run ubuntu \
  -n wordpress \
  -it --rm \
  --image=ubuntu:24.04 -- bash
```

The `--rm` flag automatically deletes the pod when the shell exits. Once inside, install the MySQL client and DNS tools:

```bash
apt update && apt install dnsutils default-mysql-client -y
```

### DNS Resolution Test

```bash
nslookup mysql-0.mysql.wordpress.svc.cluster.local
```

**Output:**
```
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   mysql-0.mysql.wordpress.svc.cluster.local
Address: 192.168.0.12
```

The CoreDNS server at `10.96.0.10` resolved `mysql-0.mysql.wordpress.svc.cluster.local` to pod IP `192.168.0.12`. The headless service enables this per-pod DNS record.

**DNS name anatomy:**

```
mysql-0  .  mysql  .  wordpress  .  svc  .  cluster.local
   │           │           │          │         │
pod name   service     namespace   resource   cluster
           name                     type       domain
```

### MySQL Connection Test

```bash
mysql -u root \
  -h mysql-0.mysql.wordpress.svc.cluster.local \
  -p
```

Enter password `root123` when prompted.

**Output:**
```
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.46 MySQL Community Server - GPL
```

Verify the `wordpress` database was auto-created:

```bash
mysql> show databases;
```

**Output:**
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpress          |
+--------------------+
5 rows in set (0.01 sec)
```

The `wordpress` database exists — created by the `MYSQL_DATABASE` environment variable. Exit the pod:

```bash
mysql> exit
exit   # exits bash, pod is auto-deleted
```

---

## 8. Create the WordPress PersistentVolumeClaim

WordPress needs persistent storage for its web files (`/var/www/html` — themes, plugins, uploads):

**`wordpress-pvc.yaml`:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wordpress-pvc
  namespace: wordpress
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 5Gi
```

Apply:

```bash
kubectl apply -f wordpress-pvc.yaml
```

**Output:**
```
persistentvolumeclaim/wordpress-pvc created
```

---

## 9. Deploy WordPress

The WordPress Deployment references:
- The MySQL StatefulSet pod via its stable DNS name
- The root password directly in env (suitable for lab; use a Secret reference in production)
- The PVC created above for file persistence

**`wordpress-deploy.yaml`:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:latest
        ports:
        - containerPort: 80
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql-0.mysql.wordpress.svc.cluster.local
        - name: WORDPRESS_DB_USER
          value: root
        - name: WORDPRESS_DB_PASSWORD
          value: root123
        - name: WORDPRESS_DB_NAME
          value: wordpress
        volumeMounts:
        - name: wp-data
          mountPath: /var/www/html
      volumes:
      - name: wp-data
        persistentVolumeClaim:
          claimName: wordpress-pvc
```

Apply:

```bash
kubectl apply -f wordpress-deploy.yaml
```

**Output:**
```
deployment.apps/wordpress created
```

---

## 10. Expose WordPress via NodePort Service

A **NodePort** service opens a static port on every node, allowing external browser access.

**`wordpress-svc.yaml`:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: wordpress
spec:
  type: NodePort
  selector:
    app: wordpress
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

Apply:

```bash
kubectl apply -f wordpress-svc.yaml
```

**Output:**
```
service/wordpress created
```

Get the node's IP:

```bash
kubectl get nodes -o wide
```

**Output:**
```
NAME           STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
controlplane   Ready    control-plane   24d   v1.35.1   172.30.1.2    <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic   containerd://2.2.1
```

WordPress is now accessible at: **`http://172.30.1.2:30080`**

---

## 11. Verify All Resources

Check all services in the namespace:

```bash
kubectl get svc -n wordpress
```

**Output:**
```
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
mysql       ClusterIP   None            <none>        3306/TCP       12m
mysql1      ClusterIP   None            <none>        3306/TCP       11m
wordpress   NodePort    10.110.27.147   <none>        80:30080/TCP   61s
```

> **Note:** `mysql1` is a duplicate headless service created by accident during the initial setup — it is unused and can be deleted with `kubectl delete svc mysql1 -n wordpress`.

Check all PVCs:

```bash
kubectl get pvc -n wordpress
```

**Output:**
```
NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mysql-data-mysql-0   Bound    pvc-b7bae0a3-bd9d-48a6-ac64-93abde40fb8d   5Gi        RWO            local-path     <unset>                 11m
wordpress-pvc        Bound    pvc-3008d28d-24bf-4876-a2c1-29a3929c0367   5Gi        RWO            local-path     <unset>                 3m44s
```

Both PVCs are `Bound`, meaning storage has been provisioned and attached.

---

## 12. Test Pod Rescheduling (Resilience Check)

### Delete the MySQL Pod

```bash
kubectl delete pod mysql-0 -n wordpress
```

**Output:**
```
pod "mysql-0" deleted from wordpress namespace
```

The StatefulSet controller immediately recreates `mysql-0`. Watch it recover:

```bash
kubectl get pods -n wordpress -w
```

**Output:**
```
NAME                         READY   STATUS    RESTARTS   AGE
mysql-0                      1/1     Running   0          9s
wordpress-556dd6cb54-8bb74   1/1     Running   0          3m51s
```

`mysql-0` is Running again in ~9 seconds, reattached to the same PVC — **data is preserved**.

### Delete the WordPress Pod

```bash
kubectl delete pod -l app=wordpress -n wordpress
```

**Output:**
```
pod "wordpress-556dd6cb54-8bb74" deleted from wordpress namespace
```

The Deployment controller recreates the WordPress pod automatically:

```bash
kubectl get pods -n wordpress -w
```

**Output:**
```
NAME                         READY   STATUS    RESTARTS   AGE
mysql-0                      1/1     Running   0          100s
wordpress-556dd6cb54-qnp7p   1/1     Running   0          8s
```

New pod `qnp7p` is up in 8 seconds, reusing the same `wordpress-pvc`.

---

## 13. Exec into MySQL Pod and Verify Data Persistence

After WordPress is set up via the browser, exec directly into the MySQL pod to confirm data was written to the database:

```bash
kubectl exec -it mysql-0 -n wordpress -- bash
```

Connect to MySQL from inside the pod:

```bash
bash-5.1# mysql -u root \
  -h mysql-0.mysql.wordpress.svc.cluster.local \
  -p
```

Enter password `root123`.

**Output:**
```
Welcome to the MySQL monitor.
Server version: 8.0.46 MySQL Community Server - GPL
```

List databases and switch to `wordpress`:

```sql
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpress          |
+--------------------+
5 rows in set (0.01 sec)

mysql> use wordpress;
Reading table information for completion of table and column names
Database changed
```

Show all WordPress tables (confirms full WordPress installation completed):

```sql
mysql> show tables;
+-----------------------+
| Tables_in_wordpress   |
+-----------------------+
| wp_commentmeta        |
| wp_comments           |
| wp_links              |
| wp_options            |
| wp_postmeta           |
| wp_posts              |
| wp_term_relationships |
| wp_term_taxonomy      |
| wp_termmeta           |
| wp_terms              |
| wp_usermeta           |
| wp_users              |
+-----------------------+
12 rows in set (0.00 sec)
```

Inspect the admin user created during WordPress setup:

```sql
mysql> select * from wp_users;
+----+------------+------------------------------------------------------------------+---------------+---------------+---------------------------------------------------------------+---------------------+---------------------+-------------+--------------+
| ID | user_login | user_pass                                                        | user_nicename | user_email    | user_url                                                      | user_registered     | user_activation_key | user_status | display_name |
+----+------------+------------------------------------------------------------------+---------------+---------------+---------------------------------------------------------------+---------------------+---------------------+-------------+--------------+
|  1 | Arun Kumar | $wp$2y$10$BT8.AHzJjWy...                                         | arun-kumar    | xyz@gmail.com | https://8a8142dab733-10-244-5-183-30080.papa.r.killercoda.com | 2026-06-10 16:26:04 |                     |           0 | Arun Kumar   |
+----+------------+------------------------------------------------------------------+---------------+---------------+---------------------------------------------------------------+---------------------+---------------------+-------------+--------------+
1 row in set (0.01 sec)
```

| Field | Value |
|---|---|
| `user_login` | `Arun Kumar` |
| `user_pass` | Bcrypt hash (WordPress `$wp$2y$10$...` format) |
| `user_email` | `xyz@gmail.com` |
| `user_registered` | `2026-06-10 16:26:04` |
| `user_url` | KillerCoda playground URL |

---

## 14. WordPress Admin Dashboard

After completing the WordPress installation wizard via the browser at `http://172.30.1.2:30080`, the admin dashboard is accessible and fully functional:

[![1-wp-setup-start.webp](https://i.postimg.cc/mZCPcxZd/1-wp-setup-start.webp)](https://postimg.cc/MXZ64FQR)
[![Screenshot-2026-06-10-220632.png](https://i.postimg.cc/PrKrZTgK/Screenshot-2026-06-10-220632.png)](https://postimg.cc/GH8Cnwhs)

The dashboard confirms:
- WordPress **7.0** is running (as shown by the "Learn more about the 7.0 version" banner)
- Logged in as **Arun Kumar**
- All standard admin menus are available: Posts, Media, Pages, Comments, Appearance, Plugins, Users, Tools, Settings

---

## 15. Manifest Reference

A summary of all YAML files created in this deployment:

| File | Kind | Name | Namespace | Purpose |
|---|---|---|---|---|
| `mysql-secrets.yaml` | Secret | `mysql-secret` | `wordpress` | MySQL root password |
| `mysql-headless-svc.yaml` | Service | `mysql` | `wordpress` | Headless service for StatefulSet DNS |
| `mysql-sts.yaml` | StatefulSet | `mysql` | `wordpress` | MySQL database with persistent storage |
| `wordpress-pvc.yaml` | PersistentVolumeClaim | `wordpress-pvc` | `wordpress` | Storage for WordPress files |
| `wordpress-deploy.yaml` | Deployment | `wordpress` | `wordpress` | WordPress application |
| `wordpress-svc.yaml` | Service | `wordpress` | `wordpress` | NodePort exposure on port 30080 |

### Architecture Overview

```
Internet / Browser
        │
        ▼  port 30080
┌───────────────────┐
│  NodePort Service │  (wordpress)
└────────┬──────────┘
         │
         ▼
┌───────────────────┐     ┌──────────────────────┐
│ WordPress Pod     │────▶│ wordpress-pvc (5Gi)  │
│ (Deployment)      │     │ /var/www/html        │
└────────┬──────────┘     └──────────────────────┘
         │ WORDPRESS_DB_HOST
         │ mysql-0.mysql.wordpress.svc.cluster.local
         ▼
┌───────────────────┐     ┌──────────────────────┐
│ MySQL Pod         │────▶│ mysql-data-mysql-0   │
│ mysql-0           │     │ (5Gi) /var/lib/mysql │
│ (StatefulSet)     │     └──────────────────────┘
└────────┬──────────┘
         │ reads
         ▼
┌───────────────────┐
│ mysql-secret      │
│ (MYSQL_ROOT_PASS) │
└───────────────────┘
```

---

*Deployment completed on Kubernetes v1.35.1 | containerd 2.2.1 | MySQL 8.0.46 | WordPress 7.0*
