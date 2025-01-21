output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = local.guardduty_enabled ? try(module.guardduty_org[0].guardduty_detector_id, null) : null
}

output "guardduty_detector_arn" {
  description = "The ARN of the GuardDuty detector."
  value       = local.guardduty_enabled ? try(module.guardduty_org[0].guardduty_detector_arn, null) : null
}

output "guardduty_sns_topic_name" {
  value       = local.guardduty_enabled ? try(module.guardduty_org[0].sns_topic_name, null) : null
  description = "The name of the SNS topic created by the component"
}

output "guardduty_sns_topic_subscriptions" {
  value       = local.guardduty_enabled ? try(module.guardduty_org[0].sns_topic_subscriptions, null) : null
  description = "The SNS topic subscriptions created by the component"
}

output "kms_key_audit_id" {
  description = "The ID of the KMS key used for audit logs."
  value       = module.kms_key_audit.key_id
}

output "kms_key_audit_arn" {
  description = "The ARN of the KMS key used for audit logs."
  value       = module.kms_key_audit.key_arn
}

output "sns_topic_monitor_iam_activity_arn" {
  description = "ARN of the SNS Topic in the Audit account for IAM activity monitoring notifications"
  value       = var.monitor_iam_activity ? aws_sns_topic.iam_activity[0].arn : ""
}

output "sns_topic_monitor_iam_activity_name" {
  description = "NAME of the SNS Topic in the Audit account for IAM activity monitoring notifications"
  value       = var.monitor_iam_activity ? aws_sns_topic.iam_activity[0].name : ""
}

output "sns_topic_security_hub_findings_arn" {
  value = module.securityhub_org.sns_topic_security_hub_findings_arn
}

output "sns_topic_security_hub_findings_name" {
  value = module.securityhub_org.sns_topic_security_hub_findings_name
}
