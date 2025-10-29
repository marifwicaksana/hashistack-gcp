variable "gcp_region" {
  description = "Google Cloud region"
}

variable "gcp_zones" {
  description = "Zones to spread the clients. This is a list of zones"
  type = list(string)
  default = ["us-central1-a"]
  # Let's do a validation to check that the zones are within the region
  validation {
    condition     = alltrue([for zone in var.gcp_zones : contains(regexall("[a-z]+-[a-z]+[0-1]-[a-z]",zone),zone)])
    error_message = "The GCP zones ${join(",",var.gcp_zones)} needs to be a valid one."
  }
}

variable "gcp_project" {
  description = "Cloud project"
}

variable "gcp_sa" {
  description = "GCP Service Account to use for scopes"
}

variable "cluster_name" {
  description = "Name of the cluster"
}