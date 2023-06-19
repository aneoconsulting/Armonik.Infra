# AWS EC2 Instance Terraform Variables
# EC2 Instance Variables

# AWS EC2 Instance Type
variable "node_type" {
  description = "Node type: master or worker"
  type        = string
  validation {
    condition     = contains(["master", "worker"], var.node_type)
    error_message = "Possible values for the parameter node_type are \"master\" or \"worker\"."
  }
}

variable "master_node_name" {
  description = "The name of the cluster master node."
  type        = string
  default     = "master"
}

# AWS EC2 Instance Key Pair
variable "master_public_ip" {
  description = "The public ip of the master node."
  type        = string
}

# AWS EC2 Private Instance Count
variable "master_private_ip" {
  description = "The private ip of the master node."
  type        = string
}

variable "user" {
  description = "user used to execute docker + kubernetes scripts. must be updated accordingly with the linux image used"
  type        = string
}

variable "tls_private_key_pem" {
  description = "The private key of the master node."
  type        = string
}

variable "kubeadm_token" {
  description = "The generated kubeadm token used by worker node to join the master"
  type        = string
}

variable "cni_pluggin" {
  description = "The cni plugin to be used. calico or flannel"
  type        = string
  default     = "calico"
  validation {
    condition     = contains(["calico", "flannel"], var.cni_pluggin)
    error_message = "Possible values for the parameter cni_pluggin are \"calico\" or \"flannel\"."
  }
}

variable "cni_pluggin_cidr" {
  description = "The cidr of cni pluggin used by kubeadm configuration on master"
  type        = string
  default     = null
}

variable "loadbalancer_plugin" {
  description = "loadbalancer plugin to be used. Only metalLB or no Loadbalancer for now"
  type        = string
  default     = ""
  validation {
    condition     = contains(["metalLB", ""], var.loadbalancer_plugin)
    error_message = "Possible values for the parameter loadbalancer_plugin are \"metalLB\" or empty \"\"."
  }
}

variable "workers" {
  description = "The worker nodes to be deployed."
  type = map(object({
    instance_count = optional(number, 1)
    label          = optional(list(string), [])
    name           = string
    public_dns     = string
    taints         = optional(list(string), [])
  }))
}
#ex:
# "worker-1" = {
#   "instance_count" = 1
#   "labels" = tolist([
#     "workers",
#   ])
#   "name" = "worker-1"
#   "public_dns" = "ec2-3-8-5-81.eu-west-2.compute.amazonaws.com"
#   "taints" = tolist([
#     "workers",
#   ])
# }
