# Create namespace first
resource "kubernetes_namespace" "project_namespace" {
  metadata {
    name = var.project_name
  }
}

# Create Docker registry secret if credentials are provided
resource "kubernetes_secret" "docker_registry" {
  metadata {
    name      = "docker-registry-secret"
    namespace = var.project_name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = var.docker_credentials
  }

  depends_on = [kubernetes_namespace.project_namespace]
}

# Create Docker registry secret if credentials are provided
resource "kubernetes_secret" "ninja_server_secret" {
  metadata {
    name      = "ninja-server-secret"
    namespace = var.project_name
  }

  type = "kubernetes.io/opaque"

  data = {
    "REDIS_HOST"     = var.redis_host
    "REDIS_PORT"     = var.redis_port
    "REDIS_PASSWORD" = var.redis_password
    
    "DATABASE_HOST"     = var.database_host
    "DATABASE_PORT"     = var.database_port
    "DATABASE_NAME"     = var.database_name
    "DATABASE_PASSWORD" = var.database_password
    "DATABASE_USERNAME" = var.database_username
  }

  depends_on = [kubernetes_namespace.project_namespace]
}

resource "kubernetes_secret" "tls_cert" {
  metadata {
    name      = "site-tls"
    namespace = var.project_name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = var.cert
    "tls.key" = var.cert_key
  }
}

# Deploy the poe-accountant Helm chart
resource "helm_release" "poe_accountant" {
  depends_on = [
    kubernetes_namespace.project_namespace,
    kubernetes_secret.docker_registry,
    kubernetes_secret.tls_cert
  ]

  name       = var.project_name
  namespace  = var.project_name
  chart      = var.chart_path
  
  create_namespace = false  # We're creating it explicitly above
  
  # Use remote values for production deployment
  values = [
    file(var.values_file_path)
  ]
  
  # Pass dynamic values from Terraform
  set {
    name  = "global.namespace"
    value = var.project_name
  }

  set {
    name  = "ingress.host"
    value = var.ingress_host
  }
  
  # Docker registry configuration
  set {
    name  = "docker.registry"
    value = var.docker_registry_url
  }

  set {
    name  = "docker.credentialSecretName"
    value = kubernetes_secret.docker_registry.metadata[0].name
  }

  set {
    name  = "ingress.tlsSecretName"
    value = kubernetes_secret.tls_cert.metadata[0].name
  }

  set {
    name  = "services.ninja-server.envSecretName"
    value = kubernetes_secret.ninja_server_secret.metadata[0].name
  }
  
  # Database configuration
  set_sensitive {
    name  = "database.host"
    value = var.database_host
  }
  
  set_sensitive {
    name  = "database.port"
    value = var.database_port
  }
  
  set_sensitive {
    name  = "database.name"
    value = var.database_name
  }
  
  set_sensitive {
    name  = "database.username"
    value = var.database_username
  }
  
  set_sensitive {
    name  = "database.password"
    value = var.database_password
  }
  
  # Redis/Valkey configuration
  set_sensitive {
    name  = "redis.host"
    value = var.redis_host
  }
  
  set_sensitive {
    name  = "redis.port"
    value = var.redis_port
  }
  
  set_sensitive {
    name  = "redis.password"
    value = var.redis_password
  }

  set {
    name  = "ingress-nginx.controller.config.proxy-real-ip-cidr"
    value = join("\\,", var.proxy_cidr)
    type  = "string"
  }

  set {
    name  = "nginx.ingress.kubernetes.io/whitelist-source-range"
    value = join("\\,", var.proxy_cidr)
    type  = "string"
  }

  wait          = true
  wait_for_jobs = true
}

data "external" "ingress_ips" {
  program = ["bash", "-lc", <<EOT
set -euo pipefail
ns="${var.project_name}"
name="${var.project_name}-ingress-nginx-controller"

for i in {1..120}; do
  out=$(kubectl -n "$ns" get svc "$name" -o jsonpath='{.status.loadBalancer.ingress[*].ip}' || true)
  if [ -n "$out" ]; then
    ipv4=$(echo "$out" | tr ' ' '\n' | grep '\.' || true)
    ipv6=$(echo "$out" | tr ' ' '\n' | grep ':' || true)
    printf '{"ipv4":"%s","ipv6":"%s"}\n' "$ipv4" "$ipv6"
    exit 0
  fi
  sleep 5
done
echo '{"error":"timeout waiting for LoadBalancer IPs"}'
exit 1
EOT
  ]
  depends_on = [helm_release.poe_accountant]
}

