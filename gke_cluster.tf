resource "google_container_cluster" "arcdemo" {
  name     = var.gke_cluster_name
  location = var.gcp_region
  # zone   = var.gcp_zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  depends_on = [azurerm_resource_group.arc-data-demo]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "arcdemo-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.arcdemo.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-8"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}