output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns.arn
}
