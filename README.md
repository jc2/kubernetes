# Installation
- `sudo apt-get install libpq-dev python-dev`
- `pip install -r requirements.txt`
- Create **.env** file from **.env.example**

# Run in local
- `python manage.py migrate`
- `python manage.py runserver`
- `celery -A django_web worker -l info`
- `celery -A django_web beat`

# Build Docker
- `docker build -t juancamiloceron/django .` 
- `docker tag juancamiloceron/django:latest juancamiloceron/django:v1`
- `docker push juancamiloceron/django:v1`

# Run in Docker Compose
- You need a Postgres and Redis with SSL 
- `docker-compose up [--detach] [--build]`
- `docker-compose logs -f`
- `docker-compose down`

# Prepare Kubernetes in Azure
## Resouce Group
- `az group create --name ResourceGroup --location eastus`

## Container Registry
- `az acr create --resource-group ResourceGroup --name jc2acr --sku Basic`
- `docker tag juancamiloceron/django:v1 jc2acr.azurecr.io/django:v1.2`
- `az acr login --name jc2acr`
- `docker push jc2acr.azurecr.io/django:v1.2`

## Azure K8s
- `az aks create --resource-group ResourceGroup --name DjangoCluster --node-count 2 --generate-ssh-keys --attach-acr jc2acr`

## Postgres
- Create a Postgres DB with a firewall rule to allow 0.0.0.0

## Redis
- Create a Redis

## Storage File
- `az storage account create --name jc2storageaccount --resource-group ResourceGroup --location westus --sku Standard_LRS`
- `export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -n jc2storageaccount -g ResourceGroup -o tsv)`
- `STORAGE_KEY=$(az storage account keys list --resource-group ResourceGroup --account-name jc2storageaccount --query "[0].value" -o tsv)`
- `az storage share create -n djangovolume --connection-string $AZURE_STORAGE_CONNECTION_STRING`

## Change K8s context: 
- `az aks get-credentials --resource-group ResourceGroup --name DjangoCluster`

# Run in Kubernetes
- `kubectl create secret generic azure-volume-secret --from-literal=azurestorageaccountname=jc2storageaccount --from-literal=azurestorageaccountkey=$STORAGE_KEY`
- `kubectl create configmap nginx-config --from-file=../config/nginx/default.conf`
- `kubectl apply -f django_pv.yml`
- `kubectl apply -f django_pvc.yml`
- `kubectl apply -f django_cdn_deployment.yml`
- `kubectl apply -f django_cdn_service.yml`

- `kubectl apply -f django_configmap.yml`
- `kubectl create secret generic django-secret --from-env-file=django_secrets`
- `kubectl describe secret django-secret`
- `kubectl apply -f django_api_deployment.yml`
- `kubectl get deploy django-api`
- `kubectl get pod`
- `kubectl apply -f django_api_service.yml`
- `kubectl get service django-api`
- `kubectl get node -o wide`
- `kubectl apply -f django_worker_deployment.yml`
- `kubectl apply -f django_scheduler_deployment.yml`


## Shortcuts
- `kubectl apply -f .`
- `kubectl delete all --all --namespace=default`

# Test
- http://127.0.0.1:8000/
- http://127.0.0.1:8000/create?text=hello (wait 1 minute)

# TODO
- [x] Add Gunicorn
- [x] Add an Entrypoint
- [ ] Add DB and broker as optional in compose
- [ ] Add logger
- [ ] Add more things from here https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/
- [x] Add statics
- [ ] Add SSL
- [ ] Add admin to Something model
- [ ] Improve collectstatic flow
- [x] Add env vars to docker env vars
- [x] Add Worker to K8s
- [x] Add Scheduler to K8s
- [x] Add Nginx to K8s
- [ ] Put secrets as YML files (get vars from env)
- [ ] Implement Helm
- [ ] Add terrform

# BUGS
