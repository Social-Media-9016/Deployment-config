# Google Cloud Dev environment for ECE9016

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "google" {
  project = var.project_id
  zone = var.zone
}

variable "project_id" {
  description = "project ID."
  type        = string
  default     = "ece9016-social-network"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "northamerica-northeast1-a"
}

variable "team_members" {
  description = "List of email addresses for the team members who will have Owner access."
  type        = list(string)
  default     = [
    "user:yzha3296@uwo.ca",
    "user:yzha3744@uwo.ca",
    "user:jche743@uwo.ca",
    "user:xlu469@uwo.ca"
  ]
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "gke-9016-dev"
}

resource "google_container_cluster" "dev_cluster" {
  name               = var.cluster_name
  location           = var.zone

  remove_default_node_pool = true

  node_pool {
    name       = "default-pool"
    node_count = 1

    node_config {
      machine_type = "e2-medium"
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }
}

resource "google_project_iam_binding" "project_members" {
  project = var.project_id
  role    = "roles/editor"
  members = var.team_members
}

output "project_id" {
  description = "Project ID"
  value       = var.project_id
}

output "cluster_name" {
  description = "Cluster."
  value       = google_container_cluster.dev_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint to connect."
  value       = google_container_cluster.dev_cluster.endpoint
}

output "project_owners" {
  description = "members."
  value       = var.team_members
}