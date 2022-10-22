#########
# Setup #
#########

# Create a Kubernetes cluster (a local cluster like Rancher Desktop should do for the demo)

# Install `okteto` CLI from https://www.okteto.com/docs/getting-started/#installing-okteto-cli

git clone https://github.com/vfarcic/crossplane-okteto-demo

git clone https://github.com/vfarcic/devops-toolkit-crossplane

cd devops-toolkit-crossplane

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
    --filename examples/k8s/aws-eks-1-22.yaml

kubectl --namespace a-team \
    get clusterclaims

# Wait until it is `READY`

./examples/k8s/get-kubeconfig-eks.sh

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

cat examples/k8s/aws-eks-1-22.yaml

kubectl --namespace a-team apply \
    --filename examples/k8s/aws-eks-1-22.yaml

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
# A: I need a shared database server (I don't want to deploy it in my own environment)

kubectl --namespace dev apply \
    --filename examples/sql/aws.yaml

cat examples/sql/aws.yaml

kubectl --namespace dev \
    get sqlclaims

kubectl get managed

cat packages/sql/definition.yaml

cat packages/sql/aws.yaml

kubectl --namespace dev \
    get sqlclaims

# Arsh: talk about Okteto if the claim is not yet ready

# Q: What else do you need?
# A: I need to be able to access that database server

kubectl --namespace dev \
    get secrets

./examples/sql/schemahero-secret.sh dev

# Q: What else do you need?
# A: I need a database inside that DB server

kubectl get databases.postgresql.sql.crossplane.io

# Open pgAdmin and show that the DB was created

# Q: What else do you need?

# Arsh: From here on it's all about Okteto. Choose to showcase whatever you think would be good to show.

cd ../crossplane-okteto-demo

cat okteto.yaml

okteto context use

okteto up --namespace dev

cat schemahero.yaml

cat k8s.yaml

(in okteto terminal) env | grep DB

(in okteto terminal) go run server.go

###########
# Destroy #
###########

cd ../devops-toolkit-crossplane

./examples/k8s/get-kubeconfig-eks.sh

kubectl --namespace dev delete \
    --filename examples/sql/aws.yaml

kubectl --namespace ingress-nginx \
    delete service \
    a-team-eks-ingress-ingress-nginx-controller

kubectl get managed

# Wait until all the resources are deleted
#   (ignore `database` resource)

unset KUBECONFIG

kubectl --namespace a-team delete \
    --filename examples/k8s/aws-eks.yaml

kubectl get managed

# Wait until all the resources are deleted
#   (ignore `release` and `object resources`)

# Destroy or reset the management cluster
