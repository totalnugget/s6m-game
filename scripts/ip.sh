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

CLUSTER_STATUS=$(minikube_cluster_status $CLUSTER_NAME)

HOST=false

while [[ "$@" != "" ]]; do
    case $1 in
        -h | --host ) HOST=true
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ $CLUSTER_STATUS -eq 2 ]; then
    SEVER_URL=$(minikube ip -p $CLUSTER_NAME)
    if [ "$HOST" = true ] ; then
        echo $SEVER_URL
    else
        echo "http://$SEVER_URL"
    fi
else
    echo "Minikube is not running"
fi
