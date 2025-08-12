variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "poe-accountant"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = null  # Will use project_name-cluster if not set
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33.1-do.3"
}

variable "node_size" {
  description = "Size of the worker nodes"
  type        = string
}

variable "node_min_count" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "auto_scale" {
  description = "Enable autoscaling for the node pool"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = null  # Will use [project_name, "terraform"] if not set
}

variable "redis_name" {
  description = "Name of the Redis database cluster"
  type        = string
  default     = null  # Will use cluster_name-redis if not set
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "7"
}

variable "redis_size" {
  description = "Size of the Redis database cluster"
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "redis_node_count" {
  description = "Number of Redis nodes"
  type        = number
  default     = 1
}

variable "postgres_name" {
  description = "Name of the PostgreSQL database cluster"
  type        = string
  default     = null  # Will use cluster_name-postgres if not set
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "postgres_size" {
  description = "Size of the PostgreSQL database cluster"
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "postgres_node_count" {
  description = "Number of PostgreSQL nodes"
  type        = number
  default     = 1
}

variable "database_name" {
  description = "Name of the application database"
  type        = string
  default     = null  # Will use project_name with underscores if not set
}
