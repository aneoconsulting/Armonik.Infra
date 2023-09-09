data "google_client_config" "current" {}

data "google_compute_zones" "available" {
  project = data.google_client_config.current.project
  region  = try(coalesce(var.region), data.google_client_config.current.region)
  status  = "UP"
}

locals {
  description                     = coalesce(var.description, "GKE of name ${var.name}")
  enable_vertical_pod_autoscaling = !var.horizontal_pod_autoscaling ? var.enable_vertical_pod_autoscaling : false
  master_authorized_networks      = distinct(concat(var.master_authorized_networks, var.private ? [
    {
      cidr_block   = var.subnetwork_cidr
      display_name = "CLUSTER-VPC"
    }
  ] : []))
  node_pools = [
  for node_pool in var.node_pools : merge(node_pool, {
    name = "${var.name}-${node_pool["name"]}"
  })
  ]
  region      = var.regional ? try(coalesce(var.region), data.google_client_config.current.region) : var.region
  zones       = !var.regional && length(var.zones) == 0 ? data.google_compute_zones.available.names : var.zones
  public_gke  = !var.private
  private_gke = var.private
  gke_name    = coalesce(
    (local.public_gke ? module.gke[0].name : null),
    (local.private_gke ? module.private_gke[0].name : null),
  )
  gke_location = coalesce(
    (local.public_gke ? module.gke[0].location : null),
    (local.private_gke ? module.private_gke[0].location : null),
  )
}

# Public GKE with beta functionalities
module "gke" {
  count                                 = local.public_gke ? 1 : 0
  source                                = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  version                               = "27.0.0"
  description                           = local.description
  # Required
  ip_range_pods                         = var.ip_range_pods
  ip_range_services                     = var.ip_range_services
  name                                  = var.name
  network                               = var.network
  project_id                            = data.google_client_config.current.project
  subnetwork                            = var.subnetwork
  # Optional
  cloudrun                              = var.cloudrun
  cloudrun_load_balancer_type           = var.cloudrun_load_balancer_type
  cluster_autoscaling                   = var.cluster_autoscaling
  cluster_resource_labels               = var.cluster_resource_labels
  cluster_telemetry_type                = var.cluster_telemetry_type
  create_service_account                = var.create_service_account
  config_connector                      = var.config_connector
  database_encryption                   = var.database_encryption
  default_max_pods_per_node             = var.default_max_pods_per_node
  enable_confidential_nodes             = var.enable_confidential_nodes
  enable_cost_allocation                = var.enable_cost_allocation
  enable_identity_service               = var.enable_identity_service
  enable_intranode_visibility           = var.enable_intranode_visibility
  enable_l4_ilb_subsetting              = var.enable_l4_ilb_subsetting
  enable_pod_security_policy            = var.enable_pod_security_policy
  enable_resource_consumption_export    = var.enable_resource_consumption_export
  enable_shielded_nodes                 = var.enable_shielded_nodes
  enable_tpu                            = var.enable_tpu
  enable_vertical_pod_autoscaling       = local.enable_vertical_pod_autoscaling
  filestore_csi_driver                  = var.filestore_csi_driver
  gce_pd_csi_driver                     = var.gce_pd_csi_driver
  gke_backup_agent_config               = var.gke_backup_agent_config
  grant_registry_access                 = var.grant_registry_access
  horizontal_pod_autoscaling            = var.horizontal_pod_autoscaling
  initial_node_count                    = var.initial_node_count
  istio                                 = var.istio
  istio_auth                            = var.istio_auth
  kalm_config                           = var.kalm_config
  kubernetes_version                    = var.kubernetes_version
  logging_enabled_components            = var.logging_enabled_components
  monitoring_enabled_components         = var.monitoring_enabled_components
  network_policy                        = var.network_policy
  network_policy_provider               = var.network_policy_provider
  node_metadata                         = var.node_metadata
  node_pools                            = local.node_pools
  node_pools_labels                     = var.node_pools_labels
  node_pools_resource_labels            = var.node_pools_resource_labels
  node_pools_tags                       = var.node_pools_tags
  node_pools_taints                     = var.node_pools_taints
  region                                = local.region
  regional                              = var.regional
  remove_default_node_pool              = var.remove_default_node_pool
  sandbox_enabled                       = var.sandbox_enabled
  service_account                       = var.service_account
  service_account_name                  = var.service_account_name
  windows_node_pools                    = var.windows_node_pools
  workload_config_audit_mode            = var.workload_config_audit_mode
  workload_vulnerability_mode           = var.workload_vulnerability_mode
  zones                                 = local.zones
  # Optional and not used yet
  add_cluster_firewall_rules            = var.add_cluster_firewall_rules
  add_master_webhook_firewall_rules     = var.add_master_webhook_firewall_rules
  add_shadow_firewall_rules             = var.add_shadow_firewall_rules
  authenticator_security_group          = var.authenticator_security_group
  cluster_dns_domain                    = var.cluster_dns_domain
  cluster_dns_provider                  = var.cluster_dns_provider
  cluster_dns_scope                     = var.cluster_dns_scope
  cluster_ipv4_cidr                     = var.cluster_ipv4_cidr
  configure_ip_masq                     = var.configure_ip_masq
  datapath_provider                     = var.datapath_provider
  disable_default_snat                  = var.disable_default_snat
  disable_legacy_metadata_endpoints     = var.disable_legacy_metadata_endpoints
  dns_cache                             = var.dns_cache
  enable_binary_authorization           = var.enable_binary_authorization
  enable_kubernetes_alpha               = var.enable_kubernetes_alpha
  enable_network_egress_export          = var.enable_network_egress_export
  firewall_inbound_ports                = var.firewall_inbound_ports
  firewall_priority                     = var.firewall_priority
  gateway_api_channel                   = var.gateway_api_channel
  http_load_balancing                   = var.http_load_balancing
  identity_namespace                    = var.identity_namespace
  ip_masq_link_local                    = var.ip_masq_link_local
  ip_masq_resync_interval               = var.ip_masq_resync_interval
  issue_client_certificate              = var.issue_client_certificate
  logging_service                       = var.logging_service
  maintenance_end_time                  = var.maintenance_end_time
  maintenance_exclusions                = var.maintenance_exclusions
  maintenance_recurrence                = var.maintenance_recurrence
  maintenance_start_time                = var.maintenance_start_time
  master_authorized_networks            = var.master_authorized_networks
  monitoring_enable_managed_prometheus  = var.monitoring_enable_managed_prometheus
  monitoring_service                    = var.monitoring_service
  network_project_id                    = var.network_project_id
  node_pools_linux_node_configs_sysctls = var.node_pools_linux_node_configs_sysctls
  node_pools_metadata                   = var.node_pools_metadata
  node_pools_oauth_scopes               = var.node_pools_oauth_scopes
  non_masquerade_cidrs                  = var.non_masquerade_cidrs
  notification_config_topic             = var.notification_config_topic
  registry_project_ids                  = var.registry_project_ids
  release_channel                       = var.release_channel
  resource_usage_export_dataset_id      = var.resource_usage_export_dataset_id
  service_external_ips                  = var.service_external_ips
  shadow_firewall_rules_log_config      = var.shadow_firewall_rules_log_config
  shadow_firewall_rules_priority        = var.shadow_firewall_rules_priority
  stub_domains                          = var.stub_domains
  timeouts                              = var.timeouts
  upstream_nameservers                  = var.upstream_nameservers
}

