locals {
  cluster_name = "eks-cluster"
  vpc_name = "eks-vpc"
  # domain = "devopsproject.org"
  region           = "us-east-1"
  azs              = ["us-east-1a", "us-east-1b"]
  vpc_cidr         = "10.0.0.0/16"
  hosted_zones_arn = "arn:aws:route53:::hostedzone/Z015437421LGNPHC43B54"

  tags = {
    project = "outline"
  }
}
