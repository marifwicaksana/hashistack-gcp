variable "gcp_project" {
  description = "GCP Project"
}
variable "sshuser" {
  description = "Username for SSH"
  default     = "packer"
}
variable "gcp_zone" {
  description = "GCP Zone"
  default     = "europe-southwest1-a"
}
variable "image" {
  default = "consul-nomad"
}
variable "machine_type" {
  default = "e2-standard-2"
}
variable "consul_version" {
  default = "1.21.2+ent"
}
variable "nomad_version" {
  default = "1.10.3+ent"
}
variable "vault_version" {
  default = "1.14.1"
}
variable "image_family" {
  default = "hashistack"
}
variable "source_image_family" {
  default = "debian-12"
}
variable "hcp_bucket_name" {
  description = "HCP Packer's bucket name"
  default     = "consul-nomad"
}
variable "owner" {
  description = "Owner name"
  default     = "pablogdiaz"
}

locals {
  consul_version      = var.consul_version
  nomad_version       = var.nomad_version
  consul_version_safe = regex_replace(var.consul_version, "\\.+|\\+", "-")
  nomad_version_safe  = regex_replace(var.nomad_version, "\\.+|\\+", "-")
}

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = ">= 1.0.0"
    }
  }
}

source "googlecompute" "consul_nomad" {
  project_id          = var.gcp_project
  source_image_family = var.source_image_family
  image_name          = "${var.image}-${local.consul_version_safe}-${local.nomad_version_safe}"
  image_family        = var.image_family
  machine_type        = var.machine_type
  # disk_size = 50
  ssh_username = var.sshuser
  zone         = var.gcp_zone
}

build {
  hcp_packer_registry {
    bucket_name = var.hcp_bucket_name
    description = <<EOT
Image for Consul, Nomad and Vault
   EOT
    bucket_labels = {
      "hashicorp" = "Vault,Consul,Nomad",
      "owner"     = var.owner,
      "platform"  = "hashicorp",
    }
  }
  sources = ["sources.googlecompute.consul_nomad"]
  provisioner "shell" {
    scripts = ["../consul_prep.sh", "../nomad_prep.sh"]
    # execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo '{{ .Path }}'"
    environment_vars = [
      "CONSUL_VERSION=${var.consul_version}",
      "NOMAD_VERSION=${var.nomad_version}",
      "VAULT_VERSION=${var.vault_version}"
    ]
  }
}