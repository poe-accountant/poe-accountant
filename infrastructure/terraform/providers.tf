terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    external = {
      source = "hashicorp/external"
      version = "~> 2.3"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.21"
    }
  }
}

# Configure the Helm provider to use the DOKS cluster
provider "helm" {
  kubernetes {
    host                   = module.k8s.cluster_endpoint
    token                  = module.k8s.cluster_token
    cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
  }
}

# Configure the Kubernetes provider to use the DOKS cluster
provider "kubernetes" {
  host                   = module.k8s.cluster_endpoint
  token                  = module.k8s.cluster_token
  cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
}
