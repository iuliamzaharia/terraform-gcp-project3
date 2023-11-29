# Output the created VPC
output "vpc_self_link" {
  value = google_compute_network.vpc3.self_link
}