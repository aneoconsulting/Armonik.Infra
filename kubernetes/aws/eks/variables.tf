# Profile
variable "profile" {
  description = "Profile of AWS credentials to deploy Terraform sources"
  type        = string
}

# Namespace helm chart
variable "chart_namespace" {
  type        = string
  description = "Version for chart"
  default     = "default" # Enter your desired namespace of helm chart here
}

# Version helm chart
variable "chart_version" {
  type        = string
  description = "Version for chart"
  default     = "0.1.0" # Enter your desired version of helm chart here
}

# Name helm chart
variable "chart_name" {
  type        = string
  description = "Name for chart"
  default     = "eniconfig" # Enter your desired name of Helm chart here
}

# Path helm chart
variable "chart_repository" {
  type        = string
  description = "Path to the charts repository"
  default     = "../../../charts" # Enter your desired relative path here
}

# Kubeconfig file path
variable "kubeconfig_file" {
  description = "Kubeconfig file path"
  type        = string
}

# Tags
variable "tags" {
  description = "Tags for resource"
  type        = map(string)
  default     = {}
}

# EKS name
variable "name" {
  description = "AWS EKS service name"
  type        = string
  default     = "armonik-eks"
}

# Node selector
variable "node_selector" {
  description = "Node selector for pods of EKS system"
  type        = any
  default     = {}
}

# VPC infos
variable "vpc" {
  description = "AWS VPC info"
  type = object({
    id                 = string
    private_subnet_ids = list(string)
    pods_subnet_ids    = list(string)
  })
}

# EKS
variable "eks" {
  description = "Parameters of AWS EKS"
  type = object({
    cluster_version                       = string
    cluster_endpoint_private_access       = bool
    cluster_endpoint_private_access_cidrs = list(string)
    cluster_endpoint_private_access_sg    = list(string)
    cluster_endpoint_public_access        = bool
    cluster_endpoint_public_access_cidrs  = list(string)
    cluster_log_retention_in_days         = number
    docker_images = object({
      cluster_autoscaler = object({
        image = string
        tag   = string
      })
      instance_refresh = object({
        image = string
        tag   = string
      })
    })
    cluster_autoscaler = object({
      expander                              = string
      scale_down_enabled                    = bool
      min_replica_count                     = number
      scale_down_utilization_threshold      = number
      scale_down_non_empty_candidates_count = number
      max_node_provision_time               = string
      scan_interval                         = string
      scale_down_delay_after_add            = string
      scale_down_delay_after_delete         = string
      scale_down_delay_after_failure        = string
      scale_down_unneeded_time              = string
      skip_nodes_with_system_pods           = bool
      version                               = string
      repository                            = string
      namespace                             = string
    })
    instance_refresh = object({
      namespace  = string
      repository = string
      version    = string
    })
    efs_csi = object({
      name               = string
      namespace          = string
      image_pull_secrets = string
      repository         = string
      version            = string
      docker_images = object({
        efs_csi = object({
          image = string
          tag   = string
        })
        livenessprobe = object({
          image = string
          tag   = string
        })
        node_driver_registrar = object({
          image = string
          tag   = string
        })
        external_provisioner = object({
          image = string
          tag   = string
        })
      })
    })
    encryption_keys = object({
      cluster_log_kms_key_id    = string
      cluster_encryption_config = string
      ebs_kms_key_id            = string
    })
    map_roles = list(object({
      rolearn  = string
      username = string
      groups   = list(string)
    }))
    map_users = list(object({
      userarn  = string
      username = string
      groups   = list(string)
    }))
  })
  validation {
    condition     = contains(["random", "most-pods", "least-waste", "price", "priority"], var.eks.cluster_autoscaler.expander)
    error_message = "Valid values for \"expander\" of the cluster-autoscaler: \"random\" | \"most-pods\" | \"least-waste\" | \"price\" | \"priority\"."
  }
}

# List of EKS managed node groups
variable "eks_managed_node_groups" {
  description = "List of EKS managed node groups"
  type        = any
  default     = null
}

# List of self managed node groups
variable "self_managed_node_groups" {
  description = "List of self managed node groups"
  type        = any
  default     = null
}

# List of fargate profiles
variable "fargate_profiles" {
  description = "List of fargate profiles"
  type        = any
  default     = null
}
