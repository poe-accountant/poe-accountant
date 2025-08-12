output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = module.k8s.cluster_id
}

output "cluster_urn" {
  description = "URN of the Kubernetes cluster"
  value       = module.k8s.cluster_urn
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  value       = module.k8s.cluster_endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = module.k8s.kubeconfig
  sensitive   = true
}

output "redis_id" {
  description = "ID of the Redis database cluster"
  value       = module.redis.redis_id
}

output "redis_host" {
  description = "Redis database host"
  value       = module.redis.redis_host
}

output "redis_port" {
  description = "Redis database port"
  value       = module.redis.redis_port
}

output "redis_uri" {
  description = "Redis connection URI"
  value       = module.redis.redis_uri
  sensitive   = true
}

output "redis_password" {
  description = "Redis database password"
  value       = module.redis.redis_password
  sensitive   = true
}

output "postgres_id" {
  description = "ID of the PostgreSQL database cluster"
  value       = module.postgres.postgres_id
}

output "postgres_host" {
  description = "PostgreSQL database host"
  value       = module.postgres.postgres_host
}

output "postgres_port" {
  description = "PostgreSQL database port"
  value       = module.postgres.postgres_port
}

output "postgres_uri" {
  description = "PostgreSQL connection URI"
  value       = module.postgres.postgres_uri
  sensitive   = true
}

output "postgres_username" {
  description = "PostgreSQL database username"
  value       = module.postgres.postgres_username
}

output "postgres_password" {
  description = "PostgreSQL database password"
  value       = module.postgres.postgres_password
  sensitive   = true
}

output "database_name" {
  description = "Application database name"
  value       = module.postgres.database_name
}
