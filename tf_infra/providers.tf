terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.15.0, < 7.0" # my eks terraform module requires 6.15.0
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
  }

  backend "s3" {
    bucket       = "eksproject-prodbackend"
    key          = "tf_infra/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true #S3 native locking
  }
}

provider "aws" {
  region = local.region
}

# Rolling new tokens for cluster certificate
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", local.name]
      command     = "aws"
    }
  }
}