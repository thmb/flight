# KUBERNETES

## Minikube Configuration

https://minikube.sigs.k8s.io/docs/tutorials/static_ip/
```console
minikube stop

minikube delete

minikube config set cpus 4
minikube config set memory 16GB
minikube config set disk-size 40GB
minikube config set driver kvm2 # does not support static ip

minikube config view

minikube start # starts without static ip support

minikube start --driver docker --static-ip 192.168.100.100
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