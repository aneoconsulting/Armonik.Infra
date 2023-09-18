# Current account
data "aws_caller_identity" "current" {}

# this external provider is used to get date during the plan step.
data "external" "static_timestamp" {
  program = ["date", "+{ \"creation_date\": \"%Y/%m/%d %T\" }"]
}

# this resource is just used to prevent change of the creation_date during successive 'terraform apply'
resource "null_resource" "timestamp" {
  triggers = {
    creation_date = data.external.static_timestamp.result.creation_date
  }
  lifecycle {
    ignore_changes = [triggers]
  }
}

# VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# AWS EKS
module "eks" {
  source  = "../../../eks"
  profile = var.aws_profile
  tags = {
    env             = "test"
    app             = "complete"
    module          = "AWS eks"
    "create by"     = data.aws_caller_identity.current.arn
    "creation date" = null_resource.timestamp.triggers["creation_date"]
  }
  name = "test-cluster"
  #node_selector   = var.node_selector
  kubeconfig_file                      = "generated/kubeconfig"
  vpc_id                               = data.aws_vpc.default.id
  vpc_private_subnet_ids               = data.aws_subnets.subnets.ids
  vpc_pods_subnet_ids                  = data.aws_subnets.subnets.ids
  cluster_version                      = "1.25"
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  cluster_log_retention_in_days        = 30
  eks_managed_node_groups = {
    test = {
      name                        = "test"
      launch_template_description = "Managed node group for test"
      ami_type                    = "AL2_x86_64"
      instance_types              = ["c5.large"]
      capacity_type               = "SPOT"
      min_size                    = 1
      desired_size                = 1
      max_size                    = 1000
      labels = {
        service                        = "workers"
        "node.kubernetes.io/lifecycle" = "spot"
      }
      taints = {
        dedicated = {
          key    = "service"
          value  = "workers"
          effect = "NO_SCHEDULE"
        }
      }
      iam_role_use_name_prefix = false
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }
  self_managed_node_groups = {
    self-test = {
      name                        = "self-test"
      launch_template_description = "Self managed node group for test"
      instance_type               = "c5.large"
      min_size                    = 1
      desired_size                = 1
      max_size                    = 5
      force_delete                = true
      force_delete_warm_pool      = true
      instance_market_options = {
        market_type = "spot"
      }
      bootstrap_extra_args     = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
      iam_role_use_name_prefix = false
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }
  fargate_profiles                                         = {}
  cluster_autoscaler_expander                              = "least-waste"
  cluster_autoscaler_image                                 = "registry.k8s.io/autoscaling/cluster-autoscaler"
  cluster_autoscaler_tag                                   = "v1.23.0"
  cluster_autoscaler_max_node_provision_time               = "15m0s"
  cluster_autoscaler_min_replica_count                     = 0
  cluster_autoscaler_namespace                             = "kube-system"
  cluster_autoscaler_repository                            = "https://kubernetes.github.io/autoscaler"
  cluster_autoscaler_scale_down_delay_after_add            = "2m"
  cluster_autoscaler_scale_down_delay_after_delete         = "0s"
  cluster_autoscaler_scale_down_delay_after_failure        = "3m"
  cluster_autoscaler_scale_down_enabled                    = true
  cluster_autoscaler_scale_down_non_empty_candidates_count = 30
  cluster_autoscaler_scale_down_unneeded_time              = "2m"
  cluster_autoscaler_scale_down_utilization_threshold      = 0
  cluster_autoscaler_scan_interval                         = "10s"
  cluster_autoscaler_skip_nodes_with_system_pods           = true
  cluster_autoscaler_version                               = "9.24.0"
  cluster_encryption_config                                = ""
  cluster_log_kms_key_id                                   = ""
  ebs_kms_key_id                                           = ""
  instance_refresh_image                                   = "public.ecr.aws/aws-ec2/aws-node-termination-handler"
  instance_refresh_tag                                     = "v1.19.0"
  instance_refresh_namespace                               = "kube-system"
  instance_refresh_repository                              = "https://aws.github.io/eks-charts"
  instance_refresh_version                                 = "0.21.0"
  map_roles_groups                                         = []
  map_users_groups                                         = []
}
