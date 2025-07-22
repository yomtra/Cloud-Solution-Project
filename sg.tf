resource "aws_security_group" "web_tier_sg" {
  name        = "web_tier_sg"
  description = "Security group for the web tier"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}


#Allows all internet traffic in for the web tier (HTTP)
resource "aws_vpc_security_group_ingress_rule" "web_tier_in_http" {
  security_group_id = aws_security_group.web_tier_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

# OLD CODE - Only had HTTP port 80, missing HTTPS support
#Allows all internet traffic in for the web tier (HTTPS)
# Jurabek: Added HTTPS port 443 for ALB SSL termination support
resource "aws_vpc_security_group_ingress_rule" "web_tier_in_https" {
  security_group_id = aws_security_group.web_tier_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

#Allows traffic on all ports out to each app subnet
# Jurabek: Fixed invalid port range (-1) for TCP, changed to allow all ports (0-65535)
resource "aws_vpc_security_group_egress_rule" "web_tier_out" {
  for_each = toset(var.app_subnet_cidrs)

  security_group_id = aws_security_group.web_tier_sg.id

  cidr_ipv4   = each.value
  # from_port   = -1  # OLD CODE: -1 is invalid for TCP
  # to_port     = -1  # OLD CODE: -1 is invalid for TCP
  from_port   = 0     # Jurabek: Fixed to use valid port range
  ip_protocol = "tcp"
  to_port     = 65535 # Jurabek: Fixed to use valid port range
}

resource "aws_security_group" "app_tier_sg" {
  name        = "app_tier_sg"
  description = "Security group for the app tier"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}

#Allows traffic in from each web subnet
# Jurabek: Fixed invalid port range (-1) for TCP, changed to allow all ports (0-65535)
resource "aws_vpc_security_group_ingress_rule" "app_tier_in" {
  for_each = toset(var.web_subnet_cidrs)

  security_group_id = aws_security_group.app_tier_sg.id

  cidr_ipv4   = each.value
  # from_port   = -1  # OLD CODE: -1 is invalid for TCP
  # to_port     = -1  # OLD CODE: -1 is invalid for TCP
  from_port   = 0     # Jurabek: Fixed to use valid port range for app tier communication
  ip_protocol = "tcp"
  to_port     = 65535 # Jurabek: Fixed to use valid port range for app tier communication
}

#Allows traffic out to each db subnet on mysql port
resource "aws_vpc_security_group_egress_rule" "app_tier_out" {
  for_each = toset(var.db_subnet_cidrs)

  security_group_id = aws_security_group.app_tier_sg.id

  cidr_ipv4   = each.value
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}