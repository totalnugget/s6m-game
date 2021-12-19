#!/usr/bin/env bash

set -o errexit

# Export the vars in .env into your shell:
if [[ "$OSTYPE" == *"darwin"* ]]; then
    export $(egrep -v '^#' .env | xargs)
else
    source ./.env
fi

# Get project root path
ROOT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/..

# load libs
source ${ROOT_PATH}/scripts/lib/minikube-functions.sh

# delete cluster
CLUSTER_STATUS=$(minikube_cluster_status $CLUSTER_NAME)
if [ $CLUSTER_STATUS -eq  1 ] || [ $CLUSTER_STATUS -eq  2 ];then
  minikube delete -p $CLUSTER_NAME
fi