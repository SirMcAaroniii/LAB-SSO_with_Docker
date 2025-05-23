########################################################################################
# CREATION DU RESEAU DOCKER ET CERTIFICAT SSH
########################################################################################

# Reseau docker 
resource "docker_network" "reseau_lab" {
  name = "reseau_lab"
}


# Certificat SSH pour Ansible
resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "public_key" {
  content  = tls_private_key.ansible_key.public_key_openssh
  filename = "${path.module}/ansible_key.pub"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ansible_key.private_key_pem
  filename        = "${path.module}/ansible_key"
  file_permission = "0600"
}


########################################################################################
# CREATION DU CONTENEUR GITLAB 
########################################################################################

# Téléchargement de l'image GitLab CE officielle
resource "docker_image" "gitlab" {
  name         = "gitlab/gitlab-ce:latest"
  keep_locally = false
}

# Création du conteneur GitLab
resource "docker_container" "gitlab" {
  image = docker_image.gitlab.image_id
  name  = "gitlab"

  ports {
    internal = 80
    external = 80
  }
  ports {
    internal = 443
    external = 443
  }
  ports {
    internal = 22
    external = 2222
  }
  networks_advanced {
    name = "reseau_lab"
  }
}

# Injection de la clé dans le conteneur
resource "null_resource" "inject_ssh_key_gitlab" {
  depends_on = [
    docker_container.gitlab,
    local_file.public_key
  ]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/inject_ssh_key_gitlab.sh gitlab ${path.module}/ansible_key.pub"
    interpreter = ["/bin/sh", "-c"]
  }
}


########################################################################################
# CREATION DU CONTENEUR KEYCLOAK
########################################################################################

# Téléchargement de l'image Keycloak officielle
resource "docker_image" "keycloak" {
  name         = "keycloak/keycloak:latest"
  keep_locally = false
}

# Création du conteneur Keycloak
resource "docker_container" "keycloak" {
  image = docker_image.keycloak.image_id
  name  = "keycloak"

  ports {
    internal = 8080
    external = 8080
  }
  networks_advanced {
    name = "reseau_lab"
  }

  env = [
    "KEYCLOAK_ADMIN=admin",
    "KEYCLOAK_ADMIN_PASSWORD=admin",
    "KC_HEALTH_ENABLED=true",
    "KC_METRICS_ENABLED=true"
  ]

  command = ["start-dev"]
}

# Injection de la clé dans le conteneur
resource "null_resource" "inject_ssh_key_Keycloak" {
  depends_on = [
    docker_container.keycloak,
    local_file.public_key
  ]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/inject_ssh_key_keycloak.sh keycloak ${path.module}/ansible_key.pub"
    interpreter = ["/bin/sh", "-c"]
  }
}


########################################################################################
# SORTIES ATTENDUES 
########################################################################################

# Informations Gitlab
data "external" "gitlab_root_pwd" {
  depends_on = [docker_container.gitlab]
  program    = ["bash", "${path.module}/scripts/get_gitlab_password.sh", docker_container.gitlab.name]
}

output "gitlab_root_password_message" {
  description = "Message de fin indiquant le mot de passe root GitLab"
  value       = "Voici le mot de passe root GitLab : ${data.external.gitlab_root_pwd.result["result"]}"
  sensitive   = true
}

# Informations Keycloak
output "keycloak_mdp_password_message" {
  description = "Message de fin indiquant le mot de passe admin Keycloak"
  value = "Les identifiants pour se connecter à Keycloak sont admin/admin"
  sensitive = false
}