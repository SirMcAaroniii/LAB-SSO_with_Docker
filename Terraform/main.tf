########################################################################################
# CREATION DU RESEAU LAB ET DU CERTIFICAT SSH
########################################################################################

# Creation du reseau lab
resource "docker_network" "reseau_lab" {
  name = "reseau_lab"
}

# Certificat Ansible
resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "public_key" {
  content  = tls_private_key.ansible_key.public_key_openssh
  filename = "${path.module}/certs/ansible_key.pub"
}
resource "local_file" "private_key" {
  content         = tls_private_key.ansible_key.private_key_pem
  filename        = "${path.module}/certs/ansible_key"
  file_permission = "0600"
}

# Certificat NGINX
resource "tls_private_key" "key_nginx" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key_nginx.private_key_pem

  subject {
    common_name  = "gitlab.lab"
    organization = "Lab"
  }

  validity_period_hours = 8760
  is_ca_certificate     = false

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  dns_names = ["gitlab.lab"]
}

resource "local_file" "tls_key" {
  filename = "${path.module}/certs/gitlab.lab.key"
  content  = tls_private_key.key_nginx.private_key_pem
}

resource "local_file" "tls_cert" {
  filename = "${path.module}/certs/gitlab.lab.crt"
  content  = tls_self_signed_cert.cert.cert_pem
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
    internal = 22
    external = 2222
  }

  networks_advanced {
    name = docker_network.reseau_lab.name
  }
}

# Injection de la clé dans le conteneur
resource "null_resource" "inject_ssh_key_gitlab" {
  depends_on = [
    docker_container.gitlab,
    local_file.public_key
  ]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/inject_ssh_key_gitlab.sh gitlab ${path.module}/certs/ansible_key.pub"
    interpreter = ["/bin/sh", "-c"]
  }
}


########################################################################################
# CREATION DU CONTENEUR KEYCLOAK
########################################################################################

resource "docker_image" "keycloak" {
  name = "quay.io/keycloak/keycloak:24.0.3"
}

resource "docker_container" "keycloak" {
  name  = "keycloak"
  image = docker_image.keycloak.name

  restart = "unless-stopped"

  ports {
    internal = 8080
    external = 8080
  }

  env = [
    "KEYCLOAK_ADMIN=admin",
    "KEYCLOAK_ADMIN_PASSWORD=admin",
    "KC_DB=postgres",
    "KC_DB_URL=jdbc:postgresql://keycloak-db:5432/keycloak",
    "KC_DB_USERNAME=keycloak",
    "KC_DB_PASSWORD=keycloak",
    "KC_HOSTNAME_STRICT=false",
    "KC_CONF=/etc/keycloak/keycloak.conf",           
    "KC_PROXY=edge",                      
  ]

  depends_on = [
    docker_container.keycloak_db
  ]


  networks_advanced {
    name = docker_network.reseau_lab.name
  }
}

# Injection de la clé dans le conteneur
resource "null_resource" "inject_ssh_key_Keycloak" {
  depends_on = [
    docker_container.keycloak,
    local_file.public_key
  ]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/inject_ssh_key_keycloak.sh keycloak ${path.module}/certs/ansible_key.pub"
    interpreter = ["/bin/sh", "-c"]
  }
}

########################################################################################
# CREATION DU CONTENEUR POSTGRESQL POUR KEYCLOAK
########################################################################################

resource "docker_image" "postgres" {
  name = "postgres:16"
}

resource "docker_container" "keycloak_db" {
  name  = "keycloak-db"
  image = docker_image.postgres.name

  env = [
    "POSTGRES_DB=keycloak",
    "POSTGRES_USER=keycloak",
    "POSTGRES_PASSWORD=keycloak",
  ]

  ports {
    internal = 5432
    external = 5432
  }

  networks_advanced {
    name = docker_network.reseau_lab.name
  }
}


########################################################################################
# CREATION DU CONTENEUR NGINX PROXY
########################################################################################

resource "docker_container" "nginx" {
  name  = "nginx"
  image = "nginx:stable"
  restart = "always"

  networks_advanced {
    name = docker_network.reseau_lab.name
  }

  ports {
    internal = 443
    external = 443
  }

  mounts {
    target     = "/etc/nginx/nginx.conf"
    source     = abspath("${path.module}/nginx.conf")
    type       = "bind"
    read_only  = true
  }

  mounts {
    target     = "/etc/nginx/certs"
    source     = abspath("${path.module}/certs")
    type       = "bind"
    read_only  = true
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
  sensitive   = false
}

# Informations Keycloak
output "keycloak_mdp_password_message" {
  description = "Message de fin indiquant le mot de passe admin Keycloak"
  value = "Les identifiants pour se connecter à Keycloak sont admin/admin"
  sensitive = false
}