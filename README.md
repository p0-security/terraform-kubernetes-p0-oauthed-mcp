# terraform-kubernetes-p0-oauthed-mcp

Terraform module that deploys [oauthed-mcp](https://github.com/p0-security/oauthed-mcp-tools) via the [p0-helm-oauthed-mcp](https://github.com/p0-security/p0-helm-oauthed-mcp) umbrella Helm chart. The chart bundles Envoy Gateway, cert-manager, Let's Encrypt (ACME HTTP-01), PostgreSQL, and Valkey into a single install.

## Usage

```hcl
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

module "oauthed_mcp" {
  source  = "p0-security/p0-oauthed-mcp/kubernetes"
  version = "0.1.10"

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

There is no secret setup step to run before `terraform apply`. The chart creates `app-secrets` itself, from a pre-install hook. The cluster prerequisites still apply, though — a working block-storage StorageClass for the bundled PostgreSQL, which on EKS means the EBS CSI driver add-on. Those are listed in the [p0-helm-oauthed-mcp deployment guide](https://github.com/p0-security/p0-helm-oauthed-mcp#prerequisites).

Afterwards, patch in the real OIDC client secret, and on an external database the real PostgreSQL password. The hook writes a placeholder for the first and never overwrites either once set. Restart both Deployments after patching — they read the Secret when a pod starts, so running pods keep the old value until they are replaced:

```bash
kubectl -n <namespace> patch secret app-secrets \
  --type merge \
  -p '{"stringData":{"OIDC_CLIENT_SECRET":"<your-oidc-client-secret>"}}'

kubectl -n <namespace> rollout restart deploy/oauth-server deploy/mcp-unified-server
```

If your secrets already come from External Secrets or Vault, set `oauthed-mcp.generateSecrets: false` in `values` and create the Secret yourself. It has to exist before the release is created, so with `create_namespace = true` the namespace does not exist yet at that point — create it outside Terraform and set `create_namespace = false`, or let a separate `kubernetes_namespace` resource own it.

For all post-deploy steps (DNS, verification, staging→prod), follow the [deployment guide](https://github.com/p0-security/p0-helm-oauthed-mcp#deploy).

## Compatibility matrix

Each module version pins an exact chart version. To use a specific chart version, use the corresponding module version.

| Module version | Chart version |
|----------------|---------------|
| 0.1.10         | 0.10.1        |
| 0.1.9          | 0.8.6         |
| 0.1.8          | 0.8.5         |
| 0.1.7          | 0.8.4         |
| 0.1.6          | 0.8.3         |
| 0.1.5          | 0.8.2         |
| 0.1.4          | 0.8.1         |
| 0.1.3          | 0.8.0         |
| 0.1.2          | 0.7.2         |
| 0.1.1          | 0.7.1         |
| 0.1.0          | 0.7.1         |

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
