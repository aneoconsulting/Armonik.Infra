output "endpoint_urls" {
  description = "List of URL endpoints for: control-plane, Seq, Grafana and Admin GUI"
  value = var.ingress != null ? {
    control_plane_url = local.ingress_grpc_url != "" ? local.ingress_grpc_url : local.control_plane_url
    grafana_url       = data.kubernetes_secret.grafana.data.enabled ? (local.ingress_http_url != "" ? "${local.ingress_http_url}/grafana/" : nonsensitive(data.kubernetes_secret.grafana.data.url)) : ""
    seq_web_url       = data.kubernetes_secret.seq.data.enabled ? (local.ingress_http_url != "" ? "${local.ingress_http_url}/seq/" : nonsensitive(data.kubernetes_secret.seq.data.web_url)) : ""
    admin_app_url     = length(kubernetes_service.admin_gui) > 0 ? (local.ingress_http_url != "" ? "${local.ingress_http_url}/admin" : local.admin_app_url) : null
    admin_api_url     = length(kubernetes_service.admin_0_8_gui) > 0 ? (local.ingress_http_url != "" ? "${local.ingress_http_url}/api" : local.admin_api_url) : null
    admin_0_8_url     = length(kubernetes_service.admin_0_8_gui) > 0 ? (local.ingress_http_url != "" ? "${local.ingress_http_url}/admin-0.8" : local.admin_0_8_url) : null
    admin_0_9_url     = length(kubernetes_service.admin_0_9_gui) > 0 ? (local.ingress_http_url != "" ? "${local.ingress_http_url}/admin-0.9" : local.admin_0_9_url) : null
    } : {
    control_plane_url = local.control_plane_url
    grafana_url       = nonsensitive(data.kubernetes_secret.grafana.data.url)
    seq_web_url       = nonsensitive(data.kubernetes_secret.seq.data.web_url)
    admin_app_url     = local.admin_app_url
    admin_api_url     = local.admin_api_url
    admin_0_8_url     = local.admin_0_8_url
    admin_0_9_url     = local.admin_0_9_url
  }
}

output "object_storage_adapter" {
  description = "Adapter used for the object storage"
  value       = local.object_storage_adapter_from_secret
  precondition {
    condition     = can(coalesce(local.object_storage_adapter_from_secret)) || contains(["mongodb", "redis", "s3", "localstorage"], local.object_storage_adapter_from_secret)
    error_message = "Object storage adapter must be non-null and non-empty-string. Valid values: \"MongoDB\" | \"Redis\" | \"S3\" | \"LocalStorage\""
  }
}

output "table_storage_adapter" {
  description = "Adapter used for the table storage"
  value       = local.table_storage_adapter_from_secret
  precondition {
    condition     = can(coalesce(local.table_storage_adapter_from_secret)) || contains(["mongodb"], local.table_storage_adapter_from_secret)
    error_message = "Table storage adapter\" must be non-null and non-empty-string. Valid values: \"MongoDB\""
  }
}

# output "queue_storage_adapter" {
#   description = "Adapter used for the quque storage"
#   value       = local.queue_storage_adapter_from_secret
#   precondition {
#     condition     = can(coalesce(local.queue_storage_adapter_from_secret)) || contains(["amqp"], local.queue_storage_adapter_from_secret)
#     error_message = "\"Queue storage adapter\" must be non-null and non-empty-string. Valid values: \"Amqp\""
#   }
# }

output "object_storage_adapter_check" {
  description = "Check the adapter used for the object storage"
  value       = local.object_storage_adapter_from_secret
  precondition {
    condition     = contains([for each in local.deployed_object_storages : lower(each)], local.object_storage_adapter_from_secret)
    error_message = "Can't use ${nonsensitive(local.object_storage_adapter)} because it has not been deployed. Deployed storages are : ${join(",", nonsensitive(local.deployed_object_storages))}"
  }
}

output "table_storage_adapter_check" {
  description = "Check the adapter used for the table storage"
  value       = local.table_storage_adapter_from_secret
  precondition {
    condition     = contains([for each in local.deployed_table_storages : lower(each)], local.table_storage_adapter_from_secret)
    error_message = "Can't use ${nonsensitive(local.table_storage_adapter)} because it has not been deployed. Deployed storages are : ${join(",", nonsensitive(local.deployed_table_storages))}"
  }
}

# output "queue_storage_adapter_check" {
#   description = "Check the adapter used for the queue storage"
#   value       = local.queue_storage_adapter_from_secret
#   precondition {
#     condition     = contains([for each in local.deployed_queue_storages : lower(each)], local.queue_storage_adapter_from_secret)
#     error_message = "Can't use ${nonsensitive(local.queue_storage_adapter)} because it has not been deployed. Deployed storages are : ${join(",", nonsensitive(local.deployed_queue_storages))}"
#   }
# }
