# Output the created VPC
output "vpc_self_link" {
  value = google_compute_network.vpc3.self_link
}

#output "sql_connection_name" {
# value     = google_sql_database_instance.wordpress-db3.connection_name
# depends_on = [google_sql_database_instance.wordpress-db3]
#}

#output "sql_ip_address" {
#value     = google_sql_database_instance.wordpress-db3.ip_address[0]
#depends_on = [google_sql_database_instance.wordpress-db3]
#}
