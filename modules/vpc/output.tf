output "vpc_id" {
  value = aws_vpc.main.id
}

output "web_subnet_ids" {
  value = aws_subnet.web[*].id
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat.id
}
output "web_nacl_id" {
  value = aws_network_acl.web.id
}

output "app_nacl_id" {
  value = aws_network_acl.app.id
}

output "db_nacl_id" {
  value = aws_network_acl.db.id
}

