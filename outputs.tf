output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = local.guardduty_enabled ? try(module.guardduty_org[0].guardduty_detector_id, null) : null
}

output "guardduty_detector_arn" {
  description = "The ARN of the GuardDuty detector."
  value       = local.guardduty_enabled ? try(module.guardduty_org[0].guardduty_detector_arn, null) : null
}

output "sns_topic_name" {
  value       = local.guardduty_enabled ? try(module.guardduty_org[0].sns_topic_name, null) : null
  description = "The name of the SNS topic created by the component"
}

output "sns_topic_subscriptions" {
  value       = local.guardduty_enabled ? try(module.guardduty_org[0].sns_topic_subscriptions, null) : null
  description = "The SNS topic subscriptions created by the component"
}
