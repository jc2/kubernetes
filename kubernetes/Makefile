configure:
	kubectl delete secret azure-volume-secret | true
	kubectl delete secret django-secret | true
	kubectl delete cm nginx-config | true
	kubectl delete cm django-config | true
 
	kubectl create secret generic azure-volume-secret --from-literal=azurestorageaccountname=jc2storageaccount --from-literal=azurestorageaccountkey=$(STORAGE_KEY)
	kubectl create secret generic django-secret --from-env-file=django_secrets
	kubectl create configmap nginx-config --from-file=../config/nginx/default.conf
	kubectl apply -f django_configmap.yml

	kubectl delete pv django-storage | true
	kubectl delete pvc django-storage-claim | true

	kubectl apply -f django_pv.yml
	kubectl apply -f django_pvc.yml

	kubectl delete service django-api | true
	kubectl delete service django-cdn | true

	kubectl apply -f django_cdn_service.yml
	kubectl apply -f django_api_service.yml
	kubectl get services

stop:
	kubectl delete deploy django-cdn | true
	kubectl delete deploy django-api | true
	kubectl delete deploy django-worker | true
	kubectl delete deploy django-scheduler | true

deploy-all:
	kubectl delete deploy django-cdn | true
	kubectl delete deploy django-api | true
	kubectl delete deploy django-worker | true
	kubectl delete deploy django-scheduler | true
	
	kubectl apply -f django_cdn_deployment.yml
	kubectl apply -f django_api_deployment.yml
	kubectl apply -f django_worker_deployment.yml
	kubectl apply -f django_scheduler_deployment.yml
	kubectl get pods

deploy-api:
	kubectl delete deploy django-api | true
	kubectl apply -f django_api_deployment.yml
	kubectl get pods