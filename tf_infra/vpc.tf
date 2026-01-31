## VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true


  public_subnet_tags = {
    "kubernetes.io/cluster/${local.vpc_name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.vpc_name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = local.tags
}
