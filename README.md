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
-  

# Run in Docker
- `docker-compose up [--detach] [--build]`
- `docker-compose logs -f`
- `docker-compose down`

# Run in Kubernetes
- `kubectl apply -f django_configmap.yml`
- `kubectl create secret generic django-secret --from-env-file=django_secrets`
- `kubectl describe secret django-secret`
- `kubectl apply -f django_api_deployment.yml`
- `kubectl get deploy django`
- `kubectl get pod`
- `kubectl apply -f django_service.yml`
- `kubectl get service django`
- `kubectl get node -o wide`
- `kubectl apply -f django_worker_deployment.yml`
- `kubectl apply -f django_scheduler_deployment.yml`

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
- [ ] Add Nginx to K8s

# BUGS
- [ ] There is a problem because the service sometimes does not respond 