#!/usr/bin/env bash
set -euxo pipefail
# create kind cluster
# kind create cluster --config kind.yaml
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
# install nginx ingress controller
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.config.worker-processes=2 \
  --wait --wait-for-jobs
# allow unauthenticated access to oidc endpoint
kubectl create clusterrolebinding oidc-reviewer  \
  --clusterrole=system:service-account-issuer-discovery \
  --group=system:unauthenticated
# install dex
helm repo add dex https://charts.dexidp.io --force-update
helm upgrade --install \
  dex dex/dex \
  --namespace dex \
  --create-namespace \
  -f dex.values.yaml \
  --wait \
  --wait-for-jobs
