resource "google_compute_network" "vpc3" {
  name                    = var.vpc_name
  auto_create_subnetworks = "true"
  routing_mode            = "GLOBAL"
}

resource "google_compute_firewall" "firewall" {
  name    = "firewall"
  network = google_compute_network.vpc3.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3306", "443"]
  }

  source_ranges = ["0.0.0.0/0"] 
}