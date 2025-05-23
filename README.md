# LAB-SSO_with_Docker
Mise en route d'une solution SSO avec déploiement Docker.


# Concept 
Proposition d'environnement laboratoire de la solution SSO Keycloak via Ansible, Terraform et Docker. 
Le lab a été testé et approuvé fonctionnel sur les supports suivants: 
- Windows 11 Pro


# Fonctionnement 
Terraform est utilisé pour : 
- créer le réseau virtuel partagé 
- déployer les conteneurs
- monter les certificats TLS dans NGINX ;

Ansible est utilisé pour : 
- Configuration Realm Keycloak
- Configuration OIDC Gitlab


# Schéma d'infra 
![Lab2 drawio (1)](https://github.com/user-attachments/assets/0b3462cc-ae3c-47bd-b9ed-7d0a1b3a2f3a)


# Actions manuelles et informations 
## TERRAFORM
Pour que Terraform contacte correctement Docker, il faut :
- autoriser l'intégration depuis l'application Docker Desktop (Settings/Resources/WSL integration - turn on Debian or Ubuntu) ;
- ajouter notre utilisateur au groupe docker via la commande _sudo usermod -aG docker $USER_ et relancer l'appartenance au groupe avec _newgrp docker_ .

## ANSIBLE
Ansible doit également avoir quelques commandes nécessaires pour son bon fonctionnement : 
- réduire les droits trop permissifs sur le dossier Ansible avec la commande _chmod go-w /chemin/vers/Ansible_

## NGINX PROXY 
- Il faudra ajouter le nom de domaine dans l'hote qui fait le test

## CERTS
Decriptif des certs : 
- ansible_key/ansible_key.pub : certificat et clé pour Ansible 
- gitlab.lab.crt/gitlab.lab.key : certificat et clé pour NGINX Proxy

## SCRIPTS 
Descriptif des scripts Terraform :
- get_gitlab_password.sh : récupère le mot de passe root du fichier temporaire
- inject_ssh_key_gitlab.sh : injecte le certificat public pour la connexion Ansible au conteneur, via root.
- inject_ssh_key_keycloak.sh : injecte le certificat public pour la connexi on Ansible au conteneur, via home.


# Notes complémentaires
Le conteneur Gitlab peut prendre entre 2 et 5 min d'installations. Il faut patienter 1 minute ou 2 même s'il apparait, car le serveur n'est pas accessible immédiatement.