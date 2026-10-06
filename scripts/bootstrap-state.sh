#!/usr/bin/env bash
# One-time setup of the storage account that holds Terraform state.
# Run once per subscription before the first `terraform init`.
set -euo pipefail

LOCATION="${LOCATION:-australiaeast}"
RG="${RG:-rg-tfstate-aue}"
SA="${SA:-sttfstateaue001}"   # must be globally unique, 3-24 lowercase alphanumerics
CONTAINER="${CONTAINER:-tfstate}"

az group create --name "$RG" --location "$LOCATION" --output none

az storage account create \
  --name "$SA" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku Standard_ZRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --allow-shared-key-access false \
  --output none

# Versioning + soft delete protect against accidental state loss.
az storage account blob-service-properties update \
  --account-name "$SA" \
  --resource-group "$RG" \
  --enable-versioning true \
  --enable-delete-retention true --delete-retention-days 30 \
  --enable-container-delete-retention true --container-delete-retention-days 30 \
  --output none

# Grant yourself data-plane access (needed because shared keys are disabled).
SA_ID=$(az storage account show --name "$SA" --resource-group "$RG" --query id -o tsv)
ME=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --assignee-object-id "$ME" --assignee-principal-type User \
  --role "Storage Blob Data Contributor" --scope "$SA_ID" --output none

az storage container create --name "$CONTAINER" --account-name "$SA" --auth-mode login --output none

echo "State backend ready: $SA/$CONTAINER (role assignment may take a minute to propagate)"
