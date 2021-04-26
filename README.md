# Content
- [Content](#content)
- [Installation](#installation)
- [Run in local](#run-in-local)
- [Build Docker](#build-docker)
- [Run in Docker](#run-in-docker)
- [Run in Docker Compose](#run-in-docker-compose)
- [Prepare Kubernetes in Azure with terraform](#prepare-kubernetes-in-azure-with-terraform)
  - [Run terraform](#run-terraform)
  - [Extra configurations](#extra-configurations)
- [Prepare Kubernetes in Azure with CLI](#prepare-kubernetes-in-azure-with-cli)
  - [Login](#login)
  - [Resouce Group](#resouce-group)
  - [Container Registry](#container-registry)
  - [AKS](#aks)
  - [Postgres](#postgres)
  - [Redis](#redis)
  - [Storage File](#storage-file)
- [Switch Azure context:](#switch-azure-context)
- [Run in Kubernetes](#run-in-kubernetes)
  - [Loading configs](#loading-configs)
  - [Deploying](#deploying)
  - [Shortcuts](#shortcuts)
- [Test](#test)
- [TODO](#todo)
- [BUGS](#bugs)

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

# Run in Docker
- `docker run --name django-api --env-file .env -e APP_MODE=api -p 8000:8000 -d juancamiloceron/django:v1`
- `docker exec -it django-api /bin/bash`

# Run in Docker Compose
- You need a Postgres and Redis with SSL 
- `docker-compose up [--detach] [--build]`
- `docker-compose logs -f`
- `docker-compose down`

# Prepare Kubernetes in Azure with terraform
## Run terraform
- `az login`
- `terraform init`
- `terraform plan -var-file secrets.tfvars`
- `terraform apply -var-file secrets.tfvars -auto-approve`
- `terraform state pull | jq '.outputs.broker_password.value'`
- `export STORAGE_KEY=$(terraform state pull | jq '.outputs.files_account_primary_key.value' | tr -d '"' )`
## Extra configurations
- `az aks get-credentials --resource-group k8s-group --name django-cluster`
- `docker tag juancamiloceron/django:v1 jc2acr.azurecr.io/django:v1.2`
- `az acr login --name jc2acr`
- `docker push jc2acr.azurecr.io/django:v1.2`

# Prepare Kubernetes in Azure with CLI
## Login
- `az login`
## Resouce Group
- `az group create --name k8s-group --location eastus`
## Container Registry
- `az acr create --resource-group k8s-group --name jc2acr --sku Basic`
- `docker tag juancamiloceron/django:v1 jc2acr.azurecr.io/django:v1.2`
- `az acr login --name jc2acr`
- `docker push jc2acr.azurecr.io/django:v1.2`
## AKS
- `az aks create --resource-group k8s-group --name django-cluster --node-count 2 --generate-ssh-keys --attach-acr jc2acr`
## Postgres
- Create a Postgres DB with a firewall rule to allow 0.0.0.0
## Redis
- Create a Redis
## Storage File
- `az storage account create --name jc2storageaccount --resource-group k8s-group --location westus --sku Standard_LRS`
- `export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -n jc2storageaccount -g k8s-group -o tsv)`
- `export STORAGE_KEY=$(az storage account keys list --resource-group k8s-group --account-name jc2storageaccount --query "[0].value" -o tsv)`
- `az storage share create -n djangovolume --connection-string $AZURE_STORAGE_CONNECTION_STRING`

# Switch Azure context: 
- `az aks get-credentials --resource-group k8s-group --name django-cluster`

# Run in Kubernetes
## Loading configs
- `kubectl create secret generic azure-volume-secret --from-literal=azurestorageaccountname=jc2storageaccount --from-literal=azurestorageaccountkey=$STORAGE_KEY`
- `kubectl create configmap nginx-config --from-file=../config/nginx/default.conf`
- `kubectl create secret generic django-secret --from-env-file=django_secrets`
- `kubectl apply -f django_configmap.yml`
## Deploying
- `kubectl apply -f django_pv.yml`
- `kubectl apply -f django_pvc.yml`
- `kubectl apply -f django_cdn_deployment.yml`
- `kubectl apply -f django_cdn_service.yml`
- `kubectl apply -f django_api_deployment.yml`
- `kubectl apply -f django_api_service.yml`
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
- [x] Add Worker to K8s-group
- [x] Add Scheduler to K8s-group
- [x] Add Nginx to K8s-group
- [ ] Put secrets as YML files (get vars from env)
- [ ] Implement Helm
- [x] Add terrform
- [ ] Improve urls for cdn and api

# BUGS
