data "aws_region" "current" {}
data "aws_caller_identity" "audit" {}

locals {
  enabled             = module.this.enabled
  guardduty_enabled   = local.enabled && var.guardduty_enabled
  securityhub_enabled = local.enabled && var.securityhub_enabled
}

module "kms_key_audit" {
  source                  = "cloudposse/kms-key/aws"
  version                 = "0.12.2"
  context                 = module.this.context
  description             = "KMS Key for audit account ${module.this.id}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  alias                   = "alias/${module.this.id}"
  policy                  = data.aws_iam_policy_document.kms_key_audit.json
}

data "aws_iam_policy_document" "kms_key_audit" {
  source_policy_documents = var.kms_key_policy_audit

  statement {
    sid       = "Root permission"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.audit.account_id}:root"]
    }
  }

  statement {
    sid       = "Administrative permissions for pipeline"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:GenerateDataKey*",
      "kms:Get*",
      "kms:List*",
      "kms:Put*",
      "kms:Revoke*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Update*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.audit.account_id}:role/AWSControlTowerExecution"
      ]
    }
  }

  statement {
    sid       = "List KMS keys permissions for all IAM users"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.audit.account_id}:root"
      ]
    }
  }

  statement {
    sid       = "Allow CloudWatch Decrypt"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }

  statement {
    sid       = "Allow SNS Decrypt"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.aws_auditmanager.enabled ? ["allow_audit_manager"] : []

    content {
      sid       = "Allow Audit Manager from management to describe and grant"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

      actions = [
        "kms:CreateGrant",
        "kms:DescribeKey"
      ]

      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${var.management_account_id}:root"
        ]
      }

      condition {
        test     = "Bool"
        variable = "kms:ViaService"

        values = [
          "auditmanager.amazonaws.com"
        ]
      }
    }
  }

  dynamic "statement" {
    for_each = var.aws_auditmanager.enabled ? ["allow_audit_manager"] : []
    content {
      sid       = "Encrypt and Decrypt permissions for S3"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${var.management_account_id}:key/*"]

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ]

      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${var.management_account_id}:root"
        ]
      }

      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values = [
          "s3.${data.aws_region.current.name}.amazonaws.com",
        ]
      }
    }
  }
}


module "guardduty_org" {
  source                                          = "./guardduty-org"
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
  source                            = "./securityhub-org"
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
