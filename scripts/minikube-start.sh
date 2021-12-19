#!/usr/bin/env bash
# Starts a minikube cluster

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

CLUSTER_STATUS=$(minikube_cluster_status $CLUSTER_NAME)

if [ $CLUSTER_STATUS -eq 0 ]; then
    # Determine VM driver
    VM_DRIVER_PARAMS=

    if [[ $IS_WSL -eq 1 ]]; then
        # Don't use hypervisor on WSL
        VM_DRIVER_PARAMS=--vm-driver=none
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Use KVM2 driver on Linux
        VM_DRIVER_PARAMS=--vm-driver=kvm2
    elif [[ "$OSTYPE" == *"darwin"* ]]; then
        # Use hyperkit driver on Mac
        VM_DRIVER_PARAMS=--vm-driver=hyperkit
    fi

    # Determine number of CPUs used (defaults to 4 if not configured)
    CPUS=$(minikube config view -p $CLUSTER_NAME | awk '/cpus/ {print $3}')
    CPUS=${CPUS:-$CLUSTER_CPU}

    # Determine amount of memory used (defaults to 16000 if not configured)
    MEMORY=$(minikube config view -p $CLUSTER_NAME | awk '/memory/ {print $3}')
    MEMORY=${MEMORY:-$CLUSTER_MEMORY}

    # Determine disk size used (defaults to 64GB if not configured)
    DISK_SIZE=$(minikube config view -p $CLUSTER_NAME | awk '/disk-size/ {print $3}')
    DISK_SIZE=${DISK_SIZE:-$CLUSTER_DISKSIZE}

    minikube start \
    -p $CLUSTER_NAME \
    --kubernetes-version=v1.19.9 \
    --cpus=$CPUS \
    --memory=$MEMORY \
    --disk-size=$DISK_SIZE \
    --ports=8080:80 \
    $VM_DRIVER_PARAMS

    source ${ROOT_PATH}/scripts/lib/minikube-init.sh
elif [ $CLUSTER_STATUS -eq 1 ]; then
   minikube start -p $CLUSTER_NAME
elif [ $CLUSTER_STATUS -eq 2 ]; then
    echo "$CLUSTER_NAME is already running!"
fi

kubectl config use-context $CLUSTER_NAME
kubectl config set-context  --current --namespace $DEFAULT_NAMESPACE
