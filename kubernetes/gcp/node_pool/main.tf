/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Configuration in the current provider
data "google_client_config" "current" {}

locals {
  regional   = length(split("-", var.cluster_location)) == 2
  location   = coalesce(var.cluster_location, data.google_client_config.current.region)

  // When a release channel is used, node auto-upgrade is enabled and cannot be disabled.
  default_auto_upgrade = local.regional || var.release_channel != "UNSPECIFIED" ? true : false

  cluster_network_tag         = "gke-${var.cluster_name}"
}

resource "google_container_node_pool" "pools" {
  provider = google
  for_each = var.node_pools
  name     = each.key
  project  = data.google_client_config.current.project
  location = local.location
  // use node_locations if provided, defaults to cluster level node_locations if not specified
  node_locations = lookup(each.value, "node_locations", "") != "" ? split(",", each.value["node_locations"]) : null

  cluster = var.cluster_name

  version = lookup(each.value, "auto_upgrade", local.default_auto_upgrade) ? "" : lookup(
    each.value,
    "version",
    var.min_master_version,
  )

  initial_node_count = lookup(each.value, "autoscaling", true) ? lookup(
    each.value,
    "initial_node_count",
    lookup(each.value, "min_count", 1)
  ) : null

  max_pods_per_node = lookup(each.value, "max_pods_per_node", null)

  node_count = lookup(each.value, "autoscaling", true) ? null : lookup(each.value, "node_count", 1)

  dynamic "autoscaling" {
    for_each = lookup(each.value, "autoscaling", true) ? [each.value] : []
    content {
      min_node_count       = contains(keys(autoscaling.value), "total_min_count") ? null : lookup(autoscaling.value, "min_count", 1)
      max_node_count       = contains(keys(autoscaling.value), "total_max_count") ? null : lookup(autoscaling.value, "max_count", 100)
      location_policy      = lookup(autoscaling.value, "location_policy", null)
      total_min_node_count = lookup(autoscaling.value, "total_min_count", null)
      total_max_node_count = lookup(autoscaling.value, "total_max_count", null)
    }
  }

  management {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", local.default_auto_upgrade)
  }

  upgrade_settings {
    strategy        = lookup(each.value, "strategy", "SURGE")
    max_surge       = lookup(each.value, "strategy", "SURGE") == "SURGE" ? lookup(each.value, "max_surge", 1) : null
    max_unavailable = lookup(each.value, "strategy", "SURGE") == "SURGE" ? lookup(each.value, "max_unavailable", 0) : null
    dynamic "blue_green_settings" {
      for_each = lookup(each.value, "strategy", "SURGE") == "BLUE_GREEN" ? [1] : []
      content {
        node_pool_soak_duration = lookup(each.value, "node_pool_soak_duration", null)
        standard_rollout_policy {
          batch_soak_duration = lookup(each.value, "batch_soak_duration", null)
          batch_percentage    = lookup(each.value, "batch_percentage", null)
          batch_node_count    = lookup(each.value, "batch_node_count", null)
        }
      }
    }
  }

  node_config {
    image_type       = lookup(each.value, "image_type", "COS_CONTAINERD")
    machine_type     = lookup(each.value, "machine_type", "e2-medium")
    min_cpu_platform = lookup(each.value, "min_cpu_platform", "")
    dynamic "gcfs_config" {
      for_each = lookup(each.value, "enable_gcfs", false) ? [true] : []
      content {
        enabled = gcfs_config.value
      }
    }
    dynamic "gvnic" {
      for_each = lookup(each.value, "enable_gvnic", false) ? [true] : []
      content {
        enabled = gvnic.value
      }
    }
    labels = merge(
      var.labels,
      lookup(each.value, "labels", {})
    )
    resource_labels = merge(
      var.resource_labels,
      lookup(each.value, "resource_labels", {})
    )
    metadata = merge(
      var.node_pools_metadata,
      lookup(each.value, "metadata", {}),
      {
        "disable-legacy-endpoints" = var.disable_legacy_metadata_endpoints
      }
    )

    dynamic "taint" {
      for_each = lookup(each.value, "taint", null) != null ? each.value.taint : []
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.value
      }
    }

    tags = concat(
      var.node_pools_tags,
      lookup(each.value, "tags", [])
    )

    local_ssd_count = lookup(each.value, "local_ssd_count", 0)
    disk_size_gb    = lookup(each.value, "disk_size_gb", 100)
    disk_type       = lookup(each.value, "disk_type", "pd-standard")


    service_account = "gke-gke-on-vpc-cluster-sa@armonik-gcp-13469.iam.gserviceaccount.com"
    preemptible = lookup(each.value, "preemptible", false)
    spot        = lookup(each.value, "spot", false)

    oauth_scopes = concat(
      var.oauth_scopes,
      lookup(each.value, "oauth_scopes", []),
    )

    dynamic "guest_accelerator" {
      for_each = lookup(each.value, "accelerator_count", 0) > 0 ? [1] : []
      content {
        type               = lookup(each.value, "accelerator_type", "")
        count              = lookup(each.value, "accelerator_count", 0)
        gpu_partition_size = lookup(each.value, "gpu_partition_size", null)
      }
    }

    workload_metadata_config {
      mode = lookup(each.value, "node_metadata", var.node_metadata)
    }

    dynamic "linux_node_config" {
      for_each = lookup(each.value, "linux_node_config", null) != null ? each.value.linux_node_config : []
      content {
        sysctls = linux_node_config.value
      }
    }

    boot_disk_kms_key = lookup(each.value, "boot_disk_kms_key", "")

    shielded_instance_config {
      enable_secure_boot          = lookup(each.value, "enable_secure_boot", false)
      enable_integrity_monitoring = lookup(each.value, "enable_integrity_monitoring", true)
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = lookup(var.timeouts, "create", "45m")
    update = lookup(var.timeouts, "update", "45m")
    delete = lookup(var.timeouts, "delete", "45m")
  }
}

