```
root@k3s-master:~# history
    1  cat /etc/hosts
    2  sudo tee -a /etc/hosts <<EOF
    3  192.168.142.11  k3s-master.sece.com  k3s-master
    4  192.168.142.12  k3s-worker1.sece.com k3s-worker1
    5  192.168.142.13  k3s-worker2.sece.com k3s-worker2
    6  EOF
    7  >
    8  cat /etc/hosts
    9  sudo tee -a /etc/hosts <<EOF
   10  192.168.142.11  k3s-master.sece.com  k3s-master
   11  192.168.142.12  k3s-worker1.sece.com k3s-worker1
   12  192.168.142.13  k3s-worker2.sece.com k3s-worker2
   13  EOF
   14  hostman
   15  hostname
   16  sudo ufw status
   17  curl -sfL https://get.k3s.io | sh -
   18  sudo systemctl status k3s
   19  sudo k3s kubectl get nodes
   20  cat /var/lib/rancher/k3s/server/node-token
   21  curl -sfL https://get.k3s.io | K3S_URL=https://k3s-master.sece.com:6443 K3S_TOKEN="K10d77c075b4c37a70ffa36d11812bbffdbf8b0f05f75a2ad0646d2d9122ad43fe7::server:a0f34418d9bc7f87186be26a7f22ac89
   22  " sh -
   23  sudo systemctl status k3s-agent
   24  k3s kubectl get nodes
   25  systemctl status k3s-agent
   26  sudo k3s kubectl get nodes
   27  hostname
   28  sudo hostnamectl set-hostname k3s-master.sece.com
   29  hostname
   30  bash
   31  bash
   32  sudo k3s kubectl get nodes
   33  sudo systemctl status k3s
   34  sudo k3s kubectl get nodes
   35   kubectl describe deployment nginx-deployment
   36  kubectl get deploy,rs,po -o wide -w
   37  watch kubectl get deploy,rs,po -o wide
   38  vi nginx-rs.yaml
   39  kubectl get rs
   40  kubectl get nginx-rs
   41  kubectl apply -f nginx-rs.yaml
   42  kubectl get nginx-rs
   43  kubectl get rs
   44  kubectl get po -l app=nginx
   45  vi nginx-deployment.yaml
   46  kubectl apply -f nginx-deployment.yaml
   47  kubectl get deploy
   48  kubectl get po -o wide
   49  kubectl describe deploy nginx-deployment
   50  kubectl get po
   51  cat nginx-replicaset
   52  cat nginx-deployment
   53  cat nginx-deployment.yaml
   54  vi nginx-deployment.yaml
   55  kubectl apply -f nginx-deployment.yaml
   56  cat nginx-deployment.yaml
   57  kubectl get rs
   58  kubectl describe deploy nginx-deployment
   59  kubectl get po -o wide
   60  kubectl describe deploy nginx-deployment
   61  kubectl get deploy,rs,po -o wide
   62  kubectl set image deployment/nginx-deployment nginx=nginx:1.26
   63  kubectl get deploy,rs,po -o wide
   64  kubectl describe deploy nginx-deployment
   65  kubectl rollout status deployment/nginx-deployment --revision=2
   66  kubectl get deploy,rs,po -o wide
   67  kubectl get rs
   68  kubectl describe deploy nginx-deployment
   69  kubectl apply -f nginx-deployment.yaml
   70  kubectl get rs
   71  kubectl get deploy,rs,po -o wide
   72  kubectl describe deploy nginx-deployment
   73  kubectl rollout status deployment/nginx-deployment
   74  kubectl describe deployment nginx-deployment
   75  kubectl describe deployment nginx-deployment | grep Image
   76  kubectl rollout undo deployment/nginx-deployment
   77  kubectl rollout status deployment/nginx-deployment
   78  kubectl describe deployment nginx-deployment | grep Image
   79  kubectl get deploy
   80  kubectl describe deploy
   81  kubectl describe deploy nginx-deployment
   82  kubectl describe deploy nginx-deployment | grep Image
   83  kubectl describe deploy nginx-deployment | grep Image
   84  kubectl  get po
   85  kubectl  get po nginx-deployment-8574879789-2chfw
   86  kubectl get po
   87  kubectl get po nginx-deployment-8574879789-2chfw
   88  kubectl delete po nginx-deployment-8574879789-2chfw
   89  kubectl get po
   90  kubectl describe deploy nginx-deployment | grep Image
   91  kubectl describe deploy nginx-deployment
   92  kubectl get deploy,rs,po -o wide
   93  vi deployment.yaml
   94  vi nginx-deployment.yaml
   95  kubectl apply -f nginx- deployment.yaml
   96  kubectl apply -f nginx-deployment.yaml
   97  kubectl rollout status deployment/nginx-deployment
   98  kubectl get deployment
   99  kubectl describe deployment nginx-deployment
  100  vi nginx-deployment.yaml
  101  kubectl apply -f deploy nginx-deployment
  102  kubectl apply -f deploy nginx-deployment.yaml
  103  kubectl apply -f nginx-deployment.yaml
  104  cat nginx-deployment.yaml
  105  kubectl rollout history deployment/nginx-deployment
  106  kubectl rollout history deployment/nginx-deployment --revision=1
  107  kubectl rollout history deployment/nginx-deployment --revision=4
  108  kubectl rollout pause deployment/nginx-deployment
  109  kubectl get deployment
  110  kubectl describe deployment nginx-deployment
  111  kubectl set image deployment/nginx-deployment nginx=nginx:1.27
  112  kubectl rollout resume deployment/nginx-deployment
  113  kubectl history
  114  history
