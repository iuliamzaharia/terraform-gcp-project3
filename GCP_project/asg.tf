resource "google_compute_autoscaler" "foobar" {
  name   = "my-autoscaler"
  zone   = "us-central1-f"
  target = google_compute_instance_group_manager.foobar.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60
  }
}

resource "google_compute_instance_template" "foobar" {
  name         = "my-instance-template"
  machine_type = "e2-medium"

  disk {
    source_image = data.google_compute_image.debian_9.id
  }
}

resource "google_compute_target_pool" "foobar" {
  name = "my-target-pool"
}

resource "google_compute_instance_group_manager" "foobar" {
  name = "my-igm"
  zone = "us-central1-f"

  version {
    instance_template = google_compute_instance_template.foobar.id
    name              = "primary"
  }

  target_pools       = [google_compute_target_pool.foobar.id]
  base_instance_name = "foobar"
}

data "google_compute_image" "debian_9" {
  family  = "debian-11"
  project = "debian-cloud"
}