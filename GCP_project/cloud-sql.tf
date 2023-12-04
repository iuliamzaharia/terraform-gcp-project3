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