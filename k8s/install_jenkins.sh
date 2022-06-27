#!/bin/bash

echo ""
echo "#############################################################"
echo "#  Configurando autenticação do cluster EKS para o Kubectl  #"
echo "#############################################################"
echo ""
aws eks update-kubeconfig --name jenkins

if [ $? -eq 0 ]
then
    echo ""
    echo "------------"
    echo "---  OK  ---"
    echo "------------"
    echo ""
else
    echo ""
    echo "!!!!!!!!!!!!!!"
    echo "!!!  FAIL  !!!"
    echo "!!!!!!!!!!!!!!"
    echo ""
fi

echo ""
echo "##################################################################"
echo "#  Editando arquivo volumes.yaml com o ID correto do EFS criado  #"
echo "##################################################################"
echo ""
EFSID=$(aws efs describe-file-systems --query "FileSystems[?CreationToken == 'jenkins-efs'].FileSystemId" --output text)
sed -i "s/EFSID/$EFSID/g" ./volumes.yaml

if [ $? -eq 0 ]
then
    echo ""
    echo "------------"
    echo "---  OK  ---"
    echo "------------"
    echo ""
else
    echo ""
    echo "!!!!!!!!!!!!!!"
    echo "!!!  FAIL  !!!"
    echo "!!!!!!!!!!!!!!"
    echo ""
fi

echo ""
echo "#####################################################"
echo "#  Instalando NGINX Controller para uso do Ingress  #"
echo "#####################################################"
echo ""
helm repo update
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

if [ $? -eq 0 ]
then
    echo ""
    echo "------------"
    echo "---  OK  ---"
    echo "------------"
    echo ""
else
    echo ""
    echo "!!!!!!!!!!!!!!"
    echo "!!!  FAIL  !!!"
    echo "!!!!!!!!!!!!!!"
    echo ""
fi

echo ""
echo "##########################################"
echo "#  Instalando driver EFS CSI de conexão  #"
echo "##########################################"
echo ""
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.3"

if [ $? -eq 0 ]
then
    echo ""
    echo "------------"
    echo "---  OK  ---"
    echo "------------"
    echo ""
else
    echo ""
    echo "!!!!!!!!!!!!!!"
    echo "!!!  FAIL  !!!"
    echo "!!!!!!!!!!!!!!"
    echo ""
fi

echo ""
echo "##################################################################"
echo "#  Aplicando manifestos YAML para provisionar o serviço Jenkins  #"
echo "##################################################################"
echo ""
kubectl apply -k .

if [ $? -eq 0 ]
then
    echo ""
    echo "------------"
    echo "---  OK  ---"
    echo "------------"
    echo ""
else
    echo ""
    echo "!!!!!!!!!!!!!!"
    echo "!!!  FAIL  !!!"
    echo "!!!!!!!!!!!!!!"
    echo ""
fi

echo ""
echo "##################################################################"
echo "#  Obter endpoint de acesso do novo Load Balancer  #"
echo "##################################################################"
echo ""
kubectl -n ingress-nginx get svc ingress-nginx-controller | tail -n 1 | awk "{ print $4 }"
