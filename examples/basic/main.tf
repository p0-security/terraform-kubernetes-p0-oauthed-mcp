provider "helm" {
  kubernetes = {
    config_path    = var.kube_config_path
    config_context = var.kube_context
  }
}

module "oauthed_mcp" {
  source  = "p0-security/p0-oauthed-mcp/kubernetes"
  version = "0.1.3"

  release_name     = var.release_name
  namespace        = var.namespace
  create_namespace = var.create_namespace
  values           = [file(var.values_file)]
}

output "release_name" { value = module.oauthed_mcp.release_name }
output "namespace" { value = module.oauthed_mcp.namespace }
output "chart_version" { value = module.oauthed_mcp.chart_version }
