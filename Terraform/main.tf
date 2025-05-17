# Image gitlab officielle
resource "docker_image" "gitlab" {
  name         = "gitlab/gitlab-ce:latest"
  keep_locally = false
}

# Creation du container Gitlab
resource "docker_container" "gitlab" {
  image = docker_image.gitlab.image_id
  name  = "conteneur_gitlab"
  hostname = "gitlab"
  ports {
    internal = 80
    external = 80
  }
  ports {
    internal = 443
    external = 443
  }
}