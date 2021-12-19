#!/usr/bin/env bash
set -o errexit

# Get project root path
ROOT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../..

# create default namespace
kubectl create namespace $DEFAULT_NAMESPACE || true
kubectl config set-context  --current --namespace $DEFAULT_NAMESPACE

# ingress
minikube addons enable ingress -p $CLUSTER_NAME

# helm - don't need helm 
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo add appscode https://charts.appscode.com/stable/
helm repo update

# kubedb --- skip for my project
helm install kubedb-operator --version v0.13.0-rc.0 --namespace kube-system appscode/kubedb
kubectl rollout status -w deployment/kubedb-operator --namespace=kube-system # Wait for tiller pod to be ready
echo "waiting 2 minutes for crds to be ready"
sleep 2m
helm install kubedb-catalog --version v0.13.0-rc.0 --namespace kube-system appscode/kubedb-catalog

# create secrets
source ${ROOT_PATH}/scripts/lib/add_secrets.sh

#  using kip
kip build
kip deploy