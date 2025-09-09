# XOps Microchallenge #7 – Secrets Management with Kubernetes Secrets 
In this challenge, i have used **Kubernetes Secrets** to securely inject sensitive information into pods   

---

## 🎯 Objective  
Securely store and inject fake database credentials (`DB_USER`, `DB_PASSWORD`) into a pod using Kubernetes Secrets, and verify they are accessible inside the container.  


## 🔧 Step-by-Step Challenge  

### 1️⃣ Create a Kubernetes Secret  
bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=testuser \
  --from-literal=DB_PASSWORD=s3cr3tP@ss
## verify the secrets been created
kubectl get secrets
kubectl describe secret db-credentials
kubectl get secret db-credentials -o yaml
## Inject Secret as environment Variable
kubectl apply -f k8s/secret-env-pod.yaml
kubectl get pods

## Verify the secrets inside the container
kubectl exec -it secret-env-pod -c nginx -- sh
echo $DB_USER
echo $DB_PASSWORD

## Inject Secret as Mounted Files (Optional)
kubectl apply -f k8s/secret-vol-pod.yaml
kubectl get pods

## verify secrets from file 
kubectl exec -it secret-vol-pod -- sh -c \
"ls -l /etc/secrets; \
echo '--- DB_USER ---'; cat /etc/secrets/DB_USER; \
echo '--- DB_PASSWORD ---'; cat /etc/secrets/DB_PASSWORD"

