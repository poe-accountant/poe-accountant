resource "digitalocean_database_cluster" "redis" {
  name       = var.redis_name != null ? var.redis_name : "${var.cluster_name}-valkey"
  engine     = "valkey"
  version    = var.redis_version
  size       = var.redis_size
  region     = var.region
  node_count = var.redis_node_count

  tags = var.tags
}
