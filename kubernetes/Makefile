configure:
	kubectl create secret generic azure-volume-secret --from-literal=azurestorageaccountname=jc2storageaccount --from-literal=azurestorageaccountkey=$STORAGE_KEY
	kubectl create configmap nginx-config --from-file=../config/nginx/default.conf
	kubectl create secret generic django-secret --from-env-file=django_secrets
	kubectl apply -f django_configmap.yml

	kubectl apply -f django_pv.yml
	kubectl apply -f django_pvc.yml
	kubectl apply -f django_cdn_deployment.yml
	kubectl apply -f django_cdn_service.yml
	kubectl apply -f django_api_deployment.yml
	kubectl apply -f django_api_service.yml
	kubectl apply -f django_worker_deployment.yml
	kubectl apply -f django_scheduler_deployment.yml