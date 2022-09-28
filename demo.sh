#########
# Intro #
#########

# TODO: Viktor: What is Crossplane?

# TODO: Arsh: What is Okteto?

#########
# Setup #
#########

# Create a Kubernetes cluster (a local cluster like Rancher Desktop should do)

git clone https://github.com/vfarcic/devops-toolkit-crossplane

cd devops-toolkit-crossplane

kubectl krew install schemahero

# TODO: Viktor: Remove
kubectl schemahero install

helm repo add crossplane-stable \
    https://charts.crossplane.io/stable

# TODO: Viktor: Remove
helm repo add schemahero \
    oci://ghcr.io/schemahero/helm/schemahero

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

########
# Demo #
########

# Q: What would you like to do?
# A: Simplify development

# Q: How will you do that?
# A: With Okteto

# Q: What do you need?
# A: I need a cluster

cat examples/k8s/aws-eks.yaml

kubectl --namespace a-team \
    get clusterclaims

# Q: What else do you need?
# A: I need to be able to connect to that cluster

kubectl --namespace a-team get secrets

./examples/k8s/get-kubeconfig-eks.sh

kubectl --kubeconfig kubeconfig.yaml \
    get nodes

# Q: What else do you need?
# A: I need a shared database (I don't want to deploy it in my own environment)

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production apply \
    --filename examples/sql/aws.yaml

cat examples/sql/aws.yaml

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production \
    get sqlclaims

kubectl get managed

kubectl --kubeconfig kubeconfig.yaml \
    get managed

cat packages/sql/definition.yaml

cat packages/sql/aws.yaml

# TODO: Add the secret from the k8s composition
kubectl --kubeconfig kubeconfig.yaml \
    --namespace crossplane-system \
    create secret generic aws-creds \
    --from-file creds=./aws-creds.conf

kubectl --kubeconfig kubeconfig.yaml \
    --namespace a-team \
    get sqlclaims

# Talk about something until the claim is `READY`

# Q: What else do you need?
# A: I need a database inside that DB server

# TODO: Continue

# Q: What else do you need?
# A: I need to create a schema in that database

kubectl --namespace a-team \
    get secrets

export DB_ENDPOINT=$(kubectl \
    --kubeconfig kubeconfig.yaml \
    --namespace production \
    get secret my-db \
    --output jsonpath='{.data.endpoint}' \
    | base64 --decode)

export DB_PORT=$(kubectl \
    --kubeconfig kubeconfig.yaml \
    --namespace production \
    get secret my-db \
    --output jsonpath='{.data.port}' \
    | base64 --decode)

export DB_USER=$(kubectl \
    --kubeconfig kubeconfig.yaml \
    --namespace production \
    get secret my-db \
    --output jsonpath='{.data.username}' \
    | base64 --decode)

export DB_PASS=$(kubectl \
    --kubeconfig kubeconfig.yaml \
    --namespace production \
    get secret my-db \
    --output jsonpath='{.data.password}' \
    | base64 --decode)

env | grep DB_

# TODO: Viktor: Add creation of the DB to the composition

kubectl --namespace a-team \
    get databases.databases.schemahero.io

# TODO: Viktor: Switch to Kubernetes secrets
# TODO: Viktor: Move the DB part to the composition
cat examples/sql/schemahero-postgresql.yaml

kubectl --namespace a-team apply \
    --filename examples/sql/schemahero-postgresql.yaml

kubectl --namespace a-team \
    get tables.schemas.schemahero.io

kubectl schemahero --namespace a-team \
    get migrations

# Replace `[...]` with the migration ID
export MIGRATION_ID=[...]

kubectl schemahero --namespace a-team \
    describe migration $MIGRATION_ID

kubectl schemahero --namespace a-team \
    approve migration $MIGRATION_ID

# TODO: Arsh: Use Okteto to deploy an app connected to Postgresql

# TODO: Arsh: The app should be able to create a schema in Postgresql. Typically, The endpoint, port, user, and password are in the environment variables (`DB_*`).

# TODO: Arsh: Show that the apps is working and connected to the DB (e.g., create/retrieve some records in the DB)

###########
# Destroy #
###########

./examples/k8s/get-kubeconfig-eks.sh

kubectl --kubeconfig kubeconfig-eks.yaml \
    --namespace ingress-nginx delete service \
    a-team-eks-ingress-ingress-nginx-controller

kubectl --kubeconfig kubeconfig-eks.yaml \
    --namespace production delete \
    --filename examples/sql/aws.yaml

kubectl --kubeconfig kubeconfig-eks.yaml \
    get managed

# Wait until all the resources are deleted
#   (ignore `release` and `object resources`)

kubectl --namespace a-team delete \
    --filename examples/k8s/aws-eks.yaml

kubectl get managed

# Wait until all the resources are deleted
#   (ignore `release` and `object resources`)

# Destroy or reset the management cluster
