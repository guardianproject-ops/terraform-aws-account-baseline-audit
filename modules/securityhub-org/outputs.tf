output "security_hub_has_cis_aws_foundations_enabled" {
  value = local.security_hub_has_cis_aws_foundations_enabled
}

output "sns_topic_security_hub_findings_arn" {
  value = aws_sns_topic.security_hub_findings.arn
}

output "sns_topic_security_hub_findings_name" {
  value = aws_sns_topic.security_hub_findings.name
}
