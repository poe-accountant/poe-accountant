output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.id
}

output "cluster_urn" {
  description = "URN of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.urn
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = digitalocean_kubernetes_cluster.main.kube_config.0.raw_config
  sensitive   = true
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.name
}

output "cluster_status" {
  description = "Status of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.status
}

output "cluster_version" {
  description = "Version of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.version
}
