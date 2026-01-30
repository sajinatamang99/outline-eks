module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"
  name               = local.name
  kubernetes_version = "1.33"

  # cluster_endpoint_public_access = true
  endpoint_public_access = true
  endpoint_private_access      = true
  
  endpoint_public_access_cidrs = ["0.0.0.0/0"]
  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    worker1 = {
      instance_types = ["t3.large"]
      min_size     = 1
      max_size     = 2
      desired_size = 1
      disk_size = 20
    }
  }

  tags = local.tags
}