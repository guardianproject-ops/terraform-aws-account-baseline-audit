locals {
  enabled                = module.this.enabled
  guardduty_enabled      = local.enabled
  create_sns_topic       = local.enabled && var.create_sns_topic
  guardduty_detector_id  = local.guardduty_enabled ? try(module.guardduty[0].guardduty_detector.id, null) : null
  guardduty_detector_arn = local.guardduty_enabled ? try(module.guardduty[0].guardduty_detector.arn, null) : null
}

#data "aws_caller_identity" "this" {
#  count = local.enabled ? 1 : 0
#}

module "guardduty" {
  count   = local.guardduty_enabled ? 1 : 0
  source  = "cloudposse/guardduty/aws"
  version = "0.5.0"

  finding_publishing_frequency              = var.finding_publishing_frequency
  create_sns_topic                          = local.create_sns_topic
  findings_notification_arn                 = var.findings_notification_arn
  subscribers                               = var.subscribers
  enable_cloudwatch                         = var.cloudwatch_enabled
  cloudwatch_event_rule_pattern_detail_type = var.cloudwatch_event_rule_pattern_detail_type
  s3_protection_enabled                     = var.s3_protection_enabled

  context = module.this.context
}

# Configure GuardDuty across the entire AWS Organization to send GuardDuty findings to the detector in this account
resource "aws_guardduty_organization_configuration" "this" {
  count = local.guardduty_enabled ? 1 : 0

  auto_enable_organization_members = var.auto_enable_organization_members
  detector_id                      = local.guardduty_detector_id

  datasources {
    s3_logs {
      auto_enable = var.s3_protection_enabled
    }
    kubernetes {
      audit_logs {
        enable = var.kubernetes_audit_logs_enabled
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = var.malware_protection_scan_ec2_ebs_volumes_enabled
        }
      }
    }
  }
}

resource "aws_guardduty_detector_feature" "this" {
  for_each = { for k, v in var.detector_features : k => v if local.guardduty_enabled }

  detector_id = local.guardduty_detector_id
  name        = each.value.feature_name
  status      = each.value.status

  dynamic "additional_configuration" {
    for_each = each.value.additional_configuration != null ? [each.value.additional_configuration] : []
    content {
      name   = additional_configuration.value.addon_name
      status = additional_configuration.value.status
    }
  }
}
