#This file creates two ec2 roles
#One just for SSM access for the web tier, and one for SSM and access to relevant s3 buckets for the app tier

locals {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "s3_and_ssm_instance_profile" {
  name = "instance_profile_for_s3_and_ssm"
  role = aws_iam_role.s3_and_ssm_role.name

  tags = var.tags
}

resource "aws_iam_role" "s3_and_ssm_role" {
  name               = "ec2_role_for_ssm_and_s3"
  assume_role_policy = local.assume_role_policy
  tags               = var.tags
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "instance_profile_for_ssm"
  role = aws_iam_role.ssm_role.name

  tags = var.tags
}

resource "aws_iam_role" "ssm_role" {
  name               = "ec2_role_for_ssm"
  assume_role_policy = local.assume_role_policy
  tags               = var.tags
}

#Policy for ec2 instances that need to access s3
resource "aws_iam_policy" "s3_policy" {
  name        = "s3_policy_for_ec2"
  description = "This policy allows ec2 instances to get and put objects in s3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::mybucketmarch16dsdsdsd"] #Replace with list of buckets from s3 module!!
      },
    ]
  })
}

#Managed AWS policy for SSM
data "aws_iam_policy" "ssm_managed_core_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  for_each   = toset([aws_iam_role.ssm_role.name, aws_iam_role.s3_and_ssm_role.name])
  role       = each.value
  policy_arn = data.aws_iam_policy.ssm_managed_core_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.s3_and_ssm_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}