locals {
  cluster_name         = var.cluster_name != null ? var.cluster_name : "${var.project_name}-cluster"
  database_name        = var.database_name != null ? var.database_name : replace(var.project_name, "-", "_")
  tags                 = var.tags != null ? var.tags : [var.project_name, "terraform"]
  full_api_domain_name = "${var.cloudflare_api_subdomain}.${var.cloudflare_zone_name}"
}

# SSL prep
module "acme" {
  source = "./cloudflare/acme"

  email_address = var.email_address
  domain_names  = [local.full_api_domain_name]
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

module "proxy_list" {
  source = "./cloudflare/proxies"
}

# Deploy the poe-accountant Helm chart
module "helm" {
  source = "./helm"

  project_name     = var.project_name
  ninja_host_names = [local.full_api_domain_name]

  # Docker registry configuration
  docker_registry_url = module.registry.registry_endpoint
  docker_credentials  = module.registry.registry_credentials

  # Database configuration
  database_host     = module.postgres.postgres_host
  database_port     = module.postgres.postgres_port
  database_name     = module.postgres.database_name
  database_username = module.postgres.postgres_username
  database_password = module.postgres.postgres_password

  # Redis/Valkey configuration
  redis_host     = module.valkey.valkey_host
  redis_port     = module.valkey.valkey_port
  redis_password = module.valkey.valkey_password

  cert     = module.acme.cert_pem
  cert_key = module.acme.key_pem

  proxy_cidr = module.proxy_list.proxy_list

  depends_on = [
    module.k8s,
    module.postgres,
    module.valkey,
    module.registry,
    module.acme,
    module.proxy_list
  ]
}

# Cloudflare DNS
module "cloudflare_dns" {
  source = "./cloudflare/dns"

  zone_id   = var.cloudflare_zone_id
  zone_name = var.cloudflare_zone_name

  records = {
    backend_api_ipv4 = {
      # Backend API domain IPv4
      name    = var.cloudflare_api_subdomain
      type    = "A"
      value   = module.helm.ingress_ipv4_address
      ttl     = 1
      proxied = true
      comment = "${var.project_name} Backend API ingress"
    }
    
    backend_api_ipv6 = {
      # Backend API domain IPv6
      name    = var.cloudflare_api_subdomain
      type    = "AAAA"
      value   = module.helm.ingress_ipv6_address
      ttl     = 1
      proxied = true
      comment = "${var.project_name} Backend API ingress"
    }
  }
}
