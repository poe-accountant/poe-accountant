variable "cluster_name" {
  description = "Name of the cluster (used for Redis naming)"
  type        = string
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
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
}

variable "redis_node_count" {
  description = "Number of Redis nodes"
  type        = number
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = []
}
