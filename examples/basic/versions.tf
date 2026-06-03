terraform {
  required_version = "1.14.4"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.2"
    }
  }
}
