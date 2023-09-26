# KUBERNETES

## Minikube Configuration

https://minikube.sigs.k8s.io/docs/tutorials/static_ip/
```console
minikube stop

minikube delete

minikube config set cpus 4
minikube config set memory 16GB
minikube config set disk-size 40GB
minikube config set driver docker # kvm2

minikube config view

minikube start --static-ip 10.10.10.10
```

https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns/
```console
minikube addons enable ingress
minikube addons enable ingress-dns

minikube addons list
```

### Port Forward Example
kubectl port-forward service/postgresql 5432:5432

kubectl get ingress --all-namespaces