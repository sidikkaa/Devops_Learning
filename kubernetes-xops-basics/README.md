# kubernetes-xops-basics

## Objective
Create a local kind cluster, deploy a simple nginx app, and explore k8s control plane.

## Prereqs
- Docker (running). See Docker docs.
- kind (vX.Y.Z) — created cluster `xops-cluster`.
- kubectl (client).

## Steps performed
1. Installed Docker, kind, kubectl.
2. Created cluster:
   - `kind create cluster --name xops-cluster`
   - Output: (paste `kubectl get nodes` here)
3. Deployed app:
   - `kubectl apply -f app.yaml`
   - `kubectl get svc`
   - Screenshot: `screenshots/svc.png`
4. Accessed app:
   - `kubectl port-forward svc/xops-web 8080:80` → http://localhost:8080
   - Screenshot: `screenshots/app.png`
5. Explored control plane:
   - `kubectl -n kube-system get pods`
   - Explain each component in your own words (API Server, etcd, Scheduler, Controller Manager, kubelet, kube-proxy).

## Files
- `app.yaml` — deployment + service manifest
- `screenshots/` — add the screenshots you took

## Clean up
`kind delete cluster --name xops-cluster`
