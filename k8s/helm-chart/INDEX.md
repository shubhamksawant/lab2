# Helm Chart - Complete Index


## 📚 Documentation Files (START HERE)

Read these in order:

1. **QUICKSTART.md** (4 KB)
   - Quick 3-step setup
   - Common commands
   - Basic examples
   - **👈 START HERE for quick deployment**

2. **INSTALLATION_GUIDE.md** (8.5 KB)
   - Step-by-step installation instructions
   - Multiple installation methods (dev/qa/prod)
   - Pre-installation checks
   - Troubleshooting guide
   - Post-installation configuration

## 📁 Chart Files

### Metadata
- **Chart.yaml** (159 B)
  - Chart name, version, description
  - Current version: 0.1.0

### Values Files
- **values.yaml** (2.3 KB) - Default values 
- **values-dev.yaml** (868 B) - Development overrides
- **values-qa.yaml** (1.4 KB) - QA overrides
- **values-prod.yaml** (1.5 KB) - Production overrides

### Templates (`templates/` directory)
All 14 resource templates:
- `_helpers.tpl` - Helper functions
- `namespace.yaml` - Kubernetes namespace
- `configmap.yaml` - humor-game-config
- `secrets.yaml` - humor-game-secrets
- `pvc.yaml` - postgres-pvc
- `postgres-init.yaml` - Postgres SQL init
- `backend-deployment.yaml`
- `backend-service.yaml`
- `frontend-deployment.yaml`
- `frontend-service.yaml`
- `postgres-deployment.yaml`
- `postgres-service.yaml`
- `redis-deployment.yaml`
- `redis-service.yaml`


## 🚀 Quick Start (3 Commands)

### 1. Validate
```bash
helm lint ./helm-chart
```

### 2. Preview
```bash
helm template humor-game-helm-chart ./helm-chart
```

### 3. Install
```bash
helm install humor-game-helm-chart ./helm-chart \
  --namespace humor-game \
  --create-namespace
```


## 📋 Customization Quick Reference

### Change Image Tag
```bash
helm upgrade humor-game-helm-chart ./helm-chart \
  --set backend.image.tag=v2.0.0
```

### Scale Replicas
```bash
helm upgrade humor-game-helm-chart ./helm-chart \
  --set backend.replicaCount=3
```

### Update ConfigMap
```bash
helm upgrade humor-game-helm-chart ./helm-chart \
  --set configmap.data.NODE_ENV=production
```

### Deploy to Different Environment
```bash
# Development
helm install humor-game-helm-chart ./helm-chart -f values-dev.yaml -n dev --create-namespace

# QA
helm install humor-game-helm-chart ./helm-chart -f values-qa.yaml -n qa --create-namespace

# Production
helm install humor-game-helm-chart ./helm-chart -f values-prod.yaml -n prod --create-namespace
```


## 🔑 Key Files at a Glance

| File | Purpose | When to Use |
|------|---------|-------------|
| Chart.yaml | Chart metadata | Version control, publishing |
| values.yaml | Default values | Edit for global changes |
| values-dev.yaml | Dev environment | Deploy to dev: `-f values-dev.yaml` |
| values-qa.yaml | QA environment | Deploy to QA: `-f values-qa.yaml` |
| values-prod.yaml | Prod environment | Deploy to prod: `-f values-prod.yaml` |
| templates/* | Resource templates | Usually don't edit directly |
| QUICKSTART.md | Quick reference | Getting started |
| INSTALLATION_GUIDE.md | Detailed steps | Full deployment walkthrough |
| CONVERSION_GUIDE.md | Technical details | Understanding the conversion |



## 💡 Pro Tips

1. **Always validate before install**
   ```bash
   helm lint ./helm-chart
   helm template my-app ./helm-chart --debug
   ```

2. **Use dry-run to preview changes**
   ```bash
   helm install my-app ./helm-chart --dry-run --debug
   ```

3. **Keep environment values in version control**
   - `values-dev.yaml` ✅ Commit to git
   - `values-qa.yaml` ✅ Commit to git
   - `values-prod.yaml` ✅ Commit to git
   - Secrets data ❌ Use external management

4. **Tag your releases**
   - Update Chart.yaml version
   - Use semantic versioning (1.0.0, 1.0.1, 1.1.0)

5. **Check history and rollback**
   ```bash
   helm history my-app -n humor-game
   helm rollback my-app 1 -n humor-game
   ```

## 🆘 Need Help?

1. **Chart validation errors?**
   ```bash
   helm lint ./helm-chart -v 9
   ```

2. **Template rendering issues?**
   ```bash
   helm template humor-game-helm-chart ./helm-chart --debug
   ```

3. **Installation problems?**
   - Check INSTALLATION_GUIDE.md Troubleshooting section
   - Review pre-installation checks
   - Check pod logs: `kubectl logs -n humor-game deployment/backend`

4. **Need to customize?**
   - Modify values-*.yaml files
   - Use `--set` flags for quick overrides

## 📞 References

- **Official Helm Docs**: https://helm.sh/docs/
- **Chart Template Guide**: https://helm.sh/docs/chart_template_guide/
- **Kubernetes Docs**: https://kubernetes.io/docs/

---

## 🎉 Ready to Deploy!

1. Read **QUICKSTART.md** for immediate deployment
2. Follow **INSTALLATION_GUIDE.md** for detailed steps

