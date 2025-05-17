# LAB-SSO_with_Docker
Mise en route d'une solution SSO avec déploiement Docker.


# Concept 
Proposition d'environnement laboratoire de la solution SSO Keycloak via Ansible, Terraform et Docker. 


# Fonctionnement 
Terraform est utilisé pour déployer les conteneurs sur Docker. 
Ansible va aller configurer les conteneurs associés. 
L'objectif est de se connecter à un serveur Gitlab via la solution SSO Keycloak.


# Schéma d'infra 
![Lab2 drawio](https://github.com/user-attachments/assets/043ebd40-4991-4234-9aa1-5e0d0e68499d)


# Actions manuelles et nécessaires 
*TERRAFORM*
Pour que Terraform contacte correctement Docker, il faut :
- autoriser l'intégration depuis l'application Docker Desktop (Settings/Resources/WSL integration - turn on Debian or Ubuntu) ;
- ajouter notre utilisateur au groupe docker via la commande _sudo usermod -aG docker $USER_ et relancer l'appartenance au groupe avec _newgrp docker_ .


# Notes complémentaires
Télécharger le projet Github pour avoir accès au laboratoire au complet. 
Les variables seront à adapter en fonction de votre projet.
Le conteneur Gitlab peut prendre entre 5 et 15min d'installation, même s'il est affiché, il peut ne pas être disponible. 