# ArmoniK
module "armonik" {
  source               = "./modules/armonik-components"
  namespace            = var.namespace
  logging_level        = var.logging_level
  control_plane        = var.control_plane
  compute_plane        = var.compute_plane
  storage              = local.storage
  storage_adapters     = local.storage_adapters
  storage_endpoint_url = var.storage_endpoint_url
  seq_endpoint_url     = local.seq_endpoint_url
  grafana_endpoint_url = local.grafana_endpoint_url
}