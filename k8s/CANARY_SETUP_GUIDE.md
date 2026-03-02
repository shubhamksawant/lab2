# Quick Setup Guide for Argo Rollouts Canary Deployment

## Overview
This guide explains the file structure and how to enable canary deployments with Argo Rollouts for your humor-game application.

## File Structure

### New Files Created:
```
k8s/
├── helm-chart/
│   ├── templates/
│   │   ├── backend-rollout.yaml       # Rollout resource for backend
│   │   ├── frontend-rollout.yaml      # Rollout resource for frontend
│   │   ├── analysis-template.yaml     # AnalysisTemplate for metrics validation
│   │   └── canary-services.yaml       # Canary & Stable services for traffic split
│   ├── values-canary.yaml             # Canary-specific configuration
│   └── Chart.yaml                     # (Updated) Added Argo Rollouts dependency
│
├── argo-rollouts/
│   └── argo-rollouts-controller.yaml  # Argo Rollouts controller deployment
│
└── argocd-config/applications/
    └── argocd-app-canary.yaml         # ArgoCD Application for canary env
```

### Modified Files:
1. **values.yaml** - Added `rolloutEnabled` and `canary` configuration structure
2. **values-dev.yaml** - Enabled canary with dev-friendly 3-5min steps
3. **values-qa.yaml** - Enabled canary with qa-appropriate 5min steps
4. **values-prod.yaml** - Enabled canary with conservative 10min+ steps
5. **Chart.yaml** - Added Argo Rollouts helm chart dependency
6. **argocd-app-dev.yaml** - Added `ignoreDifferences` for Rollout resources
7. **argocd-app-qa.yaml** - Added `ignoreDifferences` for Rollout resources
8. **argocd-app-prod.yaml** - Added `ignoreDifferences` for Rollout resources

## Installation Steps

### Step 1: Install Argo Rollouts Controller
```bash
# Apply the controller to your cluster
kubectl apply -f k8s/argo-rollouts/argo-rollouts-controller.yaml

# Verify installation
kubectl get deployment -n argo-rollouts
kubectl get crd | grep rollout
```

### Step 2: Update Helm Dependencies
```bash
cd k8s/helm-chart
helm dependency update
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### Step 3: Deploy Using ArgoCD

**For Canary Environment:**
```bash
kubectl apply -f k8s/argocd-config/applications/argocd-app-canary.yaml
```

**For Dev with Canary:**
```bash
# Update argocd-app-dev.yaml to include values-dev.yaml values for canary
kubectl apply -f k8s/argocd-config/applications/argocd-app-dev.yaml
```

### Step 4: Verify Deployment
```bash
# Watch rollout progress
kubectl argo rollouts get rollout backend -n humor-game-canary --watch

# Check analysis runs
kubectl get analysisruns -n humor-game-canary

# View rollout metrics
# ArgoCD UI will show canary deployment progress
# Argo Rollouts UI available at: kubectl port-forward -n argo-rollouts svc/argo-rollouts-dashboard 3100:3100
```

## Configuration Options

### Canary Strategy (Percentage-Based)
Each environment has different canary steps:

**Dev (Fast Validation - 11 minutes total):**
```yaml
steps:
- weight: 25    # 25% traffic for 3 minutes
- weight: 50    # 50% traffic for 3 minutes
- weight: 100   # 100% traffic for 3 minutes
```

**QA (Moderate - 17 minutes total):**
```yaml
steps:
- weight: 20    # 20% traffic for 5 minutes
- weight: 50    # 50% traffic for 5 minutes
- weight: 100   # 100% traffic for 5 minutes
```

**Prod (Conservative - 40+ minutes total):**
```yaml
steps:
- weight: 10    # 10% traffic for 10 minutes
- weight: 25    # 25% traffic for 10 minutes
- weight: 50    # 50% traffic for 10 minutes
- weight: 100   # 100% traffic for 5 minutes
```

### Metrics-Based Validation
Analysis runs automatically validate each canary step:

**Backend Metrics:**
- Error Rate: Acceptable threshold varies by environment (0.5% to 5%)
- Latency P95: Target < 500-1000ms
- Request Count: Monitors traffic volume

**Frontend Metrics:**
- Error Rate: Acceptable threshold (0.5% to 5%)
- Request Count: Monitors traffic volume

### Automatic Rollback
If metrics exceed thresholds, rollout automatically rolls back to stable version.

## Enable/Disable Canary

### Enable Canary for a Service:
```yaml
# In values-<env>.yaml
backend:
  rolloutEnabled: true  # Switch from Deployment to Rollout
  canary:
    enabled: true       # Enable canary strategy
```

### Disable Canary (fallback to regular Deployment):
```yaml
backend:
  rolloutEnabled: false  # Use standard Deployment
  canary:
    enabled: false
```

## Monitoring Canary Deployments

### Using ArgoCD UI:
1. Go to Applications → humor-game-canary
2. See Progressive Deployment status
3. View canary pod replicas and traffic split

### Using kubectl:
```bash
# Watch canary progress
kubectl argo rollouts get rollout backend -n humor-game-canary --watch

# View specific step
kubectl describe rollout backend -n humor-game-canary

# Check analysis runs
kubectl get analysisruns -n humor-game-canary
kubectl logs -n humor-game-canary <analysis-run-pod>
```

### Using Prometheus + Grafana:
- Query `http_requests_total` to track error rates
- Query `http_request_duration_seconds` for latency
- Dashboard included in `k8s/monitoring/`

## Troubleshooting

### Rollout Stuck in Canary:
```bash
# Check analysis template
kubectl get analysistemplates -n humor-game-canary

# Check prometheus connectivity
kubectl logs -n argo-rollouts deployment/argo-rollouts | grep "prometheus"

# Manually complete rollout
kubectl argo rollouts promote backend -n humor-game-canary
```

### High Error Rate During Canary:
```bash
# Automatic rollback triggers at threshold
# Check what failed:
kubectl get analysisruns -n humor-game-canary -o jsonpath='{.items[*].status.conditions[*]}'

# Revert deployment
kubectl argo rollouts abort rollout backend -n humor-game-canary
```

## Multi-Environment Rollout Strategy

### Dev: Aggressive Testing
- Fast canary steps (3-5 min each)
- Aggressive validation (5% error threshold)
- Good for catching bugs early

### QA: Thorough Validation
- Moderate canary steps (5 min each)
- Stricter metrics (2% error threshold)
- Aligns with smoke testing duration

### Prod: Ultra-Conservative
- Long canary steps (10-60 min each)
- Very strict metrics (0.5% error threshold)
- Includes latency monitoring
- Higher failure limit before rollback

## Next Steps

1. **Update your CI/CD** to build images with proper versioning
2. **Configure Prometheus** metrics scraping for your services
3. **Test canary flow** in dev environment with intentional failures
4. **Set up alerts** in ArgoCD/Argo Rollouts for failed canaries
5. **Document runbooks** for manual interventions if needed

## Additional Resources

- Argo Rollouts Docs: https://argoproj.github.io/argo-rollouts/
- Canary Rollout Examples: https://github.com/argoproj/argo-rollouts/tree/master/examples
- Analysis Metrics: https://argoproj.github.io/argo-rollouts/analysis/
