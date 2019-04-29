#!/bin/sh

note() {
    echo "\033[33m$1\033[m"
}

docker-compose kill
docker-compose rm -f

export VAULT_DEV_ROOT_TOKEN_ID="my-very-big-and-dev-only-token"

docker-compose up -d vault

note "Creating the web policy"
VAULT_URL="http://$(docker-compose port vault 8200)"
curl \
  --request POST \
  --header "X-Vault-Token: $VAULT_DEV_ROOT_TOKEN_ID" \
  --data '{"policy":"path \"secret/data/web/*\" {capabilities = [\"read\"]}"}' \
  $VAULT_URL/v1/sys/policy/web

note "Creating the periodic policy"
curl \
  --request POST \
  --header "X-Vault-Token: $VAULT_DEV_ROOT_TOKEN_ID" \
  --data '{"policy":"path \"auth/token/renew-self\" {capabilities = [\"sudo\"]}"}' \
  $VAULT_URL/v1/sys/policy/periodic

note "Creating the pepper secret"
curl \
  --request POST \
  --header "X-Vault-Token: $VAULT_DEV_ROOT_TOKEN_ID" \
  --data '{"data":{"pepper":"my pepper"}}' \
  $VAULT_URL/v1/secret/data/web/password > /dev/null

note "Creating a new token and using it on webdev"
VAULT_DEV_ROOT_TOKEN_ID=$(curl \
  --request POST \
  --header "X-Vault-Token: $VAULT_DEV_ROOT_TOKEN_ID" \
  $VAULT_URL/v1/auth/token/create | jq -r .auth.client_token)

note "TOKEN: $VAULT_DEV_ROOT_TOKEN_ID"

docker-compose up -d webapp
sleep 5
WEBAPP_URL="http://$(docker-compose port webapp 10000)"
open $WEBAPP_URL
docker-compose logs -f webapp
