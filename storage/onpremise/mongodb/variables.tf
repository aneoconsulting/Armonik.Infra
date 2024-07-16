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
    storage_provisioner = string
    volume_binding_mode = string
    parameters          = optional(map(string), {})

    # Resources for PVC
    resources = object({
      limits = object({
        storage = string
      })
      requests = object({
        storage = string
      })
    })

    wait_until_bound = optional(bool, true)
  })
  default = null

  # For retrocompatibility concerns (AWS deployment), this variable must be null for now
  validation {
    condition     = var.persistent_volume == null
    error_message = <<EOT
    "For now, 'persistent_volume' variable must be null.
    Custom persistent volume definition for MongoDB is soon to be implemented"
    EOT
  }
}

# Not used yet (there for retrocompatibility reasons)
variable "security_context" {
  description = "Security context for MongoDB pods"
  type = object({
    run_as_user = number
    fs_group    = number
  })
  default = {
    run_as_user = 999
    fs_group    = 999
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
