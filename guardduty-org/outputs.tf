output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = local.guardduty_detector_id
}

output "guardduty_detector_arn" {
  description = "The ARN of the GuardDuty detector."
  value       = local.guardduty_detector_arn
}

output "sns_topic_name" {
  value       = local.guardduty_enabled ? try(module.guardduty[0].sns_topic.name, null) : null
  description = "The name of the SNS topic created by the component"
}

output "sns_topic_subscriptions" {
  value       = local.guardduty_enabled ? try(module.guardduty[0].sns_topic_subscriptions, null) : null
  description = "The SNS topic subscriptions created by the component"
}
