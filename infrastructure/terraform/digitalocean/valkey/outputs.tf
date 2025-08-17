output "valkey_id" {
  description = "ID of the Valkey database cluster"
  value       = digitalocean_database_cluster.valkey.id
}

output "valkey_host" {
  description = "Valkey database host"
  value       = digitalocean_database_cluster.valkey.host
}

output "valkey_port" {
  description = "Valkey database port"
  value       = digitalocean_database_cluster.valkey.port
}

output "valkey_uri" {
  description = "Valkey connection URI"
  value       = digitalocean_database_cluster.valkey.uri
  sensitive   = true
}

output "valkey_password" {
  description = "Valkey database password"
  value       = digitalocean_database_cluster.valkey.password
  sensitive   = true
}

output "valkey_name" {
  description = "Valkey database cluster name"
  value       = digitalocean_database_cluster.valkey.name
}

output "cluster_urn" {
  description = "Valkey database cluster URN (alias for consistency)"
  value       = digitalocean_database_cluster.valkey.urn
}
