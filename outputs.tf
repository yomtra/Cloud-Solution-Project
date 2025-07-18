output "vpc_id" {
  value = module.vpc.vpc_id
}

output "web_subnet_ids" {
  value = module.vpc.web_subnet_ids
}

output "app_subnet_ids" {
  value = module.vpc.app_subnet_ids
}

output "db_subnet_ids" {
  value = module.vpc.db_subnet_ids
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "web_nacl_id" {
  value = module.vpc.web_nacl_id
}

output "app_nacl_id" {
  value = module.vpc.app_nacl_id
}

output "db_nacl_id" {
  value = module.vpc.db_nacl_id
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_read_replica_endpoint" {
  value = module.rds.rds_read_replica_endpoint
}

output "rds_username" {
  value = module.rds.rds_username
}

output "rds_port" {
  value = module.rds.rds_port
}
