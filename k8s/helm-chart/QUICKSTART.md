# Quick Start Guide

### Files Created

```
helm-chart/
├── Chart.yaml                    # Chart metadata (name, version)
├── values.yaml                   # Default values (extracted from base)
├── values-dev.yaml              # Development environment overrides
├── values-qa.yaml               # QA environment overrides
├── values-prod.yaml             # Production environment overrides
├── CONVERSION_GUIDE.md           # Comprehensive guide (read this!)
├── README.md                     # Basic usage
├── rendered-manifests.yaml       # Sample output (for reference)
└── templates/
    ├── _helpers.tpl
    ├── namespace.yaml
    ├── configmap.yaml           # humor-game-config
    ├── secrets.yaml             # humor-game-secrets
    ├── pvc.yaml                 # postgres-pvc
    ├── postgres-init.yaml       # Postgres SQL ConfigMap
    ├── backend-deployment.yaml
    ├── backend-service.yaml
    ├── frontend-deployment.yaml
    ├── frontend-service.yaml
    ├── postgres-deployment.yaml
    ├── postgres-service.yaml
    ├── redis-deployment.yaml
    └── redis-service.yaml
```

## Quick Commands

### 1. Preview Rendered Templates
```bash
cd helm-chart
helm template humor-game-helm-chart . --namespace humor-game
```

### 2. Dry-Run Install (No changes to cluster)
```bash
helm install humor-game-helm-chart ./helm-chart \
  --namespace humor-game \
  --create-namespace \
  --dry-run \
  --debug
```

### 3. Install to Cluster
```bash
helm install humor-game-helm-chart ./helm-chart \
  --namespace humor-game \
  --create-namespace
```

### 4. Verify Installation
```bash
kubectl get all -n humor-game
kubectl logs -n humor-game deployment/backend
```

### 5. Upgrade (Change values/images)
```bash
helm upgrade humor-game-helm-chart ./helm-chart \
  --namespace humor-game \
  --set backend.image.tag=v2.0.0
```

### 6. Uninstall
```bash
helm uninstall humor-game-helm-chart -n humor-game
```

## Environment-Specific Deployments

### Dev
```bash
helm install humor-game-helm-chart ./helm-chart \
  -f values-dev.yaml \
  --namespace humor-game-dev \
  --create-namespace
```

### QA
```bash
helm install humor-game-helm-chart ./helm-chart \
  -f values-qa.yaml \
  --namespace humor-game-qa \
  --create-namespace
```

### Production
```bash
helm install humor-game-helm-chart ./helm-chart \
  -f values-prod.yaml \
  --namespace humor-game-prod \
  --create-namespace
```

## What's Different from Kustomize

| Feature | Kustomize | Helm |
|---------|-----------|------|
| **Distribution** | Git patches | Helm package (.tgz) |
| **Versioning** | Git tags | Chart version (semver) |
| **Dependencies** | Manual | Helm dependencies |
| **Package Repo** | None | Helm Hub, private repos |
| **Release Management** | Manual | helm install/upgrade/rollback |
| **Values** | kustomization.yaml | values.yaml |

## Support

- **Helm Docs**: https://helm.sh/docs/
- **Kubernetes**: https://kubernetes.io/docs/
- **Template Debugging**: `helm template --debug`
