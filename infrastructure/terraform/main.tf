locals {
  cluster_name  = var.cluster_name != null ? var.cluster_name : "${var.project_name}-cluster"
  database_name = var.database_name != null ? var.database_name : replace(var.project_name, "-", "_")
  tags         = var.tags != null ? var.tags : [var.project_name, "terraform"]
}

module "project" {
  source = "./digitalocean/project"

  project_name        = var.project_name
  project_description = var.project_description
  resource_urns = [
    module.k8s.cluster_urn,
    module.valkey.cluster_urn,
    module.postgres.cluster_urn,
  ]
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

module "valkey" {
  source = "./digitalocean/valkey"

  cluster_name      = local.cluster_name
  region            = var.region
  valkey_name       = var.valkey_name
  valkey_version    = var.valkey_version
  valkey_size       = var.valkey_size
  valkey_node_count = var.valkey_node_count
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

module "registry" {
  source = "./digitalocean/registry"

  cluster_name                = local.cluster_name
  region                     = var.region
  registry_name              = var.registry_name
  registry_subscription_tier = var.registry_subscription_tier
}
