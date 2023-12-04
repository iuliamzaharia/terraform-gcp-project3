terraform {
  backend "gcs" {
    bucket = "terraform-bucket-project-aug230"
    prefix = "terraform/state"
  }
}
