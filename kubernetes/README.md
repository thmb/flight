# KUBERNETES

## Minikube Configuration

minikube stop
minikube delete

minikube config set cpus 4
minikube config set memory 16GB
minikube config set disk-size 40GB
minikube config set driver kvm2

minikube start

minikube addons enable ingress
minikube addons list

### Port Forward Example
kubectl port-forward service/postgresql 5432:5432

kubectl get ingress --all-namespaces