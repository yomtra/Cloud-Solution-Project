# Terraform AWS RDS Module

This module provisions:
- A MySQL-compatible RDS instance (Primary)
- A Read Replica in a second AZ
- Security group allowing MySQL access from the application tier

---

## 📦 Features

- Primary and Read Replica RDS Instances
- Deployed in two private subnets (one per AZ)
- Custom DB engine, version, size, and instance type
- Secure with private access and security groups
- Outputs for endpoint and credentials for use by other modules

---

## ✅ Requirements

- Existing VPC
- Two private subnets in different AZs (for primary and replica)
- Terraform v1.0+

---

## 📥 Inputs

| Name                   | Description                                  | Type     | Required |
|------------------------|----------------------------------------------|----------|----------|
| `name`                 | Name prefix for all RDS resources            | `string` | ✅ yes   |
| `vpc_id`               | VPC ID where RDS will be deployed            | `string` | ✅ yes   |
| `private_subnet_3_id`  | Subnet ID for primary RDS instance           | `string` | ✅ yes   |
| `private_subnet_4_id`  | Subnet ID for read replica                   | `string` | ✅ yes   |
| `engine`               | Database engine (e.g., `mysql`)              | `string` | no       |
| `engine_version`       | Engine version                               | `string` | no       |
| `instance_class`       | DB instance class (e.g., `db.t3.micro`)      | `string` | ✅ yes   |
| `allocated_storage`    | Storage in GB                                | `number` | no       |
| `username`             | Master DB username                           | `string` | ✅ yes   |
| `password`             | Master DB password                           | `string` | ✅ yes   |
| `tags`                 | Tags applied to all resources                | `map`    | no       |

---

## 📤 Outputs

| Name                      | Description                      |
|---------------------------|----------------------------------|
| `rds_endpoint`            | Primary DB endpoint              |
| `rds_read_replica_endpoint` | Replica DB endpoint             |
| `rds_sg_id`               | Security group ID                |
| `rds_port`                | DB Port (default: 3306)          |
| `rds_username`            | DB master username               |

---

## 🚀 Example Usage

```hcl
module "rds" {
  source = "./modules/rds"

  name                 = "app-db"
  vpc_id               = module.vpc.vpc_id
  private_subnet_3_id  = module.vpc.private_subnet_3_id
  private_subnet_4_id  = module.vpc.private_subnet_4_id

  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20

  username             = "admin"
  password             = var.db_password

  tags = {
    Environment = "dev"
    Owner       = "team-database"
  }
}
```

---

## 🧪 Notes

- The application tier should be in subnets `10.32.0.0/24` and `10.48.0.0/24` to access this DB by default.
- You can modify the `cidr_blocks` in the security group if needed.
