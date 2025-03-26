#!/usr/bin/env bash
set -euxo pipefail
# install cert-manager
helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  --set crds.enabled=true \
  --wait \
  --wait-for-jobs
# bootstrap selfsigned issuer
kubectl apply -f clusterissuer.yaml
# allow unauthenticated access to oidc endpoint
kubectl create clusterrolebinding oidc-reviewer  \
  --clusterrole=system:service-account-issuer-discovery \
  --group=system:unauthenticated
# install dex
helm repo add dex https://charts.dexidp.io --force-update
helm install \
  dex dex/dex \
  --namespace dex \
  --create-namespace \
  -f dex.values.yaml \
  --wait \
  --wait-for-jobs
