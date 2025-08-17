output "project_id" {
  description = "ID of the DigitalOcean project"
  value       = module.project.project_id
}

output "project_name" {
  description = "Name of the DigitalOcean project"
  value       = module.project.project_name
}

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

output "valkey_id" {
  description = "ID of the Valkey database cluster"
  value       = module.valkey.valkey_id
}

output "valkey_host" {
  description = "Valkey database host"
  value       = module.valkey.valkey_host
}

output "valkey_port" {
  description = "Valkey database port"
  value       = module.valkey.valkey_port
}

output "valkey_uri" {
  description = "Valkey connection URI"
  value       = module.valkey.valkey_uri
  sensitive   = true
}

output "valkey_password" {
  description = "Valkey database password"
  value       = module.valkey.valkey_password
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

output "registry_id" {
  description = "ID of the container registry"
  value       = module.registry.registry_id
}

output "registry_name" {
  description = "Name of the container registry"
  value       = module.registry.registry_name
}

output "registry_endpoint" {
  description = "Endpoint URL of the container registry"
  value       = module.registry.registry_endpoint
}

output "registry_server_url" {
  description = "Server URL of the container registry"
  value       = module.registry.registry_server_url
}
