# #Export values for Airflow docker images
# export IMAGE_NAME=my-dags
# # export IMAGE_TAG=$(date +%Y%m%d%H%M%S)
# export IMAGE_TAG=0.0.1
# export NAMESPACE=airflow
# export RELEASE_NAME=airflow

# #Build the image and load it into kind
# docker build --pull --tag $IMAGE_NAME:$IMAGE_TAG -f cicd/Dockerfile .
# kind load docker-image $IMAGE_NAME:$IMAGE_TAG 

# # Upgrade Airflow using helm
# helm upgrade $RELEASE_NAME apache-airflow/airflow \
#     --namespace $NAMESPACE -f chart/values-override.yaml \
#     --set-string images.airflow.tag="$IMAGE_TAG" \
#     --debug

# # Port forward the API server
# kubectl port-forward svc/$RELEASE_NAME-api-server 8080:8080 --namespace $NAMESPACE



export IMAGE_NAME=my-dags
export IMAGE_TAG=$(date +%Y%m%d%H%M%S)
export NAMESPACE=airflow
export RELEASE_NAME=airflow

docker build --no-cache --pull --tag $IMAGE_NAME:$IMAGE_TAG -f cicd/Dockerfile .
kind load docker-image $IMAGE_NAME:$IMAGE_TAG --name kind

helm upgrade $RELEASE_NAME apache-airflow/airflow \
    --namespace $NAMESPACE -f chart/values-override.yaml \
    --set-string images.airflow.repository="$IMAGE_NAME" \
    --set-string images.airflow.tag="$IMAGE_TAG"