resource "google_container_node_pool" "windows_pools" {
  provider = google
  for_each = var.windows_node_pools
  name     = each.key
  project  = data.google_client_config.current.project
  location = local.location
  // use node_locations if provided, defaults to cluster level node_locations if not specified
  node_locations = lookup(each.value, "node_locations", "") != "" ? split(",", each.value["node_locations"]) : null

  cluster = var.cluster_name

  version = lookup(each.value, "auto_upgrade", local.default_auto_upgrade) ? "" : lookup(
    each.value,
    "version",
    var.min_master_version,
  )

  initial_node_count = lookup(each.value, "autoscaling", true) ? lookup(
    each.value,
    "initial_node_count",
    lookup(each.value, "min_count", 1)
  ) : null

  max_pods_per_node = lookup(each.value, "max_pods_per_node", null)

  node_count = lookup(each.value, "autoscaling", true) ? null : lookup(each.value, "node_count", 1)

  dynamic "autoscaling" {
    for_each = lookup(each.value, "autoscaling", true) ? [each.value] : []
    content {
      min_node_count       = contains(keys(autoscaling.value), "total_min_count") ? null : lookup(autoscaling.value, "min_count", 1)
      max_node_count       = contains(keys(autoscaling.value), "total_max_count") ? null : lookup(autoscaling.value, "max_count", 100)
      location_policy      = lookup(autoscaling.value, "location_policy", null)
      total_min_node_count = lookup(autoscaling.value, "total_min_count", null)
      total_max_node_count = lookup(autoscaling.value, "total_max_count", null)
    }
  }

  management {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", local.default_auto_upgrade)
  }

  upgrade_settings {
    strategy        = lookup(each.value, "strategy", "SURGE")
    max_surge       = lookup(each.value, "strategy", "SURGE") == "SURGE" ? lookup(each.value, "max_surge", 1) : null
    max_unavailable = lookup(each.value, "strategy", "SURGE") == "SURGE" ? lookup(each.value, "max_unavailable", 0) : null

    dynamic "blue_green_settings" {
      for_each = lookup(each.value, "strategy", "SURGE") == "BLUE_GREEN" ? [1] : []
      content {
        node_pool_soak_duration = lookup(each.value, "node_pool_soak_duration", null)

        standard_rollout_policy {
          batch_soak_duration = lookup(each.value, "batch_soak_duration", null)
          batch_percentage    = lookup(each.value, "batch_percentage", null)
          batch_node_count    = lookup(each.value, "batch_node_count", null)
        }
      }
    }
  }

  node_config {
    image_type       = lookup(each.value, "image_type", "COS_CONTAINERD")
    machine_type     = lookup(each.value, "machine_type", "e2-medium")
    min_cpu_platform = lookup(each.value, "min_cpu_platform", "")
    dynamic "gcfs_config" {
      for_each = lookup(each.value, "enable_gcfs", false) ? [true] : []
      content {
        enabled = gcfs_config.value
      }
    }
    dynamic "gvnic" {
      for_each = lookup(each.value, "enable_gvnic", false) ? [true] : []
      content {
        enabled = gvnic.value
      }
    }
    labels = merge(
      var.labels,
      lookup(each.value, "labels", {})
    )
    resource_labels = merge(
      var.resource_labels,
      lookup(each.value, "resource_labels", {})
    )
    metadata = merge(
      var.node_pools_metadata,
      lookup(each.value, "metadata", {}),
      {
        "disable-legacy-endpoints" = var.disable_legacy_metadata_endpoints
      }
    )

    dynamic "taint" {
      for_each = lookup(each.value, "taint", null) != null ? each.value.taint : []
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.value
      }
    }
    tags = concat(
      var.node_pools_tags,
      lookup(each.value, "tags", [])
    )

    local_ssd_count = lookup(each.value, "local_ssd_count", 0)
    disk_size_gb    = lookup(each.value, "disk_size_gb", 100)
    disk_type       = lookup(each.value, "disk_type", "pd-standard")

    service_account = "gke-gke-on-vpc-cluster-sa@armonik-gcp-13469.iam.gserviceaccount.com"
    preemptible = lookup(each.value, "preemptible", false)
    spot        = lookup(each.value, "spot", false)

    oauth_scopes = concat(
      var.oauth_scopes,
      lookup(each.value, "oauth_scopes", []),
    )

    dynamic "guest_accelerator" {
      for_each = lookup(each.value, "accelerator_count", 0) > 0 ? [1] : []
      content {
        type               = lookup(each.value, "accelerator_type", "")
        count              = lookup(each.value, "accelerator_count", 0)
        gpu_partition_size = lookup(each.value, "gpu_partition_size", null)
      }
    }

    workload_metadata_config {
      mode = lookup(each.value, "node_metadata", var.node_metadata)
    }

    boot_disk_kms_key = lookup(each.value, "boot_disk_kms_key", "")

    shielded_instance_config {
      enable_secure_boot          = lookup(each.value, "enable_secure_boot", false)
      enable_integrity_monitoring = lookup(each.value, "enable_integrity_monitoring", true)
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count]

  }

  timeouts {
    create = lookup(var.timeouts, "create", "45m")
    update = lookup(var.timeouts, "update", "45m")
    delete = lookup(var.timeouts, "delete", "45m")
  }

  depends_on = [google_container_node_pool.pools[0]]
}