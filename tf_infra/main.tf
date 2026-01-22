# AWS Provider and Region Setup with Long-Lived Role
provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  vpc_name        = var.vpc_name
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  azs             = data.aws_availability_zones.available.names
}

module "ecr" {
  source = "./modules/ecr"
}
module "eks" {
  source                     = "./modules/eks"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  cluster_security_group_ids = [module.vpc.eks_cluster_sg.id]
}
