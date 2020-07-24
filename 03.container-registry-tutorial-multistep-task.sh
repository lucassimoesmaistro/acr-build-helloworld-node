ACR_NAME=acrlsmdev001
RES_GROUP=rsg-$ACR_NAME
AKV_NAME=$ACR_NAME-vault
GIT_USER=lucassimoesmaistro
GIT_PAT=
SERVICE_PRINCIPAL_NAME=acr-svc-pr

az acr task create \
    --registry $ACR_NAME \
    --name example1 \
    --context https://github.com/$GIT_USER/acr-build-helloworld-node.git \
    --file taskmulti.yaml \
    --git-access-token $GIT_PAT

az acr task run --registry $ACR_NAME --name example1

#az acr task logs --registry $ACR_NAME
#az acr task list-runs --registry $ACR_NAME --output table

az acr task create \
    --registry $ACR_NAME \
    --name example2 \
    --context https://github.com/$GIT_USER/acr-build-helloworld-node.git \
    --file taskmulti-multiregistry.yaml \
    --git-access-token $GIT_PAT \
    --set regDate=mycontainerregistrydate.azurecr.io


ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

SP_PASSWD=$(az ad sp create-for-rbac --name http://$SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query password --output tsv)
SP_APP_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId --output tsv)
echo "Service principal ID: $SP_APP_ID"
echo "Service principal password: $SP_PASSWD"

az acr task credential add --name example2 \
    --registry $ACR_NAME \
    --login-server mycontainerregistrydate.azurecr.io \
    --username "0698b270-20b7-4631-8b48-7e2d585e5183" \
    --password "yS_-w-0wrUaH8sclgv6v1-D0V_u_pGusou"