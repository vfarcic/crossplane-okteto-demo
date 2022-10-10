#########
# Intro #
#########

# TODO: Viktor: What is Crossplane? (short, we'll explain more during and after the demo)

# TODO: Arsh: What is Okteto? (short, we'll explain more during and after the demo)

#########
# Setup #
#########

# Create a Kubernetes cluster (a local cluster like Rancher Desktop should do for the demo)

# Install `okteto` CLI from https://www.okteto.com/docs/getting-started/#installing-okteto-cli

git clone https://github.com/vfarcic/silly-demo

git clone https://github.com/vfarcic/devops-toolkit-crossplane

cd devops-toolkit-crossplane

# TODO: Viktor: Remove
kubectl krew install schemahero

# TODO: Viktor: Remove
kubectl schemahero install

helm repo add crossplane-stable \
    https://charts.crossplane.io/stable

helm repo update

helm upgrade --install \
    crossplane crossplane-stable/crossplane \
    --namespace crossplane-system \
    --create-namespace \
    --wait

# Replace `[...]` with your access key ID`
export AWS_ACCESS_KEY_ID=[...]

# Replace `[...]` with your secret access key
export AWS_SECRET_ACCESS_KEY=[...]

echo "[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
" >aws-creds.conf

kubectl --namespace crossplane-system \
    create secret generic aws-creds \
    --from-file creds=./aws-creds.conf

kubectl apply \
    --filename crossplane-config/provider-aws.yaml

kubectl apply \
    --filename crossplane-config/config-k8s.yaml

kubectl apply \
    --filename crossplane-config/config-sql.yaml

kubectl get pkgrev

# Wait until all the packages are healthy

kubectl apply \
    --filename crossplane-config/provider-config-aws.yaml

kubectl create namespace a-team

kubectl --namespace a-team apply \
    --filename examples/k8s/aws-eks.yaml

kubectl --namespace a-team \
    get clusterclaims

# Wait until it is `READY`

./examples/k8s/get-kubeconfig-eks.sh

# TODO: Add the secret from the k8s composition
kubectl --kubeconfig kubeconfig.yaml \
    --namespace crossplane-system \
    create secret generic aws-creds \
    --from-file creds=./aws-creds.conf

########
# Demo #
########

# Q: What would you like to do?
# A: Simplify development

# Q: How will you do that?
# A: With Okteto

# Q: What do you need?
# A: I need a cluster

cat examples/k8s/aws-eks.yaml

kubectl --namespace a-team apply \
    --filename examples/k8s/aws-eks.yaml

kubectl --namespace a-team \
    get clusterclaims

kubectl get managed

# Q: What else do you need?
# A: I need to be able to connect to that cluster

kubectl --namespace a-team get secrets

./examples/k8s/get-kubeconfig-eks.sh

export KUBECONFIG=$PWD/kubeconfig.yaml

kubectl get nodes

# Q: What else do you need?
# A: I need a shared database (I don't want to deploy it in my own environment)

kubectl --namespace production apply \
    --filename examples/sql/aws.yaml

cat examples/sql/aws.yaml

kubectl --namespace production \
    get sqlclaims

kubectl get managed

cat packages/sql/definition.yaml

cat packages/sql/aws.yaml

kubectl --namespace production \
    get sqlclaims

# TODO: Continue

# Arsh: talk about Okteto if the claim is not yet ready

# Q: What else do you need?
# A: I need to be able to access that database server

kubectl --namespace production \
    get secrets

export DB_ENDPOINT=$(kubectl \
    --namespace production \
    get secret my-db \
    --output jsonpath='{.data.endpoint}' \
    | base64 --decode)

export DB_PORT=$(kubectl \
    --namespace production \
    get secret my-db \
    --output jsonpath='{.data.port}' \
    | base64 --decode)

export DB_USER=$(kubectl \
    --namespace production \
    get secret my-db \
    --output jsonpath='{.data.username}' \
    | base64 --decode)

export DB_PASS=$(kubectl \
    --namespace production \
    get secret my-db \
    --output jsonpath='{.data.password}' \
    | base64 --decode)

env | grep DB_

# Q: What else do you need?
# A: I need a database inside that DB server

kubectl get databases.postgresql.sql.crossplane.io

# Open pgAdmin and show that the DB was created

# Q: What else do you need?
# A: I need to create a schema in that database

cat examples/sql/schemahero-postgresql.yaml

export DB_URI=postgresql://$DB_USER:$DB_PASS@$DB_ENDPOINT:$DB_PORT/my-db

kubectl --namespace production \
    create secret generic my-db-uri \
    --from-literal=value=$DB_URI

kubectl --namespace production \
    apply \
    --filename examples/sql/schemahero-postgresql.yaml

kubectl --namespace production \
    get databases.databases.schemahero.io

kubectl --namespace production \
    get tables.schemas.schemahero.io

cd ../silly-demo

# TODO: Arsh: From here on it's all about Okteto. Choose to showcase whatever you think would be good to show.

# TODO: The commands that follow are there only to show you how to run the app. Change them to leverage Okteto.

kubectl --namespace dev \
    create secret generic my-db \
    --from-literal=endpoint=$DB_ENDPOINT \
    --from-literal=port=$DB_PORT \
    --from-literal=username=$DB_USER \
    --from-literal=password=$DB_PASS

cat okteto.yml

kubectl --namespace dev apply \
    --kustomize kustomize/overlays/stateful

kubectl --namespace dev port-forward \
    svc/silly-demo 8080:8080 &

curl -X POST "localhost:8080/video?id=wNBG1-PSYmE&title=Kubernetes%20Policies%20And%20Governance%20-%20Ask%20Me%20Anything%20With%20Jim%20Bugwadia"

curl -X POST "localhost:8080/video?id=VlBiLFaSi7Y&title=Scaleway%20-%20Everything%20We%20Expect%20From%20A%20Cloud%20Computing%20Service%3F"

curl "localhost:8080/videos" | jq .

# TODO: Viktor: Arsh, what is Okteto?

# TODO: Arsh: Viktor, what is Crossplane?

###########
# Destroy #
###########

./examples/k8s/get-kubeconfig-eks.sh

kubectl --namespace production delete \
    --filename examples/sql/aws.yaml

kubectl --namespace ingress-nginx \
    delete service \
    a-team-eks-ingress-ingress-nginx-controller

kubectl get managed

# Wait until all the resources are deleted
#   (ignore `release` and `object resources`)

unset KUBECONFIG

kubectl --namespace a-team delete \
    --filename examples/k8s/aws-eks.yaml

kubectl get managed

# Wait until all the resources are deleted
#   (ignore `release` and `object resources`)

# Destroy or reset the management cluster



# TODO: Change the namespace to dev
# TODO: EKS v1.22.13-eks-15b7512
# TODO: `okteto up -n [NAMESPACE]`