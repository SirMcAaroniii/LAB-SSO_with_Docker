# Image gitlab officielle
resource "docker_image" "gitlab" {
  name         = "gitlab/gitlab-ce:latest"
  keep_locally = false
}

# Creation du container Gitlab
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



# Génération de la clé et copie dans le conteneur
# Génère une clé privée/public RSA
resource "tls_private_key" "ansible_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Écrit la clé publique dans un fichier local
resource "local_file" "public_key" {
  content  = tls_private_key.ansible_key.public_key_openssh
  filename = "${path.module}/ansible_key.pub"
}

# Écrit la clé privée (pour Ansible)
resource "local_file" "private_key" {
  content         = tls_private_key.ansible_key.private_key_pem
  filename        = "${path.module}/ansible_key"
  file_permission = "0600"
}

# Injecte la clé publique dans le conteneur Docker
resource "null_resource" "inject_ssh_key" {
  depends_on = [
    docker_container.gitlab,
    local_file.public_key
  ]

  provisioner "local-exec" {
    command = <<EOT
docker cp ./ansible_key.pub conteneur_gitlab:/root/ansible_key.pub
docker exec gitlab mkdir -p /root/.ssh
docker exec gitlab sh -c "cat /root/ansible_key.pub >> /root/.ssh/authorized_keys"
docker exec gitlab chmod 600 /root/.ssh/authorized_keys
docker exec gitlab chmod 700 /root/.ssh
docker exec gitlab rm /root/ansible_key.pub
EOT
    interpreter = ["bash", "-c"]
  }
}