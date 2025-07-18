# modules/iam/main.tf

# IAM Groups
resource "aws_iam_group" "sysadmin" {
  name = "SysAdmin"
}

resource "aws_iam_group" "dbadmin" {
  name = "DBAdmin"
}

resource "aws_iam_group" "monitor" {
  name = "Monitor"
}

# IAM Users
resource "aws_iam_user" "sysadmin1" {
  name = "sysadmin1"
}
resource "aws_iam_user" "sysadmin2" {
  name = "sysadmin2"
}

resource "aws_iam_user" "dbadmin1" {
  name = "dbadmin1"
}
resource "aws_iam_user" "dbadmin2" {
  name = "dbadmin2"
}
resource "aws_iam_user" "monitoruser1" {
  name = "monitoruser1"
}
resource "aws_iam_user" "monitoruser2" {
  name = "monitoruser2"
}
resource "aws_iam_user" "monitoruser3" {
  name = "monitoruser3"
}
resource "aws_iam_user" "monitoruser4" {
  name = "monitoruser4"
}


# IAM Policies


resource "aws_iam_user_group_membership" "sysadmin1_membership" {
  user   = aws_iam_user.sysadmin1.name
  groups = [aws_iam_group.sysadmin.name]
}


resource "aws_iam_user_group_membership" "sysadmin2_membership" {
  user   = aws_iam_user.sysadmin2.name
  groups = [aws_iam_group.sysadmin.name]
}
resource "aws_iam_user_group_membership" "dbadmin1_membership" {
  user   = aws_iam_user.dbadmin1.name
  groups = [aws_iam_group.dbadmin.name]
}
resource "aws_iam_user_group_membership" "dbadmin2_membership" {
  user   = aws_iam_user.dbadmin2.name
  groups = [aws_iam_group.dbadmin.name]
}
resource "aws_iam_user_group_membership" "monitoruser1_membership" {
  user   = aws_iam_user.monitoruser1.name
  groups = [aws_iam_group.monitor.name]
}
resource "aws_iam_user_group_membership" "monitoruser2_membership" {
  user   = aws_iam_user.monitoruser2.name
  groups = [aws_iam_group.monitor.name]
}
resource "aws_iam_user_group_membership" "monitoruser3_membership" {
  user   = aws_iam_user.monitoruser3.name
  groups = [aws_iam_group.monitor.name]
}
resource "aws_iam_user_group_membership" "monitoruser4_membership" {
  user   = aws_iam_user.monitoruser4.name
  groups = [aws_iam_group.monitor.name]
}


# Password policy
resource "aws_iam_account_password_policy" "strict_policy" {
  minimum_password_length        = 12
  require_uppercase_characters  = true
  require_lowercase_characters  = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  hard_expiry                    = false
}

# EC2 IAM Role
resource "aws_iam_role" "ec2_role" {
  name = "ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "s3_readonly" {
  name       = "attach_s3_policy"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}
