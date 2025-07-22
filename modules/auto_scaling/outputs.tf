output "launch_template_id" {
  value = aws_launch_template.main.id
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.main.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.main.name
}