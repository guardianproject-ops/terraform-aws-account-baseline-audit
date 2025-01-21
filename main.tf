data "aws_region" "current" {}
data "aws_caller_identity" "audit" {}

locals {
  enabled             = module.this.enabled
  guardduty_enabled   = local.enabled && var.guardduty_enabled
  securityhub_enabled = local.enabled && var.securityhub_enabled
}

module "guardduty_org" {
  source                                          = "./modules/guardduty-org"
  context                                         = module.this.context
  enabled                                         = local.guardduty_enabled
  finding_publishing_frequency                    = var.guardduty_finding_publishing_frequency
  create_sns_topic                                = var.guardduty_create_sns_topic
  findings_notification_arn                       = var.guardduty_findings_notification_arn
  subscribers                                     = var.guardduty_subscribers
  cloudwatch_enabled                              = var.guardduty_cloudwatch_enabled
  cloudwatch_event_rule_pattern_detail_type       = var.guardduty_cloudwatch_event_rule_pattern_detail_type
  s3_protection_enabled                           = var.guardduty_s3_protection_enabled
  kubernetes_audit_logs_enabled                   = var.guardduty_kubernetes_audit_logs_enabled
  malware_protection_scan_ec2_ebs_volumes_enabled = var.guardduty_malware_protection_scan_ec2_ebs_volumes_enabled
  auto_enable_organization_members                = var.guardduty_auto_enable_organization_members
  detector_features                               = var.guardduty_detector_features
}

module "securityhub_org" {
  source                            = "./modules/securityhub-org"
  context                           = module.this.context
  enabled                           = local.securityhub_enabled
  aws_security_hub                  = var.aws_security_hub
  governed_regions                  = var.governed_regions
  aws_organization_root_id          = var.aws_organization_root_id
  logging_account_id                = var.logging_account_id
  audit_kms_key_id                  = module.kms_key_audit.key_id
  sns_topic_arn_feedback            = aws_iam_role.sns_feedback.arn
  aws_security_hub_sns_subscription = var.aws_security_hub_sns_subscription
}
