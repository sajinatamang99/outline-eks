variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "eks_cluster_endpoint" {
  type        = string
  description = "EKS cluster API endpoint"
}

variable "external_dns_role_arn" {
  type        = string
  description = "IAM role ARN for external-dns"
}
