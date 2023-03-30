locals {
  node_selector_keys         = keys(var.mongodb.node_selector)
  node_selector_values       = values(var.mongodb.node_selector)
  replicas                   = toset([for s in range(var.mongodb.replicas_number) : tostring(s)])
  mongodb_port               = kubernetes_service.mongodb.0.spec.0.type == "NodePort" ? kubernetes_service.mongodb.0.spec.0.port.0.node_port : kubernetes_service.mongodb.0.spec.0.port.0.port
  mongodb_dns                = "${kubernetes_service.mongodb.0.metadata.0.name}.${kubernetes_service.mongodb.0.metadata.0.namespace}"
  mongodb_url                = "mongodb://${local.mongodb_dns}:${local.mongodb_port}"
  mongodb_number_of_replicas = var.mongodb.replicas_number
}