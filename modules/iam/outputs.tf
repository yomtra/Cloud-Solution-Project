# modules/iam/outputs.tf
output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}
output "sysadmin1_access_key_id" {
  value     = aws_iam_access_key.sysadmin1_key.id
  sensitive = true
}

output "sysadmin1_secret_access_key" {
  value     = aws_iam_access_key.sysadmin1_key.secret
  sensitive = true
}
