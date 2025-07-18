# ClouWatch Alarm Module
This module creates CloudWatch alarms that monitor performance for EC2 instances and ALBs. Also utilizes SNS to alert admins of any performance issues.

# Resources
- aws_cloudwatch_metric_alarm | cloudwatch alarm for cpu, bandwidth and 400 errors
- aws_sns_topic_subscription  | SNS subscribtion for the emails
- aws_sns_topic               | SNS topic for sending email alerts

# Inputs    
      Name                     Description                               Type      Required
- notification_email | Emails that will recieve alarm notifications | list(String) | Yes |
- web_instance_id    | Ids of the instace being monitored           | list(string) | Yes |
- alb_name_id        | ALBs monitored for 400 errors                | list(string) | Yes |

# Outputs
      Name                     Description                      
- high_cpu_usage_alarm_arn | ARNs of the high cpu usage alarms
- low_cpu_usage_alarm_arn  | ARNs of the low cpu usage alarms
- sns_topic_alarm_arn      | ARNs of the sns topic used for notifications

