output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.poe_accountant.name
}

output "helm_release_namespace" {
  description = "Namespace of the Helm release"
  value       = helm_release.poe_accountant.namespace
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = helm_release.poe_accountant.status
}

output "ingress_ipv4_address" {
  description = "External IPv4 address of the ingress controller"
  value       = data.external.ingress_ips.result.ipv4
}

output "ingress_ipv6_address" {
  description = "External IPv6 address of the ingress controller"
  value       = data.external.ingress_ips.result.ipv6
}
