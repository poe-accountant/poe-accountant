resource "digitalocean_container_registry" "main" {
  name                   = var.registry_name != null ? var.registry_name : "${var.cluster_name}-registry"
  subscription_tier_slug = var.registry_subscription_tier
  region                 = var.region
}
