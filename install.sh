#!/usr/bin/env bash
set -euxo pipefail
# create kind cluster
kind create cluster --config kind.yaml

# allow unauthenticated access to oidc endpoint
kubectl create clusterrolebinding oidc-reviewer  \
  --clusterrole=system:service-account-issuer-discovery \
  --group=system:unauthenticated || true

# install jumpstarter
helm upgrade --install jumpstarter oci://quay.io/jumpstarter-dev/helm/jumpstarter \
  --version=0.5.0-117-g1b98390 \
  --namespace jumpstarter-lab --create-namespace \
  -f values.yaml \
  --wait --wait-for-jobs

# deploy qemu exporters
kubectl apply -n default -f qemu-exporter-statefulset.yaml
