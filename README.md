 Team 3 
1. Olena Furmaniuk
2. Andriy Mykhaylushko
3. Ines Arust
4. Iulia Zaharia
5. Maftuna Tojiboeva
6. Xavier Martinez

Project Manager : Iulia Zaharia
# _GCP_
## _Step1_
_Build  terraform module  for a Three-Tier application on GCP:_
- _Global VPC_
> Configure  subnets  automatically. 
> This module  should  be able to create  project.  

#### Usage
```
module "project3" {
  source  = "iuliamzaharia/project3/gcp"
  version = "0.0.2"
}
```
- _Variables_
#### Usage
```
variable "vpc_name" {
  description = "The name of the VPC"
  default     = "vpc3"
}

variable "db_password" {
  type        = string
  default     = "changeme"
  description = "description"
}

variable "project_name" {
  type        = string
  default     = "yevaysmksiiywuxn"
  description = "enter your project name"
}

```
- _Firewall_
#### Usage
```
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
```

## _Step2_
- _MIG_  (Managed Instance Groups)
> On  top  of VPC  from  previous  step, creates Auto  Scaling  Group. 
> Auto Scaling  Group, can  use  minimum  1 instance. 
> This  Auto  Scaling  Group  will create  its  Load  Balancer. 
#### Usage
```
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
```
- _LB_ (Load Balancer)
#### Usage
```
#module for the load balancer.

module "lb" {
  source       = "GoogleCloudPlatform/lb/google"
  version      = "2.2.0"
  region       = "us-central1"
  name         = "load-balancer"
  service_port = 80
  target_tags  = ["my-target-pool"]
  network      = google_compute_network.vpc3.name
}

```
## _Step3_
 - _Coud SQL_
> Create  CloudSQL  to use with wordpress  autoscaling group.
#### Usage
```
# creates instance
resource "google_sql_database_instance" "wordpress-db3" {
  name                = "wordpress-db3-instance"
  database_version    = "MYSQL_5_7"
  region              = "us-central1"
  root_password       = var.db_password
  deletion_protection = "false"
  project             = var.project_name

  settings {
    tier = "db-f1-micro"
  }
}
# cretes user
resource "google_sql_user" "users" {
  name     = "wordpress-db3-user"
  instance = google_sql_database_instance.wordpress-db3.name
  host     = "%"
  password = "changeme"

}
#creates database
resource "google_sql_database" "wordpress" {
  name     = "wordpress-db3-database"
  instance = google_sql_database_instance.wordpress-db3.name
}
```
_The CloudSQL was created to be used with wordpress autoscaling group. (An sh. file has been created for that)._







