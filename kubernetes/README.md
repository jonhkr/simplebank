# SimpleBank

A simple bank API written in Elixir.


## Kubernetes deployment

This is a guide on how to deploy this application in a Kubernetes environment.

This guide uses Minikube, follow [this guide](https://kubernetes.io/docs/setup/minikube/) to install Minikube on your machine.

Use these commands to setup the SimpleBank service on Kubernetes.

``` bash
# Create a secret to store the mysql password
echo -n "foo" > ./password.txt
kubectl create secret generic simplebank-mysql-pass --from-file=password.txt

# Create the mysql deployment
kubectl create -f kubernetes/mysql-deployment.yaml

# Configure the service
cp kubernetes/config.toml.sample config.toml

# Edit the config file as needed
# export EDITOR=/usr/bin/vim
$EDITOR config.toml

# Create a secret from the config file
kubectl create secret generic simplebank-config --from-file=config.toml

# Deploy the SimpleBank service
kubectl create -f kubernetes/simplebank-deployment.yaml
```

Use this command to list all services running on minikube
```
minikube service list
```
This should return a table like this:
```
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

