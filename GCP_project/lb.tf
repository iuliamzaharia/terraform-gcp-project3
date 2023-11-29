# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "lb-forwarding-rule"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id

}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name     = "lb-target-http-proxy"
  provider = google-beta
  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "lb-url-map"
  provider        = google-beta
  default_service = google_compute_backend_service.default.id
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "default" {
 
  name                  = "lb-backend-service"
  provider              = google-beta
  protocol              = "HTTP"
  port_name             = "http-port"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  enable_cdn            = true
  health_checks         = [google_compute_health_check.default.id]

  backend {
    group           = google_compute_instance_group_manager.foobar.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# instance template
resource "google_compute_instance_template" "default" {
  name         = "lb-template"
  provider     = google-beta
  machine_type = "e2-small"

  network_interface {
    network = google_compute_network.vpc3.id
  }

  provisioner "file" {
    source      = "path/to/installation.sh" # Path to your local WordPress installation script
    destination = "/tmp/installation.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/installation.sh",
      "/tmp/installation.sh",
    ]
  }
  
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}

# health check
resource "google_compute_health_check" "default" {
  name     = "lb-hc"
  provider = google-beta
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# allow access from health check ranges
resource "google_compute_firewall" "default" {
  name          = "lb-allow-hc"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.vpc3.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }

}