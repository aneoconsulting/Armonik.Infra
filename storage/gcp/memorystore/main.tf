data "google_client_config" "current" {}

locals {
  location_id             = data.google_client_config.current.zone
  alternative_location_id = var.tier == "STANDARD_HA" && coalesce(var.alternative_location_id, local.location_id) != local.location_id ? var.alternative_location_id : null
  labels                  = merge(var.labels, { module = "memorystore" })
  replica_count           = var.tier == "STANDARD_HA" ? (var.read_replicas_mode == "READ_REPLICAS_ENABLED" ? coalesce(var.replica_count, 2) : 1) : 0
  read_replicas_mode      = var.tier == "STANDARD_HA" ? var.read_replicas_mode : null
}

resource "google_redis_instance" "cache" {
  name                    = var.name
  memory_size_gb          = var.memory_size_gb
  alternative_location_id = local.alternative_location_id
  auth_enabled            = var.auth_enabled
  authorized_network      = var.authorized_network
  connect_mode            = var.connect_mode
  display_name            = var.display_name
  labels                  = local.labels
  redis_configs           = var.redis_configs
  location_id             = local.location_id
  redis_version           = var.redis_version
  reserved_ip_range       = var.reserved_ip_range
  tier                    = var.tier
  transit_encryption_mode = var.transit_encryption_mode
  replica_count           = local.replica_count
  read_replicas_mode      = local.read_replicas_mode
  secondary_ip_range      = var.secondary_ip_range
  region                  = data.google_client_config.current.region
  project                 = data.google_client_config.current.project
  customer_managed_key    = var.customer_managed_key
  dynamic "persistence_config" {
    for_each = can(coalesce(var.persistence_config)) ? [var.persistence_config] : []
    content {
      persistence_mode        = persistence_config.value["persistence_mode"]
      rdb_snapshot_period     = persistence_config.value["rdb_snapshot_period"]
      rdb_snapshot_start_time = persistence_config.value["rdb_snapshot_start_time"]
    }
  }
  dynamic "maintenance_policy" {
    for_each = can(coalesce(var.maintenance_policy)) ? [var.maintenance_policy] : []
    content {
      weekly_maintenance_window {
        day = maintenance_policy.value["day"]
        start_time {
          hours   = maintenance_policy.value["start_time"]["hours"]
          minutes = maintenance_policy.value["start_time"]["minutes"]
          seconds = maintenance_policy.value["start_time"]["seconds"]
          nanos   = maintenance_policy.value["start_time"]["nanos"]
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [maintenance_schedule]
  }
}
