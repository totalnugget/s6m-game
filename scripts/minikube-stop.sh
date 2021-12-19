#!/usr/bin/env bash
#
# Starts a k3s cluster (via k3d) with local image registry enabled,
# and with nodes annotated such that Tilt (https://tilt.dev/) can
# auto-detect the registry.

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

# stop cluster if running
CLUSTER_STATUS=$(minikube_cluster_status $CLUSTER_NAME)
if [ $CLUSTER_STATUS -eq  2 ];then
  minikube stop -p $CLUSTER_NAME
fi