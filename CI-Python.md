### Lab Exercise: Build Python Docker Image and Push to Docker Hub Using GitLab CI/CD

#### Objective

Create a simple Python Flask application, build a Docker image using GitLab CI/CD, and push the image to Docker Hub.

---

## Step 1: Create Project Structure

```text
python-app/
├── app.py
├── requirements.txt
├── Dockerfile
└── .gitlab-ci.yml
```

---

## Step 2: Create Python Application

### app.py

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from <studentname> Python Docker Application!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
```

---

## Step 3: Create requirements.txt

```text
Flask==2.3.2
```

---

## Step 4: Create Dockerfile

```dockerfile
# Use official Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY . .

# Expose application port
EXPOSE 5000

# Start application
CMD ["python", "app.py"]
```

---

## Step 5: Create GitLab CI/CD Pipeline

### .gitlab-ci.yml

> Replace **<studentname>** with your Docker Hub username.

```yaml
stages:
  - build

docker_build_job:
  stage: build

  image: docker

  services:
    - docker:dind

  script:
    - docker build -t python-app:v1 .

    - docker images

    - docker tag python-app:v1 <studentname>/python-app:v1

    - docker login -u <studentname> -p <dockerhub-password-or-token>

    - docker push <studentname>/python-app:v1
```

---

## Step 6: Commit and Push Code

```bash
git add .
git commit -m "Initial Commit"
git push origin main
```

---

## Step 7: Verify Pipeline

Navigate to:

```text
GitLab Project
   → Build
      → Pipelines
```

Verify the job completes successfully.

---

## Step 8: Verify Docker Hub Image

Check your Docker Hub repository:

```text
https://hub.docker.com/repositories
```

You should see:

```text
<studentname>/python-app:v1
```

---

## Step 9: Test the Image

Pull the image:

```bash
docker pull <studentname>/python-app:v1
```

Run the container:

```bash
docker run -d -p 5000:5000 --name python-app <studentname>/python-app:v1
```

Verify:

```bash
docker ps
```

Access:

```text
http://<server-ip>:5000
```

Expected Output:

```text
Hello from <studentname> Python Docker Application!
```

---

## Validation Commands

```bash
docker images

docker ps

docker logs python-app

curl http://localhost:5000
```

Expected Output:

```text
Hello from <studentname> Python Docker Application!
```

### Lab Outcome

* Created a Python Flask application.
* Created a Docker image.
* Automated image build using GitLab CI/CD.
* Pushed the image to Docker Hub.
* Pulled and ran the image successfully.

  ---
# practiced
  # Docker Hub Image Deployment Verification

## Pull the Docker Image

```bash
docker pull arunkumar1129/python-app:v1
```

Expected Output:

```bash
v1: Pulling from arunkumar1129/python-app
Status: Downloaded newer image for arunkumar1129/python-app:v1
docker.io/arunkumar1129/python-app:v1
```

---

## Verify the Downloaded Image

```bash
docker images
```

Expected Output:

```bash
REPOSITORY                   TAG    IMAGE ID
arunkumar1129/python-app     v1     273c3a062764
```

---

## Inspect the Image Configuration

```bash
docker inspect arunkumar1129/python-app:v1
```

Important Details:

```json
"ExposedPorts": {
    "5000/tcp": {}
}
```

This confirms that the application inside the container listens on port **5000**.

---

## Initial Deployment Attempt

```bash
docker run -d -p 5000:5000 arunkumar1129/python-app:v1
```

Error Encountered:

```bash
docker: Error response from daemon:
failed to bind host port 0.0.0.0:5000/tcp:
address already in use
```

Reason:

Port **5000** on the host machine was already occupied by another process.

---

## Verify Port Usage

```bash
sudo netstat -tulpn | grep 5000
```

Output:

```bash
tcp 0 0 0.0.0.0:5000 0.0.0.0:* LISTEN 1815/conmon
```

This confirms that port **5000** is already in use.

---

## Remove Failed Containers

```bash
docker ps -a
```

Remove created containers:

```bash
docker rm <container-id>
```

Example:

```bash
docker rm 2f5aa09bbddc
docker rm 0f0893d233c9
```

---

## Successful Deployment Using Alternate Host Port

```bash
docker run -d -p 8080:5000 arunkumar1129/python-app:v1
```

Explanation:

* Host Port: 8080
* Container Port: 5000

Traffic Flow:

```text
Browser
   |
   v
Host Port 8080
   |
   v
Container Port 5000
```

---

## Verify Running Container

```bash
docker ps -a
```

Expected Output:

```bash
CONTAINER ID   IMAGE                         STATUS
bd7659a4dcea   arunkumar1129/python-app:v1   Up
```

Port Mapping:

```bash
0.0.0.0:8080->5000/tcp
```

---

## Access the Application

Open:

```text
http://<SERVER-IP>:8080
```

Examples:

```text
http://localhost:8080
```

or

```text
http://<killercoda-public-ip>:8080
```

---

## Complete Command Sequence

```bash
docker pull arunkumar1129/python-app:v1

docker images

docker inspect arunkumar1129/python-app:v1

sudo netstat -tulpn | grep 5000

docker run -d -p 8080:5000 arunkumar1129/python-app:v1

docker ps -a
```

Deployment Status: SUCCESSFUL
Image Source: Docker Hub
Repository: arunkumar1129/python-app
Tag: v1
Container Port: 5000
Host Port: 8080


[![IMG-20260612-WA0011.jpg](https://i.postimg.cc/KzBRwvNG/IMG-20260612-WA0011.jpg)](https://postimg.cc/N9GsrtSS)
[![IMG-20260612-WA0012.jpg](https://i.postimg.cc/50L6TN30/IMG-20260612-WA0012.jpg)](https://postimg.cc/gXcz6p1F)
[![IMG-20260612-WA0013.jpg](https://i.postimg.cc/q79N1C8T/IMG-20260612-WA0013.jpg)](https://postimg.cc/QBJNtC44)

