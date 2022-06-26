#!/bin/bash

echo "Configurando autenticação do cluster EKS para o Kubectl"
echo ""
aws eks update-kubeconfig --name jenkins

echo "Editando arquivo volumes.yaml com o ID correto do EFS criado"
echo ""
EFSID=$(aws efs describe-file-systems --query "FileSystems[?CreationToken == 'jenkins-efs'].FileSystemId" --output text)
sed -i "s/EFSID/$EFSID/g" ./volumes.yaml

echo "Instalando NGINX Controller para uso do Ingress"
echo ""
helm repo update
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

echo "Instalando driver EFS CSI de conexão"
echo ""
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.3"

echo "Aplicando manifestos YAML para provisionar o serviço Jenkins"
echo ""
kubectl apply -k .
