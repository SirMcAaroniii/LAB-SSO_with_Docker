# LAB-SSO_with_Docker
Mise en route d'une solution SSO avec déploiement Docker.


# Concept 
Proposition d'environnement laboratoire de la solution SSO Keycloak via Ansible, Terraform et Docker. 


# Fonctionnement 
Terraform est utilisé pour déployer les conteneurs sur Docker. 
Ansible va aller configurer les conteneurs associés. 
L'objectif est de se connecter à un serveur Gitlab via la solution SSO Keycloak.


# Schéma d'infra 
![Lab2 drawio (1)](https://github.com/user-attachments/assets/0b3462cc-ae3c-47bd-b9ed-7d0a1b3a2f3a)


# Actions manuelles et nécessaires 
## TERRAFORM
Pour que Terraform contacte correctement Docker, il faut :
- autoriser l'intégration depuis l'application Docker Desktop (Settings/Resources/WSL integration - turn on Debian or Ubuntu) ;
- ajouter notre utilisateur au groupe docker via la commande _sudo usermod -aG docker $USER_ et relancer l'appartenance au groupe avec _newgrp docker_ .


# Quelques commandes intéressantes
Pour vérifier si la connexion à Gitlab sans configuration est fonctionnelle via le compte root, récupérer le mdp root avec la commande suivante et tenter de se connecter à l'interface locale en :80 :
- docker exec -it {Container ID} cat /etc/gitlab/initial_root_password


# Notes complémentaires
Télécharger le projet Github pour avoir accès au laboratoire au complet. 
Les variables seront à adapter en fonction de votre projet.

Le conteneur Gitlab peut prendre entre 2 et 5 min d'installations. Il faut patienter 1 minute ou 2 même s'il apparait, car le serveur n'est pas accessible immédiatement.