terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

locals {
  cluster_name  = var.cluster_name != null ? var.cluster_name : "${var.project_name}-cluster"
  database_name = var.database_name != null ? var.database_name : replace(var.project_name, "-", "_")
  tags         = var.tags != null ? var.tags : [var.project_name, "terraform"]
}

module "k8s" {
  source = "./digitalocean/k8s"

  cluster_name       = local.cluster_name
  region             = var.region
  kubernetes_version = var.kubernetes_version
  node_size          = var.node_size
  auto_scale         = var.auto_scale
  node_min_count     = var.node_min_count
  node_max_count     = var.node_max_count
  tags               = local.tags
}

module "redis" {
  source = "./digitalocean/redis"

  cluster_name      = local.cluster_name
  region            = var.region
  redis_name        = var.redis_name
  redis_version     = var.redis_version
  redis_size        = var.redis_size
  redis_node_count  = var.redis_node_count
  tags              = local.tags
}

module "postgres" {
  source = "./digitalocean/postgres"

  cluster_name         = local.cluster_name
  region               = var.region
  postgres_name        = var.postgres_name
  postgres_version     = var.postgres_version
  postgres_size        = var.postgres_size
  postgres_node_count  = var.postgres_node_count
  database_name        = local.database_name
  tags                 = local.tags
}
