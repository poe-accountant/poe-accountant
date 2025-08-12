variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "node_size" {
  description = "Size of the worker nodes"
  type        = string
}

variable "node_min_count" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_max_count" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "auto_scale" {
  description = "Enable autoscaling for the node pool"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = []
}
