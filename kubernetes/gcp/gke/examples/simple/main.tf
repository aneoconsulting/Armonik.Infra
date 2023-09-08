module "vpc" {
  source = "../../../../../networking/gcp/vpc"
  name   = "gke-simple-test"
  gke_subnet = {
    name                = "gke-simple-test"
    nodes_cidr_block    = "10.43.0.0/16",
    pods_cidr_block     = "172.16.0.0/16"
    services_cidr_block = "172.17.17.0/24"
    region              = var.region
  }
}

module "gke" {
  source            = "../../../gke"
  name              = "gke-simple-test"
  network           = module.vpc.name
  ip_range_pods     = module.vpc.gke_subnet_pods_range_name
  ip_range_services = module.vpc.gke_subnet_svc_range_name
  subnetwork        = module.vpc.gke_subnet_name
  kubeconfig_path   = abspath("${path.root}/generated/kubeconfig")
  private = false
}
