#!/usr/bin/env bash

ROOT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]%/*}")" ; pwd )/..

ENV_FILE=$ROOT_PATH/.env

# Export the vars in .env into your shell:
if [[ "$OSTYPE" == *"darwin"* ]]; then
    export $(egrep -v '^#' $ENV_FILE | xargs)
else
    source $ENV_FILE
fi


# command
kubectl create secret generic -n core command-db-auth --from-literal=POSTGRES_USER=$COMMAND_DB_USERNAME --from-literal=POSTGRES_PASSWORD=$COMMAND_DB_PASSWORD

# village
kubectl create secret generic -n core village-db-auth --from-literal=POSTGRES_USER=$VILLAGE_DB_USERNAME --from-literal=POSTGRES_PASSWORD=$VILLAGE_DB_PASSWORD


# Keycloak
kubectl create secret generic -n core realm-secret --from-file=$ROOT_PATH/deployments/keycloak/data/realm.json
kubectl create secret generic -n core keycloak-auth --from-literal=username=$KEYCLOAK_USERNAME --from-literal=password=$KEYCLOAK_PASSWORD
kubectl create secret generic -n core keycloak-db-auth --from-literal=POSTGRES_USER=$KEYCLOAK_DB_USERNAME --from-literal=POSTGRES_PASSWORD=$KEYCLOAK_DB_PASSWORD

# rabbitmq secrets
echo -n $(echo -n $RABBITMQ_PASSWORD | base64) > $ROOT_PATH/deployments/rabbitmq/.env.dev
kubectl create secret generic -n core rabbitmq-user --from-literal=rabbitmq-password=$RABBITMQ_PASSWORD
kubectl create secret generic -n core rabbitmq-erlang --from-literal=rabbitmq-erlang-cookie=$(head -c 48 /dev/random | base64)
