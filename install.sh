#!/usr/bin/env bash
set -euxo pipefail
# create kind cluster
# kind create cluster --config kind.yaml

# install autocert
helm upgrade --install autocert autocert \
  --namespace autocert --create-namespace \
  --repo https://smallstep.github.io/helm-charts \
  --wait --wait-for-jobs

# allow unauthenticated access to oidc endpoint
kubectl create clusterrolebinding oidc-reviewer  \
  --clusterrole=system:service-account-issuer-discovery \
  --group=system:unauthenticated

# install dex
kubectl create namespace dex
kubectl label  namespace dex autocert.step.sm=enabled
helm upgrade --install dex dex \
  --repo https://charts.dexidp.io \
  --namespace dex --create-namespace \
  -f dex.values.yaml \
  --wait --wait-for-jobs

# install nginx ingress controller
# helm upgrade --install ingress-nginx ingress-nginx \
#   --repo https://kubernetes.github.io/ingress-nginx \
#   --namespace ingress-nginx --create-namespace \
#   --set controller.service.type=NodePort \
#   --set controller.config.worker-processes=2 \
#   --wait --wait-for-jobs
# install jumpstarter
helm upgrade --install jumpstarter oci://quay.io/jumpstarter-dev/helm/jumpstarter \
  --version=0.5.0-114-g530557a \
  --namespace jumpstarter-lab --create-namespace \
  -f jumpstarter.values.yaml \
  --wait --wait-for-jobs
