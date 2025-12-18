# Helm Chart Installation Guide

## Prerequisites

1. **Helm installed** (3.0+)
   ```bash
   helm version
   ```

2. **kubectl configured** and pointing to your Kubernetes cluster
   ```bash
   kubectl cluster-info
   kubectl config current-context
   ```

3. **Namespace ready** (optional - chart creates it)
   ```bash
   kubectl get namespace humor-game || echo "Namespace will be created"
   ```

## Installation Methods

### Method 1: Default Installation

Install with default values (extracted from your base manifests):

```bash
helm install humor-game-helm-chart ./helm-chart \
  --namespace humor-game \
  --create-namespace
```

**What this does:**
- Creates namespace: `humor-game`
- Deploys: backend, frontend, postgres, redis
- Creates: configmap, secrets, pvc
- All values from `values.yaml` (extracted from base/)

**Verify:**
```bash
kubectl get all -n humor-game
helm status humor-game-helm-chart -n humor-game
```

---

### Method 2: Development Environment

Deploy to dev with development-specific values:

```bash
helm install humor-game-helm-chart ./helm-chart \
  -f values-dev.yaml \
  --namespace humor-game-dev \
  --create-namespace
```

**Differences from default:**
- Namespace: `humor-game-dev`
- Image pull policy: `Never` (local images)
- 1 replica per service
- Lower resource requests/limits

---

### Method 3: QA Environment

Deploy to QA with scaled resources:

```bash
helm install humor-game-helm-chart ./helm-chart \
  -f values-qa.yaml \
  --namespace humor-game-qa \
  --create-namespace
```

**Differences:**
- Namespace: `humor-game-qa`
- Image pull policy: `Always` (pull from registry)
- 2 replicas per service (higher availability)
- QA-specific configurations
- Increased resource limits

---

### Method 4: Production Environment

Deploy to production with maximum resilience:

```bash
helm install humor-game-helm-chart ./helm-chart \
  -f values-prod.yaml \
  --namespace humor-game-prod \
  --create-namespace
```

**Differences:**
- Namespace: `humor-game-prod`
- Image pull policy: `Always`
- 3 replicas per service (HA)
- Named image tags (not `latest`)
- Fast SSD storage class for postgres
- Higher resource requests/limits
- Production URLs and CORS settings

---

### Method 5: Custom Override

Install with custom value overrides:

```bash
helm install humor-game-helm-chart ./helm-chart \
  --set backend.image.repository=myregistry.azurecr.io/backend \
  --set backend.image.tag=v1.2.3 \
  --set backend.replicaCount=5 \
  --set namespace=custom-ns \
  --namespace custom-ns \
  --create-namespace
```

---

## Pre-Installation Checks

### 1. Validate Chart Syntax
```bash
helm lint ./helm-chart
```

Expected output:
```
==> Linting ./helm-chart
[OK] Chart is well-formed
```

### 2. Preview Rendered Manifests
```bash
helm template humor-game-helm-chart ./helm-chart --namespace humor-game
```

Save to file for review:
```bash
helm template humor-game-helm-chart ./helm-chart > manifests.yaml
cat manifests.yaml
```

### 3. Dry-Run Install
```bash
helm install humor-game-helm-chart ./helm-chart \
  --namespace humor-game \
  --create-namespace \
  --dry-run \
  --debug
```

### 4. Check Cluster Resources
```bash
kubectl top nodes
kubectl get pv
kubectl get storageclass
```

---

## Step-by-Step Installation

### Step 1: Create Namespace
```bash
kubectl create namespace humor-game
# OR let helm create it automatically with --create-namespace
```

### Step 2: Validate Chart
```bash
cd helm-chart
helm lint .
```

### Step 3: Dry-Run
```bash
helm install humor-game-helm-chart . \
  --namespace humor-game \
  --dry-run \
  --debug
```

### Step 4: Install Release
```bash
helm install humor-game-helm-chart . \
  --namespace humor-game \
  --create-namespace
```

### Step 5: Verify Installation
```bash
# Check release status
helm status humor-game-helm-chart -n humor-game

# Check all resources
kubectl get all -n humor-game

# Check specific resources
kubectl get deployments -n humor-game
kubectl get services -n humor-game
kubectl get configmaps -n humor-game
kubectl get secrets -n humor-game
kubectl get pvc -n humor-game
```

### Step 6: Watch Pods Starting
```bash
kubectl get pods -n humor-game -w
```

### Step 7: Check Pod Logs
```bash
# Backend pod
kubectl logs -n humor-game deployment/backend -f

# Frontend pod
kubectl logs -n humor-game deployment/frontend -f

# Postgres pod
kubectl logs -n humor-game deployment/postgres -f

# Redis pod
kubectl logs -n humor-game deployment/redis -f
```

