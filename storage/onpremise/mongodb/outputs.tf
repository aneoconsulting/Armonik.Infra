output "host" {
  description = "Hostname or IP address of MongoDB server"
  value       = local.mongodb_dns
}

output "port" {
  description = "Port of MongoDB server"
  value       = 27017
}

output "url" {
  description = "URL of MongoDB server"
  value       = local.mongodb_url

}

output "number_of_replicas" {
  description = "Number of replicas of MongoDB"
  value       = var.mongodb.replicas_number
}

output "user_credentials" {
  description = "User credentials of MongoDB"
  value = {
    secret    = kubernetes_secret.mongodb_user.metadata[0].name
    data_keys = keys(kubernetes_secret.mongodb_user.data)
  }
  sensitive = true
}

output "endpoints" {
  description = "Endpoints of MongoDB"
  value = {
    secret    = kubernetes_secret.mongodb.metadata[0].name
    data_keys = keys(kubernetes_secret.mongodb.data)
  }
  sensitive = true
}
