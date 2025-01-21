data "aws_region" "current" {}
data "aws_caller_identity" "audit" {}
locals {
  security_hub_standards_arns_default = [
    "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.4.0",
    "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1"
  ]

  security_hub_standards_arns = var.aws_security_hub.standards_arns != null ? var.aws_security_hub.standards_arns : local.security_hub_standards_arns_default

  security_hub_has_cis_aws_foundations_enabled = length(regexall(
    "cis-aws-foundations-benchmark/v", join(",", local.security_hub_standards_arns)
  )) > 0 ? true : false

  # have to exclude the current region
  aggregate_regions = [for region in var.governed_regions : region if region != data.aws_region.current.name]
}

resource "aws_securityhub_account" "this" {
  enable_default_standards = false
}

resource "aws_securityhub_finding_aggregator" "this" {
  linking_mode      = var.aws_security_hub.aggregator_linking_mode
  specified_regions = var.aws_security_hub.aggregator_linking_mode == "SPECIFIED_REGIONS" ? local.aggregate_regions : null
  depends_on        = [aws_securityhub_account.this]
}

resource "aws_securityhub_organization_configuration" "this" {
  auto_enable           = false
  auto_enable_standards = "NONE"
  organization_configuration {
    configuration_type = "CENTRAL"
  }
  depends_on = [
    aws_securityhub_account.this,
    aws_securityhub_finding_aggregator.this
  ]
}

resource "aws_securityhub_configuration_policy" "this" {
  name        = module.this.id
  description = "LZ default configuration policy"

  configuration_policy {
    service_enabled       = true
    enabled_standard_arns = local.security_hub_standards_arns

    security_controls_configuration {
      disabled_control_identifiers = var.aws_security_hub.disabled_control_identifiers
      enabled_control_identifiers  = var.aws_security_hub.enabled_control_identifiers
    }
  }

  depends_on = [aws_securityhub_organization_configuration.this]
}


resource "aws_securityhub_configuration_policy_association" "root" {
  target_id = var.aws_organization_root_id
  policy_id = aws_securityhub_configuration_policy.this.id
}

resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  name        = "LandingZone-SecurityHubFindings"
  description = "Rule for getting SecurityHub findings"
  event_pattern = jsonencode({
    "detail-type" = ["Security Hub Findings - Imported"]
    source        = ["aws.securityhub"]
    detail = {
      findings = {
        Severity = {
          Label = [
            "HIGH",
            "CRITICAL",
            "MEDIUM"
          ]
        }
      }
    }
  })

  tags = module.this.tags
}


resource "aws_sns_topic" "security_hub_findings" {
  name                           = "LandingZone-SecurityHubFindings"
  http_success_feedback_role_arn = var.sns_topic_arn_feedback
  http_failure_feedback_role_arn = var.sns_topic_arn_feedback
  kms_master_key_id              = var.audit_kms_key_id
  tags                           = module.this.tags
}

resource "aws_sns_topic_policy" "security_hub_findings" {
  arn    = aws_sns_topic.security_hub_findings.arn
  policy = data.aws_iam_policy_document.security_hub_findings.json
}

data "aws_iam_policy_document" "security_hub_findings" {
  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission"
    ]

    resources = [aws_sns_topic.security_hub_findings.arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.audit.account_id]
    }
  }

  statement {
    sid    = "__services_allowed_publish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.security_hub_findings.arn]
  }
}


resource "aws_sns_topic_subscription" "security_hub_findings" {
  for_each               = var.aws_security_hub_sns_subscription
  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = aws_sns_topic.security_hub_findings.arn
}

resource "aws_securityhub_member" "logging" {
  account_id = var.logging_account_id
  lifecycle {
    ignore_changes = [invite]
  }

  depends_on = [aws_securityhub_organization_configuration.this]
}