# Private GKE with beta functionalities
module "private_gke" {
  count                                 = local.private_gke ? 1 : 0
  source                                = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                               = "27.0.0"
  description                           = local.description
  # Required
  ip_range_pods                         = var.ip_range_pods
  ip_range_services                     = var.ip_range_services
  name                                  = var.name
  network                               = var.network
  project_id                            = data.google_client_config.current.project
  subnetwork                            = var.subnetwork
  # Optional
  cloudrun                              = var.cloudrun
  cloudrun_load_balancer_type           = var.cloudrun_load_balancer_type
  cluster_autoscaling                   = var.cluster_autoscaling
  cluster_resource_labels               = var.cluster_resource_labels
  cluster_telemetry_type                = var.cluster_telemetry_type
  create_service_account                = var.create_service_account
  config_connector                      = var.config_connector
  database_encryption                   = var.database_encryption
  default_max_pods_per_node             = var.default_max_pods_per_node
  enable_confidential_nodes             = var.enable_confidential_nodes
  deploy_using_private_endpoint         = var.deploy_using_private_endpoint
  enable_cost_allocation                = var.enable_cost_allocation
  enable_identity_service               = var.enable_identity_service
  enable_intranode_visibility           = var.enable_intranode_visibility
  enable_l4_ilb_subsetting              = var.enable_l4_ilb_subsetting
  enable_pod_security_policy            = var.enable_pod_security_policy
  # Whether the master's internal IP address is used as the cluster endpoint
  enable_private_endpoint               = var.private
  # Whether nodes have internal IP addresses only
  enable_private_nodes                  = var.private
  enable_resource_consumption_export    = var.enable_resource_consumption_export
  enable_shielded_nodes                 = var.enable_shielded_nodes
  enable_tpu                            = var.enable_tpu
  enable_vertical_pod_autoscaling       = local.enable_vertical_pod_autoscaling
  filestore_csi_driver                  = var.filestore_csi_driver
  gce_pd_csi_driver                     = var.gce_pd_csi_driver
  gke_backup_agent_config               = var.gke_backup_agent_config
  grant_registry_access                 = var.grant_registry_access
  horizontal_pod_autoscaling            = var.horizontal_pod_autoscaling
  initial_node_count                    = var.initial_node_count
  istio                                 = var.istio
  istio_auth                            = var.istio_auth
  kalm_config                           = var.kalm_config
  logging_enabled_components            = var.logging_enabled_components
  master_ipv4_cidr_block                = var.master_ipv4_cidr_block
  master_global_access_enabled          = var.master_global_access_enabled
  monitoring_enabled_components         = var.monitoring_enabled_components
  network_policy                        = var.network_policy
  network_policy_provider               = var.network_policy_provider
  node_metadata                         = var.node_metadata
  node_pools                            = local.node_pools
  node_pools_labels                     = var.node_pools_labels
  node_pools_resource_labels            = var.node_pools_resource_labels
  node_pools_tags                       = var.node_pools_tags
  node_pools_taints                     = var.node_pools_taints
  region                                = local.region
  regional                              = var.regional
  remove_default_node_pool              = var.remove_default_node_pool
  sandbox_enabled                       = var.sandbox_enabled
  service_account                       = var.service_account
  service_account_name                  = var.service_account_name
  windows_node_pools                    = var.windows_node_pools
  workload_config_audit_mode            = var.workload_config_audit_mode
  workload_vulnerability_mode           = var.workload_vulnerability_mode
  zones                                 = local.zones
  # Optional and not used yet
  add_cluster_firewall_rules            = var.add_cluster_firewall_rules
  add_master_webhook_firewall_rules     = var.add_master_webhook_firewall_rules
  add_shadow_firewall_rules             = var.add_shadow_firewall_rules
  authenticator_security_group          = var.authenticator_security_group
  cluster_dns_domain                    = var.cluster_dns_domain
  cluster_dns_provider                  = var.cluster_dns_provider
  cluster_dns_scope                     = var.cluster_dns_scope
  cluster_ipv4_cidr                     = var.cluster_ipv4_cidr
  configure_ip_masq                     = var.configure_ip_masq
  datapath_provider                     = var.datapath_provider
  disable_default_snat                  = var.disable_default_snat
  disable_legacy_metadata_endpoints     = var.disable_legacy_metadata_endpoints
  dns_cache                             = var.dns_cache
  enable_binary_authorization           = var.enable_binary_authorization
  enable_kubernetes_alpha               = var.enable_kubernetes_alpha
  enable_network_egress_export          = var.enable_network_egress_export
  firewall_inbound_ports                = var.firewall_inbound_ports
  firewall_priority                     = var.firewall_priority
  gateway_api_channel                   = var.gateway_api_channel
  http_load_balancing                   = var.http_load_balancing
  identity_namespace                    = var.identity_namespace
  ip_masq_link_local                    = var.ip_masq_link_local
  ip_masq_resync_interval               = var.ip_masq_resync_interval
  issue_client_certificate              = var.issue_client_certificate
  logging_service                       = var.logging_service
  maintenance_end_time                  = var.maintenance_end_time
  maintenance_exclusions                = var.maintenance_exclusions
  maintenance_recurrence                = var.maintenance_recurrence
  maintenance_start_time                = var.maintenance_start_time
  master_authorized_networks            = local.master_authorized_networks
  monitoring_enable_managed_prometheus  = var.monitoring_enable_managed_prometheus
  monitoring_service                    = var.monitoring_service
  network_project_id                    = var.network_project_id
  node_pools_linux_node_configs_sysctls = var.node_pools_linux_node_configs_sysctls
  node_pools_metadata                   = var.node_pools_metadata
  node_pools_oauth_scopes               = var.node_pools_oauth_scopes
  non_masquerade_cidrs                  = var.non_masquerade_cidrs
  notification_config_topic             = var.notification_config_topic
  registry_project_ids                  = var.registry_project_ids
  release_channel                       = var.release_channel
  resource_usage_export_dataset_id      = var.resource_usage_export_dataset_id
  service_external_ips                  = var.service_external_ips
  shadow_firewall_rules_log_config      = var.shadow_firewall_rules_log_config
  shadow_firewall_rules_priority        = var.shadow_firewall_rules_priority
  stub_domains                          = var.stub_domains
  timeouts                              = var.timeouts
  upstream_nameservers                  = var.upstream_nameservers
}

resource "null_resource" "update_kubeconfig" {
  count = can(coalesce(var.kubeconfig_path)) ? 1 : 0
  provisioner "local-exec" {
    command     = "gcloud container clusters get-credentials ${local.gke_name} --location=${local.gke_location}"
    environment = {
      KUBECONFIG = abspath(var.kubeconfig_path)
    }
  }
  depends_on = [
    module.gke,
    module.private_gke
  ]
}
