# General setup
environment       = "dev"
project           = "go-green"
 
# Network
vpc_cidr          = "10.0.0.0/16"
web_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
app_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
db_subnet_cidrs   = ["10.0.5.0/24", "10.0.6.0/24"]
enable_nat_gateway = true
 
# RDS
name              = "cloud-db"
username          = "admin"
password          = "MyStrongPass123!"
instance_class    = "db.t3.micro"
engine            = "mysql"
engine_version    = "8.0"
allocated_storage = 20
 
 
# Tags 
tags = {
  Name        = "go-green"
  Environment = "dev"
}

#Scaling group
ami = "ami-061ad72bc140532fd"

#S3