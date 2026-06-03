# terraform-kubernetes-oauthed-mcp

Terraform module that deploys [oauthed-mcp](https://github.com/p0-security/oauthed-mcp-tools) via the [p0-helm-oauthed-mcp](https://github.com/p0-security/p0-helm-oauthed-mcp) umbrella Helm chart. The chart bundles Envoy Gateway, cert-manager, and Let's Encrypt (ACME HTTP-01) into a single install.

## Usage

```hcl
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

module "oauthed_mcp" {
  source  = "p0-security/oauthed-mcp/kubernetes"
  version = "1.0.0"

  values = [
    file("${path.module}/values.yaml"),
    yamlencode({
      letsEncrypt = {
        email = var.acme_email
        env   = "prod"
      }
      "oauthed-mcp" = {
        gateway = {
          className = "oauthed-mcp"  # must be unique per release in the cluster
        }
      }
    }),
  ]
}
```

Values are merged left-to-right (last wins), equivalent to `helm install -f`. See the [chart's values.yaml](https://github.com/p0-security/p0-helm-oauthed-mcp/blob/main/values.yaml) for the full schema.

Before applying, and for all post-deploy steps (DNS, verification, staging→prod), follow the [p0-helm-oauthed-mcp deployment guide](https://github.com/p0-security/p0-helm-oauthed-mcp#deploy).

## Compatibility matrix

Each module version pins an exact chart version. To use a specific chart version, use the corresponding module version.

| Module version | Chart version |
|----------------|---------------|
| 1.0.0          | 0.7.1         |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7 |
| helm | >= 3.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| release\_name | Helm release name. | `string` | `"oauthed-mcp"` |
| namespace | Kubernetes namespace to deploy into. | `string` | `"oauthed-mcp"` |
| create\_namespace | Create the namespace if it does not exist. | `bool` | `true` |
| values | List of YAML values strings merged left-to-right. | `list(string)` | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| release\_name | Name of the Helm release. |
| namespace | Namespace the release was deployed into. |
| chart\_version | Chart version that was deployed. |
