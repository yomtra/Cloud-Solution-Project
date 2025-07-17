# cap_prj
# cap_prj

# AWS IAM Module — Terraform Project

This project was built by **Parviz Davronov** as part of the Cloud Architect program...
...


# AWS IAM Module — Terraform Project

This project was built by **Parviz Davronov** as part of the Cloud Architect program. It defines and manages AWS IAM resources using **Terraform**, including users, groups, password policies, and an EC2 role with S3 access.

---

## Project Overview

The goal of this module is to create a secure and scalable identity and access management structure using Infrastructure as Code (IaC). The module is reusable and follows best practices for AWS IAM configuration.

---

## Features

- 3 IAM Groups:
  - `SysAdmin`
  - `DBAdmin`
  - `Monitor`

- 8 IAM Users:
  - `sysadmin1`, `sysadmin2`
  - `dbadmin1`, `dbadmin2`
  - `monitoruser1`, `monitoruser2`, `monitoruser3`, `monitoruser4`

- Group Membership:
  - Each user is assigned to their corresponding group using `aws_iam_user_group_membership`.

- IAM Policies:
  - Each group is granted AWS managed policies via group attachment.

- Password Policy:
  - Strong password enforcement with complexity, length, and expiration settings.

- MFA:
  - Multi-Factor Authentication (MFA) manually enabled for all users via AWS Console.

- EC2 IAM Role:
  - Role `ec2_instance_role` created and attached to an EC2 instance profile.
  - Attached policy: `AmazonS3ReadOnlyAccess`

---

## Module Structure

```hcl
cap_prj/
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
│   └── iam/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── .gitignore
└── README.md
