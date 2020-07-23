ACR_NAME=acrlsmdev001
RES_GROUP=rsg-$ACR_NAME
AKV_NAME=$ACR_NAME-vault

echo "az group create..."
az group create --resource-group $RES_GROUP --location eastus

echo "az acr create..."
az acr create --resource-group $RES_GROUP --name $ACR_NAME --sku Standard --location eastus

echo "az keyvault create..."
az keyvault create --resource-group $RES_GROUP --name $AKV_NAME

##Aqui
echo "Create service principal, store its password in AKV (the registry *password*)..."
az keyvault secret set \
  --vault-name $AKV_NAME \
  --name $ACR_NAME-pull-pwd \
  --value $(az ad sp create-for-rbac \
                --name $ACR_NAME-pull \
                --scopes $(az acr show --name $ACR_NAME --query id --output tsv) \
                --role acrpull \
                --query password \
                --output tsv)

echo "Store service principal ID in AKV (the registry *username*)"
az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-pull-usr \
    --value $(az ad sp show --id http://$ACR_NAME-pull --query appId --output tsv)

echo "az acr build"
az acr build --registry $ACR_NAME --image helloacrtasks:v1 .

echo "az container create"
az container create \
    --resource-group $RES_GROUP \
    --name acr-tasks \
    --image $ACR_NAME.azurecr.io/helloacrtasks:v1 \
    --registry-login-server $ACR_NAME.azurecr.io \
    --registry-username $(az keyvault secret show --vault-name $AKV_NAME --name $ACR_NAME-pull-usr --query value -o tsv) \
    --registry-password $(az keyvault secret show --vault-name $AKV_NAME --name $ACR_NAME-pull-pwd --query value -o tsv) \
    --dns-name-label acr-tasks-$ACR_NAME \
    --query "{FQDN:ipAddress.fqdn}" \
    --output table

echo "az container attach"
az container attach --resource-group $RES_GROUP --name acr-tasks

#az container delete --resource-group $RES_GROUP --name acr-tasks
#az group delete --resource-group $RES_GROUP
#az ad sp delete --id http://$ACR_NAME-pull