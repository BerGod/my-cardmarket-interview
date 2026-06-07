#!/bin/bash

set -e 

echo "Check if kustomize is installed..."
if ! command -v kustomize &> /dev/null; then
    echo "kustomize is not installed. Please install it and try again."
    exit 1
fi

echo "This is a local development script. It can be used to run commands or set up the environment for local development."

echo "Setting up environment variables..."
export KUBECONFIG="$HOME/.kube/config"
export NAMESPACE="my-interview"


echo "Checking if minikube is running..."
is_running=$(minikube status | grep "host: Running")

if [ -z "$is_running" ]; then
    echo "Minikube is not running. Please start minikube and try again."
    echo "Minikube can be started with the command: minikube start"
    exit 1
else
    echo "Minikube is running."
fi

echo "Creating namespace $NAMESPACE if it does not exist..."
kubectl create namespace $NAMESPACE 2>/dev/null || echo "Namespace '$NAMESPACE' already exists."


echo "Kustomize building and applying Kubernetes manifests..."
kustomize build k8s/ | kubectl apply -f - -n $NAMESPACE

echo "Porting Nginx service to localhost:8080..."
kubectl port-forward svc/mynginx 8080:80 -n $NAMESPACE

echo "Local development environment is set up. You can access the Nginx service at http://localhost:8080"
echo "To stop port forwarding, press Ctrl+C in this terminal."

echo "To clean up the Kubernetes resources, run: kubectl delete -f k8s/ -n $NAMESPACE"
