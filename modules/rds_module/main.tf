locals {
  vpc_id              = var.vpc_id     # Replace with your VPC ID
  region              = "us-west-1"
}
 
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.name}-rds-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = var.tags
}
 
resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "RDS DB access"
  vpc_id      = local.vpc_id
 
  ingress {
    description = "Allow MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.32.0.0/24", "10.48.0.0/24"] # App tier subnets
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
  backup_retention_period = 7
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  availability_zone       = "us-west-1a"
  tags                    = var.tags
}
 
resource "aws_db_instance" "read_replica" {
  identifier              = "${var.name}-read-replica" # need all vars.
  instance_class          = var.instance_class
  replicate_source_db     = aws_db_instance.primary.arn
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  availability_zone       = "us-west-1c"
  tags                    = var.tags
}