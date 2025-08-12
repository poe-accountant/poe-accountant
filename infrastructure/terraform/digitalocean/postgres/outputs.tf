output "postgres_id" {
  description = "ID of the PostgreSQL database cluster"
  value       = digitalocean_database_cluster.postgres.id
}

output "postgres_host" {
  description = "PostgreSQL database host"
  value       = digitalocean_database_cluster.postgres.host
}

output "postgres_port" {
  description = "PostgreSQL database port"
  value       = digitalocean_database_cluster.postgres.port
}

output "postgres_uri" {
  description = "PostgreSQL connection URI"
  value       = digitalocean_database_cluster.postgres.uri
  sensitive   = true
}

output "postgres_private_uri" {
  description = "PostgreSQL private connection URI"
  value       = digitalocean_database_cluster.postgres.private_uri
  sensitive   = true
}

output "postgres_database_uri" {
  description = "Application database connection URI"
  value       = digitalocean_database_cluster.postgres.database
  sensitive   = true
}

output "postgres_username" {
  description = "PostgreSQL database username"
  value       = digitalocean_database_cluster.postgres.user
}

output "postgres_password" {
  description = "PostgreSQL database password"
  value       = digitalocean_database_cluster.postgres.password
  sensitive   = true
}

output "postgres_urn" {
  description = "PostgreSQL database URN"
  value       = digitalocean_database_cluster.postgres.urn
}

output "postgres_name" {
  description = "PostgreSQL database cluster name"
  value       = digitalocean_database_cluster.postgres.name
}

output "database_name" {
  description = "Application database name"
  value       = digitalocean_database_db.app_database.name
}
