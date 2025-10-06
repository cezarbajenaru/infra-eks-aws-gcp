# Get current AWS account ID
data "aws_caller_identity" "current" {}

module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

aws_auth_roles = concat([ #used for node group roles so you can add auto add users to the cluster
  # Node group roles
  for ng_name, ng in module.eks.eks_managed_node_groups : {
    rolearn  = ng.iam_role_arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:bootstrappers", "system:nodes"]
  }
], [
  # IRSA roles for common applications
  {
    rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-eks-external-secrets-role" #used for external secrets
    username = "external-secrets"
    groups   = ["system:masters"]
  },
  {
    rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-eks-alb-controller-role" #used for alb controller, so you can use alb controller in the cluster
    username = "alb-controller"
    groups   = ["system:masters"]
  },
  {
    rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-eks-cluster-autoscaler-role" #used for cluster autoscaler, so you can use cluster autoscaler in the cluster
    username = "cluster-autoscaler"
    groups   = ["system:masters"]
  }
])


  aws_auth_users = [ # you can add other users here, so you can log other users into the cluster, they will be added to the aws-auth configmap, you can also add groups here, so you can add groups to the aws-auth configmap
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [] # with this you can log other accounts into the cluster
}