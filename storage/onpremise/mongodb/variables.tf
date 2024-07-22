variable "namespace" {
  description = "Namespace of ArmoniK resources"
  type        = string
  default     = "default"
}

variable "labels" {
  description = "Labels for the Kubernetes StatefulSet to be deployed"
  type        = map(string)
  default = {
    "app"  = "storage"
    "type" = "table"
  }
}

variable "name" {
  description = "Name used for the helm chart release and the associated resources"
  type        = string
  default     = "mongodb-armonik"
  validation {
    condition     = length(var.name) < 54
    error_message = "Helm release name must be shorter than 54 characters"
  }
}

variable "mongodb" {
  description = "Parameters of the MongoDB deployment"

  type = object({
    databases_names       = optional(list(string), ["database"])
    helm_chart_repository = optional(string, "oci://registry-1.docker.io/bitnamicharts")
    helm_chart_name       = optional(string, "mongodb")
    helm_chart_version    = string
    image                 = optional(string, "bitnami/mongodb")
    image_pull_secrets    = optional(any, [""]) # can be a string or a list of strings
    node_selector         = optional(map(string), {})
    registry              = optional(string)
    replicas              = optional(number, 1)
    tag                   = string
  })
}

variable "persistent_volume" {
  description = "Persistent Volume parameters for MongoDB pods"
  type = object({
    access_mode         = optional(list(string), ["ReadWriteMany"])
    reclaim_policy      = optional(string, "Delete")
    storage_provisioner = optional(string, "")
    volume_binding_mode = optional(string, "")
    parameters          = optional(map(string), {})

    # Resources for PVC
    resources = optional(object({
      limits = optional(object({
        storage = string
      }))
      requests = optional(object({
        storage = string
      }))
    }))
  })
  default = null
}

variable "security_context" {
  description = "Security context for MongoDB pods"
  type = object({
    run_as_user = number
    fs_group    = number
  })
  default = {
    run_as_user = 1001
    fs_group    = 1001
  }
}

# variable "mtls" {
#   description = "Whether to deploy MongoDB with mTLS"
#   type        = bool
#   default     = false
# }

variable "timeout" {
  description = "Timeout limit in seconds per replica for the helm release creation"
  type        = number
  default     = 480 # 8 minutes
}

# Not used yet (there for retrocompatibility reasons)
# The certificates generated by bitnami's MongoDB Helm chart are valid for 10 years
variable "validity_period_hours" {
  description = "Validity period of the TLS certificate in hours"
  type        = string
  default     = "8760" # 1 year
}
