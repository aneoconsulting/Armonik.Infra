output "name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc
}

output "gateway_ipv4" {
  description = "The gateway address for default routing out of the network. This value is selected by GCP"
  value       = google_compute_network.vpc.gateway_ipv4
}

output "self_link" {
  description = "The URI of the created resource"
  value       = google_compute_network.vpc.self_link
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = { for subnet, _ in local.private_subnets : subnet => google_compute_subnetwork.subnets[subnet].id }
}

output "private_subnet_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
  value       = { for subnet, _ in local.private_subnets : subnet => google_compute_subnetwork.subnets[subnet].ip_cidr_range }
}

output "private_subnet_self_links" {
  description = "List of private subnet self links"
  value       = { for subnet, _ in local.private_subnets : subnet => google_compute_subnetwork.subnets[subnet].self_link }
}

output "private_subnet_regions" {
  description = "List of private subnet regions"
  value       = { for subnet, _ in local.private_subnets : subnet => google_compute_subnetwork.subnets[subnet].region }
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = { for subnet, _ in local.public_subnets : subnet => google_compute_subnetwork.subnets[subnet].id }
}

output "public_subnet_cidr_blocks" {
  description = "List of public subnet CIDR blocks"
  value       = { for subnet, _ in local.public_subnets : subnet => google_compute_subnetwork.subnets[subnet].ip_cidr_range }
}

output "public_subnet_self_links" {
  description = "List of public subnet self links"
  value       = { for subnet, _ in local.public_subnets : subnet => google_compute_subnetwork.subnets[subnet].self_link }
}

output "public_subnet_regions" {
  description = "List of public subnet regions"
  value       = { for subnet, _ in local.public_subnets : subnet => google_compute_subnetwork.subnets[subnet].region }
}

output "gke_subnet_ids" {
  description = "Map of GKE subnet IDs"
  value       = { for key, value in google_compute_subnetwork.gke_subnets : key => value.id }
}

output "gke_subnet_cidr_blocks" {
  description = "Map of GKE subnet CIDR blocks"
  value       = { for key, value in google_compute_subnetwork.gke_subnets : key => value.ip_cidr_range }
}

output "gke_subnet_self_links" {
  description = "Map of GKE subnet self links"
  value       = { for key, value in google_compute_subnetwork.gke_subnets : key => value.self_link }
}

output "gke_subnet_pod_ranges" {
  description = "Map of range names and IP CIDR ranges of GKE Pod"
  value = {
    for key, value in google_compute_subnetwork.gke_subnets : key => value.secondary_ip_range[0]
  }
}

output "gke_subnet_svc_ranges" {
  description = "Map of range names and IP CIDR ranges of GKE services"
  value = {
    for key, value in google_compute_subnetwork.gke_subnets : key => value.secondary_ip_range[1]
  }
}

