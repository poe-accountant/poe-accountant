variable "project_name" {
  description = "Name of the project (used for naming resources)"
  type        = string
}

variable "chart_path" {
  description = "Path to the Helm chart"
  type        = string
  default     = "../helm"
}

variable "values_file_path" {
  description = "Path to the values file"
  type        = string
  default     = "../helm/values.remote.yaml"
}

variable "ninja_host_names" {
  description = "Host names to listen for the Ninja Service"
  type        = list(string)
}

variable "docker_registry_url" {
  description = "URL of the Docker registry"
  type        = string
}

variable "docker_credentials" {
  description = "Credentials for Docker registry authentication"
  type        = string
  sensitive   = true
}

variable "docker_credential_secret_name" {
  description = "Name of the Kubernetes secret containing Docker credentials"
  type        = string
  default     = ""
}

# Database variables
variable "database_host" {
  description = "Database host"
  type        = string
  sensitive   = true
}

variable "database_port" {
  description = "Database port"
  type        = number
  sensitive   = true
}

variable "database_name" {
  description = "Database name"
  type        = string
  sensitive   = true
}

variable "database_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# Redis/Valkey variables
variable "redis_host" {
  description = "Redis host"
  type        = string
  sensitive   = true
}

variable "redis_port" {
  description = "Redis port"
  type        = number
  sensitive   = true
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
}

variable "cert" {
  description = "Certificate for domain supported under this ingress"
  type        = string
  sensitive   = true
}

variable "cert_key" {
  description = "Certificate key for domain supported under this ingress"
  type        = string
  sensitive   = true
}

variable "proxy_cidr" {
  description = "List of CIDRs accepted for incoming connections and proxy IP mapping"
  type        = list(string)
  default     = []
}
