# Module Terraform Docker 
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Chemin local Docker Provider
provider "docker" {
  host = "unix:///var/run/docker.sock"
}