# CloudWatch Alarm Module

This Terraform module creates CloudWatch alarms to monitor Auto Scaling Groups (ASGs) and Application Load Balancers (ALBs), and sets up SNS notifications for alerting administrators of performance issues.

## Resources

- `aws_cloudwatch_metric_alarm` – CloudWatch alarms for CPU, bandwidth, and HTTP 400 errors
- `aws_sns_topic` – SNS topic for sending email alerts
- `aws_sns_topic_subscription` – SNS subscriptions for notification emails

# Inputs    
| Name                   | Description                                         | Type         | Required |
|------------------------|-----------------------------------------------------|--------------|----------|
| notification_emails    | Emails that will receive alarm notifications        | list(string) | Yes      |
| autoscaling_group_name | Name of the Auto Scaling Group being monitored      | string       | Yes      |
| alb_name_ids           | List of ALB resource IDs monitored for 400 errors   | list(string) | Yes      |

## Outputs

| Name                        | Description                                  |
|-----------------------------|----------------------------------------------|
| high_cpu_usage_alarm        | ARN of the high CPU usage alarm              |
| low_cpu_usage_alarm         | ARN of the low CPU usage alarm               |
| high_asg_network_in_alarm   | ARN of the high ASG network in alarm         |
| low_asg_network_out_alarm   | ARN of the low ASG network out alarm         |
`