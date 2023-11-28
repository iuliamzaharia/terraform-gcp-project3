 Team 3 
1. Olena Furmaniuk
2. Andriy Mykhaylushko
3. Ines Arust
4. Iulia Zaharia
5. Maftuna Tojiboeva
6. Xavier Martinez
# _GCP_
## _Step1_
_Build  terraform module  for a Three-Tier application on GCP:_
- _Global VPC_
> Configure  subnets  automatically. 
> This module  should  be able to create  project.  

#### Usage
```
module "project" {
  source  = "iuliamzaharia/project/gcp"
  version = "0.0.3"
}

```
- _Variables_
```
variable "vpc_name" {
  description = "The name of the VPC"
  default     = "vpc3"
}
```
- _Firewall_
#### Usage
```
resource "google_compute_firewall" "vpc_firewall" {
  name    = "vpc-firewall"
  network = google_compute_network.vpc3.name  

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
     ports    = ["22", "80", "3306", "443"]
  }

  source_tags = ["web"]
}
```

## _Step2_
- _ASG_
> On  top  of VPC  from  previous  step, creates Auto  Scaling  Group. 
> Auto Scaling  Group, can  use  minimum  1 instance. 
> This  Auto  Scaling  Group  will create  its  Load  Balancer. 
## _Step3_
 - _RDS_
> Create  CloudSQL  to use with wordpress  autoscaling group.







