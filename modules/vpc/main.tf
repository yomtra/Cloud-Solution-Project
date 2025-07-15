
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # e.g. "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.environment}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs_web = slice(data.aws_availability_zones.available.names, 0, length(var.web_subnet_cidrs))

}

resource "aws_subnet" "web" {
  count                   = length(var.web_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.web_subnet_cidrs[count.index]
  availability_zone       = local.azs_web[count.index]
  map_public_ip_on_launch = true #any EC2 launched in this subnet will automatically get a public IP

  tags = {
    Name = "web-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "IGW"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "route_table"
  }
}

resource "aws_route_table_association" "web" {
  count          = length(var.web_subnet_cidrs)
  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.rt.id
}



resource "aws_subnet" "app" {
  count                   = length(var.app_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.app_subnet_cidrs[count.index]
  availability_zone       = local.azs_app[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "app-subnet-${count.index + 1}"
  }
}

locals {
  azs_app = slice(data.aws_availability_zones.available.names, 0, length(var.app_subnet_cidrs))
}
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web[0].id # Use the first web subnet for NAT

  tags = {
    Name = "${var.project}-${var.environment}-nat-gateway"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.environment}-private-rt"
  }
}
resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "app" {
  count          = length(var.app_subnet_cidrs)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_subnet" "db" {
  count                   = length(var.db_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.db_subnet_cidrs[count.index]
  availability_zone       = local.azs_db[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "db-subnet-${count.index + 1}"
  }


}
locals {
  azs_db = slice(data.aws_availability_zones.available.names, 0, length(var.db_subnet_cidrs))
}
resource "aws_db_subnet_group" "default" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id

  tags = {
    Name = "${var.project}-${var.environment}-db-subnet-group"
  }
}

resource "aws_network_acl" "web" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.web[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project}-${var.environment}-web-nacl"
  }
}
resource "aws_network_acl" "app" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.app[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24" # From web subnet
    from_port  = 8080
    to_port    = 8080
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.5.0/24" # To DB subnet
    from_port  = 3306
    to_port    = 3306
  }

  tags = {
    Name = "${var.project}-${var.environment}-app-nacl"
  }
}

resource "aws_network_acl" "db" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.db[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.3.0/24" # App subnet
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project}-${var.environment}-db-nacl"
  }
}





