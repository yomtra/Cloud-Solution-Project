
output "rds_read_replica_endpoint" {
  value = aws_db_instance.read_replica.endpoint
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "rds_port" {
  value = 3306
}

output "rds_username" {
  value = var.username
}

output "rds_endpoint" {
  value = aws_db_instance.primary.endpoint
}

output "db_name" {
  value = aws_db_instance.primary.db_name
}

output "db_instance_id" {
  value = aws_db_instance.primary.id
}
