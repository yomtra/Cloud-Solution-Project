# Jurabek: Fixed hardcoded values to use variables from main.tf
locals {
  # private_subnet_3_id = "10.64.0.0/24"  # OLD CODE: Hardcoded subnet CIDRs
  # private_subnet_4_id = "10.80.0.0/24"  # OLD CODE: Hardcoded subnet CIDRs  
  # vpc_id              = "10.0.0.0/16"   # OLD CODE: Hardcoded VPC CIDR instead of ID
  region = var.region  # Jurabek: Use region from variables instead of hardcode
}
 
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.name}-rds-subnet-group"
  # subnet_ids = [local.private_subnet_3_id, local.private_subnet_4_id]  # OLD CODE: Used hardcoded locals
  subnet_ids = var.db_subnet_ids  # Jurabek: Use db subnet IDs passed from main.tf
  tags       = var.tags
}
 
resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "RDS DB access"
  # vpc_id      = local.vpc_id  # OLD CODE: Used hardcoded local VPC CIDR
  vpc_id      = var.vpc_id     # Jurabek: Use VPC ID passed from main.tf
 
  ingress {
    description = "Allow MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    # cidr_blocks = ["10.32.0.0/24", "10.48.0.0/24"] # OLD CODE: Hardcoded app tier subnets
    cidr_blocks = var.app_subnet_cidrs # Jurabek: Use dynamic app subnet CIDRs from variables
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = var.tags
}
 
resource "aws_db_instance" "primary" {
  identifier              = "${var.name}-primary"  # Need all vars.
  instance_class          = var.instance_class
  engine                  = var.engine
  engine_version          = var.engine_version
  allocated_storage       = var.allocated_storage
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  # Jurabek: Added backup configuration required for read replica creation
  backup_retention_period = 7    # Enable automated backups (1-35 days)
  backup_window          = "03:00-04:00"  # UTC backup window
  apply_immediately      = true  # Jurabek: Apply backup changes immediately to existing instance
  # availability_zone       = "us-west-1a"  # Jurabek: Removed hardcoded AZ, let AWS choose from subnet group
  tags                    = var.tags
}
 
# Jurabek: Temporarily commented out read replica until primary DB has backups enabled
# Will be re-enabled after primary database backup is configured and active
# resource "aws_db_instance" "read_replica" {
#   identifier              = "${var.name}-read-replica" # need all vars.
#   instance_class          = var.instance_class
#   replicate_source_db     = aws_db_instance.primary.arn  # Jurabek: Use ARN instead of ID when using custom subnet group
#   db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
#   vpc_security_group_ids  = [aws_security_group.rds_sg.id]
#   publicly_accessible     = false
#   # availability_zone       = "us-west-1b"  # Jurabek: us-west-1 only has AZs a and c, removed hardcoded AZ
#   tags                    = var.tags
# }