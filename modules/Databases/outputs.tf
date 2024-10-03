output "timescale_server_public_ip" {
  value = module.timescale_database.server_public_ip
}


output "postgresql_server_public_ip" {
  value = module.postgresql_database.server_public_ip
}


