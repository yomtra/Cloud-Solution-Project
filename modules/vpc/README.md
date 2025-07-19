✅ Terraform AWS VPC Module

This module provisions a complete **Virtual Private Cloud (VPC)** architecture in AWS. It includes support for public/private subnets, NAT Gateways, route tables, and optional tagging.

---

## 📦 Features

- Creates a VPC with customizable CIDR
- Supports multiple Availability Zones
- Configurable public and private subnets
- Optional NAT Gateway creation
- Outputs for use in other modules (RDS, EC2, etc.)
- Easily extendable for security groups and ACLs

---

## 🔧 Usage Example

```hcl
module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  cidr_block           = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway   = true

  tags = {
    Project     = "cloud-solution"
    Environment = var.environment
  }
}
📥 Input Variables
Name	Type	Description
environment	string	The environment name (e.g. dev, prod)
cidr_block	string	CIDR block for the main VPC
public_subnet_cidrs	list	List of CIDR blocks for public subnets
private_subnet_cidrs	list	List of CIDR blocks for private subnets
enable_nat_gateway	bool	Whether to create a NAT Gateway
tags	map	Common tags to apply to all resources

📤 Outputs
Output Name	Description
vpc_id	ID of the created VPC
public_subnet_ids	List of public subnet IDs
private_subnet_ids	List of private subnet IDs
nat_gateway_id	NAT Gateway ID (if enabled)
web_acl_id	Network ACL ID (if created)

⚙️ Requirements
Terraform ≥ 1.3.0

AWS Provider ≥ 4.0

📁 Module Structure
bash
Copy
Edit
modules/vpc/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md


👤 Author
ILAYDA OTCU