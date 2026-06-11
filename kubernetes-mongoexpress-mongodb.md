# MongoDB + Mongo Express Deployment on Kubernetes

## Lab Objective

Deploy:

* MongoDB using StatefulSet
* Persistent Storage using PVC
* Mongo Express Web UI
* Kubernetes Secret for credentials
* Services for internal and external access

---

# Step 1: Create Namespace

## Create File

```bash
vi namespace.yaml
```

## namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mongodb
```

## Apply Configuration

```bash
kubectl apply -f namespace.yaml
```

## Output

```bash
namespace/mongodb created
```

## Verify

```bash
kubectl get ns
```

## Output

```bash
NAME              STATUS   AGE
default           Active   2d
kube-system       Active   2d
mongodb           Active   5s
```

## Explanation

Creates a dedicated namespace named `mongodb` to isolate all MongoDB resources.

---

# Step 2: Create Secret

## Create File

```bash
vi mongo-secret.yaml
```

## mongo-secret.yaml

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

## Apply Secret

```bash
kubectl apply -f mongo-secret.yaml
```

## Output

```bash
secret/mongodb-secret created
```

## Verify Secret

```bash
kubectl get secret -n mongodb
```

## Output

```bash
NAME             TYPE     DATA   AGE
mongodb-secret   Opaque   2      8s
```

## View Secret

```bash
kubectl get secret mongodb-secret -n mongodb -o yaml
```

## Output

```bash
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-secret
  namespace: mongodb

data:
  mongo-root-password: YWRtaW4xMjM=
  mongo-root-username: YWRtaW4=
type: Opaque
```

## Explanation

Stores MongoDB credentials securely.

---

# Step 3: Create MongoDB StatefulSet

## Create File

```bash
vi mongo-sts.yaml
```

## mongo-sts.yaml

```yaml
apiVersion: apps/v1
kind: StatefulSet

metadata:
  name: mongodb
  namespace: mongodb

spec:
  serviceName: mongodb-service

  replicas: 1

  selector:
    matchLabels:
      app: mongodb

  template:
    metadata:
      labels:
        app: mongodb

    spec:
      containers:
      - name: mongodb
        image: mongo:8

        ports:
        - containerPort: 27017

        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: mongo-root-username

        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: mongo-root-password

        volumeMounts:
        - name: mongo-data
          mountPath: /data/db

  volumeClaimTemplates:
  - metadata:
      name: mongo-data

    spec:
      accessModes:
      - ReadWriteOnce

      storageClassName: local-path

      resources:
        requests:
          storage: 5Gi
```

## Apply StatefulSet

```bash
kubectl apply -f mongo-sts.yaml
```

## Output

```bash
statefulset.apps/mongodb created
```

## Verify StatefulSet

```bash
kubectl get sts -n mongodb
```

## Output

```bash
NAME      READY   AGE
mongodb   1/1     30s
```

## Verify Pod

```bash
kubectl get pods -n mongodb
```

## Output

```bash
NAME        READY   STATUS    RESTARTS   AGE
mongodb-0   1/1     Running   0          25s
```

## Verify PVC

```bash
kubectl get pvc -n mongodb
```

## Output

```bash
NAME                  STATUS   VOLUME                                     CAPACITY
mongo-data-mongodb-0  Bound    pvc-0a506372-38e4-4e7e-a1f1-8a23aef5cba3   5Gi
```

## Explanation

StatefulSet provides:

* Stable Pod Names
* Stable Storage
* Stable Network Identity

MongoDB pod becomes:

```bash
mongodb-0
```

---

# Step 4: Create MongoDB Service

## Create File

```bash
vi mongo-svc.yaml
```

## mongo-svc.yaml

```yaml
apiVersion: v1
kind: Service

metadata:
  name: mongodb-service
  namespace: mongodb

spec:
  selector:
    app: mongodb

  ports:
  - port: 27017
    targetPort: 27017

  type: ClusterIP