### Step 8: Test Connectivity
```bash
# Port forward to backend
kubectl port-forward -n humor-game svc/backend 3001:3001 &

# Test backend health
curl http://localhost:3001/health

# Port forward to frontend
kubectl port-forward -n humor-game svc/frontend 80:80 &

# Test frontend
curl http://localhost:80
```

---

## Upgrading Installation

### Update Chart Version
Update `Chart.yaml` version (semantic versioning):
```yaml
version: 0.2.0  # Changed from 0.1.0
```

### Upgrade Release
```bash
helm upgrade humor-game-helm-chart ./helm-chart \
  --namespace humor-game
```

### Upgrade with New Values
```bash
helm upgrade humor-game-helm-chart ./helm-chart \
  --namespace humor-game \
  --set backend.image.tag=v2.0.0 \
  --set backend.replicaCount=4
```

### Upgrade with Values File
```bash
helm upgrade humor-game-helm-chart ./helm-chart \
  -f values-prod.yaml \
  --namespace humor-game-prod
```

### Check Upgrade History
```bash
helm history humor-game-helm-chart -n humor-game
```

### Rollback to Previous Release
```bash
helm rollback humor-game-helm-chart 1 -n humor-game  # Rollback to revision 1
```

---

## Post-Installation Configuration

### 1. Update ConfigMap (if needed)
```bash
kubectl edit configmap humor-game-config -n humor-game
```

Then restart pods:
```bash
kubectl rollout restart deployment/backend -n humor-game
kubectl rollout restart deployment/frontend -n humor-game
```

### 2. Update Secrets (if needed)
```bash
kubectl edit secret humor-game-secrets -n humor-game
```

Then restart pods:
```bash
kubectl rollout restart deployment/backend -n humor-game
```

### 3. Scale Deployments
```bash
kubectl scale deployment backend --replicas=5 -n humor-game
```

Or use helm upgrade:
```bash
helm upgrade humor-game-helm-chart ./helm-chart \
  --set backend.replicaCount=5 \
  -n humor-game
```

---

## Uninstalling

### Remove Release
```bash
helm uninstall humor-game-helm-chart -n humor-game
```

### Remove Namespace (optional)
```bash
kubectl delete namespace humor-game
```

### Verify Removal
```bash
helm list -n humor-game
kubectl get all -n humor-game
```

---

## Troubleshooting

### Problem: Chart Lint Fails
```bash
helm lint ./helm-chart -v 9
```

### Problem: Template Rendering Errors
```bash
helm template humor-game-helm-chart ./helm-chart --debug
```

### Problem: Pod Won't Start
```bash
kubectl describe pod -n humor-game <pod-name>
kubectl logs -n humor-game <pod-name>
```

### Problem: ConfigMap/Secret Not Applied
```bash
# Check if mounted
kubectl get configmap -n humor-game
kubectl get secret -n humor-game

# Restart pods to pick up changes
kubectl rollout restart deployment/backend -n humor-game
```

### Problem: PVC Pending
```bash
kubectl describe pvc postgres-pvc -n humor-game
kubectl get pv
kubectl get storageclass
```

### Problem: Service Not Accessible
```bash
kubectl get svc -n humor-game
kubectl describe svc backend -n humor-game
kubectl get endpoints -n humor-game
```

---

## Common Commands Reference

| Command | Purpose |
|---------|---------|
| `helm lint ./helm-chart` | Validate chart syntax |
| `helm template my-app ./helm-chart` | Preview rendered manifests |
| `helm install my-app ./helm-chart -n ns` | Install release |
| `helm upgrade my-app ./helm-chart -n ns` | Update release |
| `helm rollback my-app -n ns` | Rollback to previous version |
| `helm uninstall my-app -n ns` | Remove release |
| `helm status my-app -n ns` | Check release status |
| `helm get values my-app -n ns` | View current values |
| `helm history my-app -n ns` | View release history |
| `helm list -n ns` | List all releases |

---

## Next Steps

1. **Monitor your deployment**
   ```bash
   kubectl get pods -n humor-game -w
   ```

2. **Access applications**
   - Backend: `kubectl port-forward svc/backend 3001:3001 -n humor-game`
   - Frontend: `kubectl port-forward svc/frontend 80:80 -n humor-game`

3. **Configure ingress** (if needed)
   - Update templates to include Ingress resource

4. **Set up monitoring** (optional)
   - Use prometheus annotations already in deployments

5. **Backup and disaster recovery**
   - Store helm release configs in version control
   - Document custom values files

---

**Installation Complete!** Your Helm chart is now deployed and running.
