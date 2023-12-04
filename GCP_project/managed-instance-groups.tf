resource "google_compute_autoscaler" "foobar" {
  name   = "my-autoscaler"
  zone   = "us-central1-f"
  target = google_compute_instance_group_manager.my-igm.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60
  }
}


#creating a machine template so the autoscaling knows what type of machine to work with.
resource "google_compute_instance_template" "compute-engine" {
  depends_on = [
    google_sql_database_instance.wordpress-db3,
  ]
  name                    = "my-instance-template"
  machine_type            = "e2-medium"
  can_ip_forward          = false
  project                 = "yevaysmksiiywuxn"
  metadata_startup_script = file("${path.module}/installation.sh")


  disk {
    source_image = data.google_compute_image.centos_7.self_link
  }

  network_interface {
    network = google_compute_network.vpc3.id
    access_config {
      // Include this section to give the VM an external ip address
    }

  }
}
#creating a target pool

resource "google_compute_target_pool" "foobar" {
  name    = "my-target-pool"
  project = "yevaysmksiiywuxn"
  region  = "us-central1"
}

#creating a group manager for the instances.
resource "google_compute_instance_group_manager" "my-igm" {
  name    = "instance-group-manager"
  zone    = "us-central1-f"
  project = "yevaysmksiiywuxn"
  version {
    instance_template = google_compute_instance_template.compute-engine.self_link
    name              = "primary"
  }
  target_pools       = [google_compute_target_pool.foobar.id]
  base_instance_name = "foobar"
}

#indicating the image for the instance.

data "google_compute_image" "centos_7" {
  family  = "centos-7"
  project = "centos-cloud"
}