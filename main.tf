locals {
  # Pinned chart version for this module release. Update in lockstep with
  # module version tags — see the compatibility matrix in README.md.
  chart_version = "0.7.1"
}

resource "helm_release" "oauthed_mcp" {
  name             = var.release_name
  namespace        = var.namespace
  create_namespace = var.create_namespace
  repository       = "oci://registry-1.docker.io/p0security"
  chart            = "p0-helm-oauthed-mcp"
  version          = local.chart_version

  values = var.values
}
