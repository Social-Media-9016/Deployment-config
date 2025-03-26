
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
  zone    = var.zone
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "ece9016-social-network"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "northamerica-northeast1-a"
}

variable "team_members" {
  description = "List of email addresses with Editor access."
  type        = list(string)
  default = [
    "user:yzha3296@uwo.ca",
    "user:jche743@uwo.ca"
  ]
}

variable "production_cluster_name" {
  description = "Name of the production GKE cluster"
  type        = string
  default     = "gke-9016-prod"
}

resource "google_container_cluster" "prod_cluster" {
  name                     = var.production_cluster_name
  location                 = var.zone
  remove_default_node_pool = true

  initial_node_count       = 1
}

resource "google_container_node_pool" "web_pool" {
  name       = "web-pool"
  location   = var.zone
  cluster    = google_container_cluster.prod_cluster.name
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      environment = "production"
      role        = "webserver"
    }
  }
}
resource "google_container_node_pool" "db_pool" {
  name       = "db-pool"
  location   = var.zone
  cluster    = google_container_cluster.prod_cluster.name
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      environment = "production"
      role        = "database"
    }
  }
}
resource "google_project_iam_binding" "project_members" {
  project = var.project_id
  role    = "roles/editor"
  members = var.team_members
}

output "production_cluster_name" {
  description = "Production cluster name."
  value       = google_container_cluster.prod_cluster.name
}

output "production_cluster_endpoint" {
  description = "Production cluster endpoint."
  value       = google_container_cluster.prod_cluster.endpoint
}