```

## Apply Service

```bash
kubectl apply -f mongo-svc.yaml
```

## Output

```bash
service/mongodb-service created
```

## Verify

```bash
kubectl get svc -n mongodb
```

## Output

```bash
NAME              TYPE        CLUSTER-IP        PORT(S)
mongodb-service   ClusterIP   10.111.121.148   27017/TCP
```

## Explanation

Creates an internal service for MongoDB communication.

---

# Step 5: Create Mongo Express Deployment

## Create File

```bash
vi mongo-express-deploy.yaml
```

## mongo-express-deploy.yaml

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: mongo-express
  namespace: mongodb

spec:
  replicas: 1

  selector:
    matchLabels:
      app: mongo-express

  template:
    metadata:
      labels:
        app: mongo-express

    spec:
      containers:
      - name: mongo-express
        image: mongo-express

        ports:
        - containerPort: 8081

        env:
        - name: ME_CONFIG_MONGODB_ADMINUSERNAME
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: mongo-root-username

        - name: ME_CONFIG_MONGODB_ADMINPASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: mongo-root-password

        - name: ME_CONFIG_MONGODB_SERVER
          value: mongodb-service
```

## Apply Deployment

```bash
kubectl apply -f mongo-express-deploy.yaml
```

## Output

```bash
deployment.apps/mongo-express created
```

## Verify Deployment

```bash
kubectl get deployment -n mongodb
```

## Output

```bash
NAME            READY   UP-TO-DATE   AVAILABLE
mongo-express   1/1     1            1
```

## Verify Pod

```bash
kubectl get pods -n mongodb
```

## Output

```bash
NAME                                   READY   STATUS
mongo-express-6795f46866-c7c9w         1/1     Running
mongodb-0                              1/1     Running
```

## Explanation

Mongo Express connects to MongoDB using:

```bash
mongodb-service:27017
```

---

# Step 6: Create Mongo Express Service

## Create File

```bash
vi mongo-express-svc.yaml
```

## mongo-express-svc.yaml

```yaml
apiVersion: v1
kind: Service

metadata:
  name: mongo-express-service
  namespace: mongodb

spec:
  type: NodePort

  selector:
    app: mongo-express

  ports:
  - port: 8081
    targetPort: 8081
    nodePort: 30081
```

## Apply Service

```bash
kubectl apply -f mongo-express-svc.yaml
```

## Output

```bash
service/mongo-express-service created
```

## Verify

```bash
kubectl get svc -n mongodb
```

## Output

```bash
NAME                    TYPE       CLUSTER-IP      PORT(S)
mongo-express-service   NodePort   10.100.9.94    8081:30081/TCP
mongodb-service         ClusterIP  10.111.121.148 27017/TCP
```

## Explanation

Exposes Mongo Express externally using NodePort 30081.

---

# Final Verification

## Check Everything

```bash
kubectl get all -n mongodb
```

## Output

```bash
NAME                                     READY   STATUS
pod/mongo-express-6795f46866-c7c9w       1/1     Running
pod/mongodb-0                            1/1     Running

NAME                            TYPE
service/mongo-express-service   NodePort
service/mongodb-service         ClusterIP

NAME                            READY
deployment.apps/mongo-express   1/1

NAME                     READY
statefulset.apps/mongodb 1/1
```

---

# Useful Troubleshooting Commands

## Describe Deployment

```bash
kubectl describe deployment mongo-express -n mongodb
```

## Describe StatefulSet

```bash
kubectl describe sts mongodb -n mongodb
```

## View MongoDB Logs

```bash
kubectl logs mongodb-0 -n mongodb
```

## View Mongo Express Logs

```bash
kubectl logs deployment/mongo-express -n mongodb
```

## Watch Resources Live

```bash
watch kubectl get po,pvc,svc,sts -n mongodb -o wide
```

---

# Access Mongo Express

## Get Node IP

```bash
kubectl get nodes -o wide
```

Example:

```bash
NAME           STATUS   ROLES           INTERNAL-IP
controlplane   Ready    control-plane   192.168.1.10
```

## Open Browser

```bash
http://192.168.1.10:30081
```

Login Credentials:

```bash
Username: admin
Password: admin123
```
