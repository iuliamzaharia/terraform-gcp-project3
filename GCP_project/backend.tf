terraform {
  backend "gcs" {
    bucket = "terraform-bucket-project-aug23"
    prefix = "terraform/state"
  }
}
