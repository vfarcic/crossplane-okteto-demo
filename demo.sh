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

kubectl --namespace a-team apply \
    --filename examples/k8s/aws-eks.yaml

kubectl --namespace a-team \
    get clusterclaims

# Q: What else do you need?
# A: I need to be able to connect to that cluster

kubectl --namespace a-team get secrets

./examples/k8s/get-kubeconfig-eks.sh

kubectl --kubeconfig kubeconfig.yaml \
    get nodes

# TODO: Add the secret from the k8s composition
kubectl --kubeconfig kubeconfig.yaml \
    --namespace crossplane-system \
    create secret generic aws-creds \
    --from-file creds=./aws-creds.conf

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

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production \
    get sqlclaims

# Talk about something until the claim is `READY`

# Q: What else do you need?
# A: I need to be able to access that database server

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production \
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

# Q: What else do you need?
# A: I need a database inside that DB server

kubectl --kubeconfig kubeconfig.yaml \
    get databases.postgresql.sql.crossplane.io

# Open pgAdmin and show that the DB was created

# Q: What else do you need?
# A: I need to create a schema in that database

cat examples/sql/schemahero-postgresql.yaml

export DB_URI=postgresql://$DB_USER:$DB_PASS@$DB_ENDPOINT:$DB_PORT/my-db

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production \
    create secret generic my-db-uri \
    --from-literal=value=$DB_URI

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production \
    apply \
    --filename examples/sql/schemahero-postgresql.yaml

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production \
    get databases.databases.schemahero.io

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production \
    get tables.schemas.schemahero.io

# TODO: Arsh: Use Okteto to deploy an app connected to Postgresql

# TODO: Arsh: The endpoint, port, user, and password are in the environment variables (`DB_*`).

# TODO: Arsh: Show that the apps is working and connected to the DB (e.g., create/retrieve some records in the DB)

###########
# Destroy #
###########

./examples/k8s/get-kubeconfig-eks.sh

kubectl --kubeconfig kubeconfig.yaml \
    --namespace production delete \
    --filename examples/sql/aws.yaml

kubectl --kubeconfig kubeconfig.yaml \
    get managed

# Wait until all the resources are deleted
#   (ignore `release` and `object resources`)

kubectl --kubeconfig kubeconfig.yaml \
    --namespace ingress-nginx delete service \
    a-team-eks-ingress-ingress-nginx-controller

kubectl --namespace a-team delete \
    --filename examples/k8s/aws-eks.yaml

kubectl get managed

# Wait until all the resources are deleted
#   (ignore `release` and `object resources`)

# Destroy or reset the management cluster
