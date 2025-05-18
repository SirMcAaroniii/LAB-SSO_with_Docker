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
}



# Génération de la paire RSA pour Ansible
resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


# Création du fichier local
resource "local_file" "public_key" {
  content  = tls_private_key.ansible_key.public_key_openssh
  filename = "${path.module}/ansible_key.pub"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ansible_key.private_key_pem
  filename        = "${path.module}/ansible_key"
  file_permission = "0600"
}


# Injection de la clé dans le conteneur
resource "null_resource" "inject_ssh_key" {
  depends_on = [
    docker_container.gitlab,
    local_file.public_key
  ]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/inject_ssh_key.sh gitlab ${path.module}/ansible_key.pub"
    interpreter = ["/bin/sh", "-c"]
  }
}

