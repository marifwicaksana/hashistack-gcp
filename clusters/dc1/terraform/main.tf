terraform { 
  cloud { 
    organization = "marifw_dev"
    workspaces { 
      name = "DB-cluster-1" 
      project = "hashistack"
    } 
  } 
}

terraform {
  required_version = ">= 1.0.0"
}

resource "random_id" "server" {
  byte_length = 1
}

# Collect client config for GCP
data "google_client_config" "current" {
}

data "google_service_account" "owner_project" {
  account_id = var.gcp_sa
}

## ----- Network capabilities ------
# VPC creation
resource "google_compute_network" "network" {
  name = "${var.cluster_name}-network"
}