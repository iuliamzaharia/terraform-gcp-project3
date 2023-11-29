# Read Billing Account
data "google_billing_account" "acct" {
  display_name = "My Billing Account"
  open         = true
}


# Create 16 random characters 
resource "random_password" "password" {
  length  = 16
  numeric = false
  special = false
  lower   = true
  upper   = false
}

# Create a project
resource "google_project" "Project3" {
  name            = "Project3"
  project_id      = random_password.password.result
  billing_account = data.google_billing_account.acct.id
}

# set project
resource "null_resource" "set-project" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud config set project ${google_project.Project3.project_id}"
  }
}

resource "null_resource" "enable-apis" {
  depends_on = [
    google_project.Project3,
    null_resource.set-project
  ]
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
        gcloud services enable compute.googleapis.com
        gcloud services enable dns.googleapis.com
        gcloud services enable storage-api.googleapis.com
        gcloud services enable container.googleapis.com
        gcloud services enable file.googleapis.com
    EOT
  }
}