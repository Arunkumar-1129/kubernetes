# MongoDB + Mongo Express Deployment on Kubernetes

## 1. Create Namespace

### Create YAML

```bash
vi namespace.yaml
```

### Content

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mongodb
```

### Apply Configuration

```bash
kubectl apply -f namespace.yaml
```

### Output

```bash
namespace/mongodb created
```

### Explanation

* `kubectl apply` creates or updates Kubernetes resources.
* `-f` specifies the YAML file.
* A namespace named `mongodb` is created.
* All MongoDB-related resources will be isolated inside this namespace.

---

## 2. Create MongoDB Secret

### Create YAML

```bash
vi mongo-secret.yaml
```

### Content

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-secret
  namespace: mongodb

type: Opaque

stringData:
  mongo-root-username: admin
  mongo-root-password: admin123
```

### Apply Configuration

```bash
kubectl apply -f mongo-secret.yaml
```

### Output

```bash
secret/mongodb-secret created
```

### Explanation

* Stores MongoDB credentials securely.
* Avoids hardcoding passwords in Deployment or StatefulSet manifests.
* Values are later injected as environment variables.

---

## 3. Create Persistent Volume Claim

### Create YAML

```bash
vi mongo-pvc.yaml
```

### Content

```yaml
apiVersion: v1
kind: PersistentVolumeClaim

metadata:
  name: mongodb-pvc
  namespace: mongodb

spec:
  accessModes:
    - ReadWriteOnce

  storageClassName: local-path

  resources:
    requests:
      storage: 5Gi
```

### Apply Configuration

```bash
kubectl apply -f mongo-pvc.yaml
```

### Output

```bash
persistentvolumeclaim/mongodb-pvc created
```

### Verify

```bash
kubectl get pvc -n mongodb
```

### Example Output

```bash
NAME          STATUS    VOLUME   CAPACITY
mongodb-pvc   Pending
```

### Explanation

* Requests 5GB storage.
* `ReadWriteOnce` allows mounting by one node.
* PVC waits for a matching Persistent Volume.
* In this setup the StatefulSet creates its own PVC, making this PVC optional.

---

## 4. Deploy MongoDB StatefulSet

### Create YAML

```bash
vi mongo-sts.yaml
```

### Apply Configuration

```bash
kubectl apply -f mongo-sts.yaml
```

### Output

```bash
statefulset.apps/mongodb created
```

### Verify StatefulSet

```bash
kubectl get sts -n mongodb
```

### Output

```bash
NAME      READY   AGE
mongodb   1/1     1m
```

### Verify Pod

```bash
kubectl get pods -n mongodb
```

### Output

```bash
NAME        READY   STATUS    RESTARTS   AGE
mongodb-0   1/1     Running   0          1m
```

### Explanation

* StatefulSet is preferred for databases.
* Provides stable pod names.
* Maintains persistent storage.
* Keeps network identity intact across restarts.

---

## 5. Create MongoDB Service

### Create YAML

```bash
vi mongo-svc.yaml
```

### Apply Configuration

```bash
kubectl apply -f mongo-svc.yaml
```

### Output

```bash
service/mongodb-service created
```

### Verify

```bash
kubectl get svc -n mongodb
```

### Output

```bash
NAME              TYPE        CLUSTER-IP      PORT(S)
mongodb-service   ClusterIP   10.111.121.148 27017/TCP
```

### Explanation

* Creates an internal service.
* Exposes MongoDB on port 27017.
* Other pods can connect using:

```bash
mongodb-service:27017
```

---

## 6. Deploy Mongo Express

### Create YAML

```bash
vi mongo-express-deploy.yaml
```

### Apply Configuration

```bash
kubectl apply -f mongo-express-deploy.yaml
```

### Output

```bash
deployment.apps/mongo-express created
```

### Verify Deployment

```bash
kubectl get deploy -n mongodb
```

### Output

```bash
NAME            READY   UP-TO-DATE   AVAILABLE
mongo-express   1/1     1            1
```

### Verify Pod

```bash
kubectl get pods -n mongodb
```

### Output

```bash
NAME                                  READY   STATUS
mongo-express-6795f46866-c7c9w        1/1     Running
mongodb-0                             1/1     Running
```

### Explanation

* Deploys Mongo Express web interface.
* Uses credentials from Kubernetes Secret.
* Connects to MongoDB through `mongodb-service`.

---

## 7. Create Mongo Express Service

### Create YAML

```bash
vi mongo-express-svc.yaml
```

### Apply Configuration

```bash
kubectl apply -f mongo-express-svc.yaml
```

### Output

```bash
service/mongo-express-service created
```

### Verify

```bash
kubectl get svc -n mongodb
```

### Output

```bash
NAME                    TYPE       CLUSTER-IP      PORT(S)
mongo-express-service   NodePort   10.100.9.94    8081:30081/TCP
mongodb-service         ClusterIP  10.111.121.148 27017/TCP
```

### Explanation

* Exposes Mongo Express outside the cluster.
* Kubernetes allocates NodePort `30081`.
* Traffic flow:

```text
Browser
   │
   ▼
NodeIP:30081
   │
   ▼
Mongo Express Service
   │
   ▼
Mongo Express Pod
   │
   ▼
MongoDB Service
   │
   ▼
MongoDB Pod
```

---

# Verification Commands

## View All Resources

```bash
kubectl get all -n mongodb
```

### Output

```bash
NAME                                      READY   STATUS
pod/mongo-express-6795f46866-c7c9w        1/1     Running
pod/mongodb-0                             1/1     Running

NAME                            TYPE
service/mongo-express-service   NodePort
service/mongodb-service         ClusterIP

NAME                            READY
deployment.apps/mongo-express   1/1

NAME                            READY
statefulset.apps/mongodb        1/1
```

---

## Check PVC Status

```bash
kubectl get pvc -n mongodb
```

### Output

```bash
NAME                  STATUS   VOLUME
mongo-data-mongodb-0  Bound
mongodb-pvc           Pending
```

### Explanation

`mongo-data-mongodb-0`

* Automatically created by StatefulSet.
* Attached to MongoDB pod.
* Stores database files permanently.

---

## Inspect Deployment

```bash
kubectl describe deployment mongo-express -n mongodb
```

### Purpose

Shows:

* Labels
* Replicas
* Environment variables
* Events
* Container configuration
* Troubleshooting information

---

## View Logs

MongoDB:

```bash
kubectl logs mongodb-0 -n mongodb
```

Mongo Express:

```bash
kubectl logs deployment/mongo-express -n mongodb
```

### Purpose

Useful for:

* Authentication failures
* Connection issues
* Startup errors
* CrashLoopBackOff troubleshooting

---

## Watch Resources Continuously

```bash
watch kubectl get po,pvc,sts -n mongodb -o wide
```

### Purpose

Refreshes every 2 seconds and shows:

* Pod status
* PVC status
* StatefulSet health

---

# Final Result

Successfully deployed:

```bash
✓ Namespace
✓ Secret
✓ StatefulSet
✓ Persistent Storage
✓ MongoDB Service
✓ Mongo Express Deployment
✓ Mongo Express NodePort Service
```

Access Mongo Express:

```bash
http://<Node-IP>:30081
```

MongoDB Internal Endpoint:

```bash
mongodb-service:27017
```
