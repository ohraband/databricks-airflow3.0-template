#Create or replace a kind cluster
kind delete cluster --name kind
kind create cluster --image kindest/node:v1.29.4 --config k8s/clusters/kind-cluster.yaml

# Add airflow to my helm repo
helm repo add apache-airflow https://apache.org
helm repo update
helm show values apache-airflow/airflow > chart/values-example.yaml

#Export values for Airflow docker images
export IMAGE_NAME=ghcr.io/ohraband/databricks-airflow3.0-template
export IMAGE_TAG=latest
export NAMESPACE=airflow
export RELEASE_NAME=airflow

#Create a namespace
kubectl create namespace $NAMESPACE

# Create GHCR pull secret for private image
kubectl create secret docker-registry ghcr-secret \
    --docker-server=ghcr.io \
    --docker-username=ohraband\
    --docker-password=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 \
    --namespace $NAMESPACE

# Apply kubernetes secrets
kubectl apply -f k8s/secrets/git-secrets.yaml --namespace $NAMESPACE

kubectl apply -f k8s/volumes/airflow-logs-pv.yaml
kubectl apply -f k8s/volumes/airflow-logs-pvc.yaml #may get claimed again and cause pods to be stuck at pending, try: kubectl describe pod -l component=api-server -n airflow

# Install Airflow using helm
helm install $RELEASE_NAME apache-airflow/airflow \
    --namespace $NAMESPACE -f chart/values-override-persistence.yaml \
    --set-string images.airflow.repository="$IMAGE_NAME" \
    --set-string images.airflow.tag="$IMAGE_TAG" \
    --set-string registry.secretName="ghcr-secret" \
    --debug

# Port forward the API server
kubectl port-forward svc/$RELEASE_NAME-api-server 8080:8080 --namespace $NAMESPACE
