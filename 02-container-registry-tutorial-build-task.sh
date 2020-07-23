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
    --git-access-token $GIT_PAT

