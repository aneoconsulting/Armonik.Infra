terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.7.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.1.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "~> 0.0.7"
    }
  }
}