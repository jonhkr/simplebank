# SimpleBank

A simple bank API written in Elixir.


## Kubernetes deployment

This is a guide on how to deploy this application in a Kubernetes environment.

This guide uses Minikube, follow [this guide](https://kubernetes.io/docs/setup/minikube/) to install Minikube on your machine.

Use these commands to setup the SimpleBank service on Kubernetes.

```sh
# Create a secret to store the mysql password
echo -n "foo" > ./password.txt
kubectl create secret generic simplebank-mysql-pass --from-file=password.txt

# Create the mysql deployment
kubectl create -f kubernetes/mysql-deployment.yaml

# Create the database for the service
kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -- mysql -h simplebank-mysql -pfoo -e "create database simplebank_prod"

# Configure the service
cp kubernetes/config.toml.sample config.toml

# Edit the config file as needed
# export EDITOR=/usr/bin/vim
$EDITOR config.toml

# Create a secret from the config file
kubectl create secret generic simplebank-config --from-file=config.toml

# Deploy the SimpleBank service
kubectl create -f kubernetes/simplebank-deployment.yaml

# Wait for all pods to be created (their status should be `Running`)
kubectl get pods --watch

# To apply the migrations we need to connect to one of the pods
kubectl exec -it $(kubectl get pods --selector=app=simplebank --selector=tier=frontend -o jsonpath='{.items[0].metadata.name}') -- /bin/bash

# Then run the migrate command
bin/simplebank migrate
```

Use this command to list all services running on minikube
```sh
minikube service list
```
This should return a table like this:
```sh
|-------------|----------------------|-----------------------------|
|  NAMESPACE  |         NAME         |             URL             |
|-------------|----------------------|-----------------------------|
| default     | kubernetes           | No node port                |
| default     | simplebank-lb        | http://192.168.99.100:30170 |
| default     | simplebank-mysql     | No node port                |
| kube-system | kube-dns             | No node port                |
| kube-system | kubernetes-dashboard | No node port                |
|-------------|----------------------|-----------------------------|
```

In this example, the service is accessible through the address `http://192.168.99.100:30170`

