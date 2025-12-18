Helm chart generated from kustomize base manifests.

How to use:

1. Customize `values.yaml` to match your existing kustomize base files (image names, ports, configmap data, secrets).

2. Render templates locally:

   helm template ./gitops-safe-copy -f ./gitops-safe-copy/values.yaml --namespace $(cat ./gitops-safe-copy/values.yaml | grep namespace | awk '{print $2}')

3. Install into cluster:

   helm install humor-game-helm-chart ./gitops-safe-copy -f ./gitops-safe-copy/values.yaml --namespace $(cat ./gitops-safe-copy/values.yaml | grep namespace | awk '{print $2}')
