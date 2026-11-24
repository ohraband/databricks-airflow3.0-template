#Create or replace a kind cluster
kind delete cluster --name kind
kind create cluster --image kindest/node:v1.29.4

# Add airflow to my helm repo
helm repo add apache-airflow https://airflow.apache.org/
helm repo update
helm show values apache-airflow/airflow > chart/values-example.yaml

#Export values for Airflow docker images
export IMAGE_NAME=my-dags
export IMAGE_TAG=$(date +%Y%m%d%H%M%S)
#export IMAGE_TAG=0.0.1
export NAMESPACE=airflow
export RELEASE_NAME=airflow

#Build the image and load it into kind
docker build --no-cache --pull --tag $IMAGE_NAME:$IMAGE_TAG -f cicd/Dockerfile .
kind load docker-image $IMAGE_NAME:$IMAGE_TAG 

#Create a namespace
kubectl create namespace $NAMESPACE

# Apply kubernetes secrets
kubectl apply -f k8s/secrets/git-secrets.yaml --namespace $NAMESPACE

# Install Airflow using helm
helm install $RELEASE_NAME apache-airflow/airflow \
    --namespace $NAMESPACE -f chart/values-override.yaml \
    --set-string images.airflow.tag="$IMAGE_TAG" \
    --debug

# Port forward the API server
kubectl port-forward svc/$RELEASE_NAME-api-server 8080:8080 --namespace $NAMESPACE