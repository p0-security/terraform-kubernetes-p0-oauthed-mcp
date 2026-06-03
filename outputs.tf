output "release_name" {
  description = "Name of the Helm release."
  value       = helm_release.oauthed_mcp.name
}

output "namespace" {
  description = "Kubernetes namespace the release was deployed into."
  value       = helm_release.oauthed_mcp.namespace
}

output "chart_version" {
  description = "Version of the chart that was deployed."
  value       = local.chart_version
}
