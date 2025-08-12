output "redis_id" {
  description = "ID of the Redis database cluster"
  value       = digitalocean_database_cluster.redis.id
}

output "redis_host" {
  description = "Redis database host"
  value       = digitalocean_database_cluster.redis.host
}

output "redis_port" {
  description = "Redis database port"
  value       = digitalocean_database_cluster.redis.port
}

output "redis_uri" {
  description = "Redis connection URI"
  value       = digitalocean_database_cluster.redis.uri
  sensitive   = true
}

output "redis_password" {
  description = "Redis database password"
  value       = digitalocean_database_cluster.redis.password
  sensitive   = true
}

output "redis_urn" {
  description = "Redis database URN"
  value       = digitalocean_database_cluster.redis.urn
}

output "redis_name" {
  description = "Redis database cluster name"
  value       = digitalocean_database_cluster.redis.name
}
