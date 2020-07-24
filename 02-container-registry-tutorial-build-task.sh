ACR_NAME=acrlsmdev001
RES_GROUP=rsg-$ACR_NAME
AKV_NAME=$ACR_NAME-vault
GIT_USER=lucassimoesmaistro
GIT_PAT=

az acr task create \
    --registry $ACR_NAME \
    --name taskhelloworld \
    --image helloworld:{{.Run.ID}} \
    --context https://github.com/$GIT_USER/acr-build-helloworld-node.git \
    --file Dockerfile \
    --commit-trigger-enabled false \
    --base-image-trigger-enabled true \
    --git-access-token $GIT_PAT

#az acr task run --registry $ACR_NAME --name taskhelloworld
#az acr task logs --registry $ACR_NAME
#az acr task list-runs --registry $ACR_NAME --output table