#!/bin/bash

(set -x; 
#Install virtualbox
echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" >> /etc/apt/sources.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
apt-get update
apt-get -y install virtualbox-5.0

#Install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.16.0/minikube-linux-amd64
chmod +x minikube && mv minikube /usr/local/bin/

#Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

#Install docker
apt-get install -y curl linux-image-extra-$(uname -r) linux-image-extra-virtual apt-transport-https ca-certificates
curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -
apt-get install -y software-properties-common
add-apt-repository "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"
apt-get update && apt-get -y install docker-engine
/etc/init.d/docker restart
)

#Iniciar VM minikube
(set -x;
minikube start --vm-driver="virtualbox" --insecure-registry="0.0.0.0:5000" --v=3
)

#Repo local a MV minikube
eval $(minikube docker-env)

#Obtener Fuentes
(set -x; test -d php-mysql || git clone https://github.com/IBM-Bluemix/php-mysql.git)

: ${registry:="localhost:5000"}

(set -x; 
#Crear registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2

#Construir imagen (Dockerfile)
docker build -t myapp-bluemix .
)
echo "Listo: myapp-bluemix"

(set -x;
docker tag myapp-bluemix:latest ${registry?}/myapp-bluemix:latest
docker push ${registry?}/myapp-bluemix:latest
)

#Pull Imagen mysql
(set -x;
docker pull mysql:5.5
docker tag mysql:5.5 ${registry?}/mysql:5.5
docker push ${registry?}/mysql:5.5
)

#Run Kube
(set -x;
kubectl create -f myappsql-rc.tmpl.yaml
)

#Mostrar direccion app
IP=$(minikube service myappsql-svc --url)
echo "Script finalizado, se puede acceder a la app desde la siguiente dirección:"
echo "${IP:?}/php-mysql/"
