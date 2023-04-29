#!/bin/bash

# Set variables 
resourceGroupName='rg-p-weu-docs-001'
location='westeurope'
storageAccountName='sapweudocs001'
storageContainerName='tfstate'

# Create resource group
az group create --name $resourceGroupName --location $location

# Create storage account
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $location --sku Standard_LRS

# Create storage container
az storage container create --name $storageContainerName --account-name $storageAccountName
