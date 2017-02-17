# mysql-minikube
Despliegue de la aplicación IBM-Bluemix sobre el Cluster de Kubernetes, utilizando Minikube. 
El script desarrollado fue probado sobre una instalación limpia de Ubuntu 16.04. Al ejecutarlo descarga e instala todo lo necesario para desplagar la aplicación y entregar la URL donde está atendiendo la misma.
#Guía de ejecución
#1- Conar el repositorio.
git clone https://github.com/apenasco/mysql-minikube.git

cd mysql-minikube
#2- Ejecutar (Como sudo).
sudo ./tp-final.sh
#3- Eliminar.
sudo ./kube-delete.sh
