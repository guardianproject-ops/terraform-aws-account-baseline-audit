locals {
  #security_hub_roles = module.securityhub_org.security_hub_has_cis_aws_foundations_enabled ? sort([
  #  for account_id, _ in local.aws_account_emails : "\"arn:aws:sts::${account_id}:assumed-role/AWSServiceRoleForSecurityHub/securityhub\""
  #  if account_id != data.aws_caller_identity.audit.account_id
  #]) : []
}
resource "aws_sns_topic" "iam_activity" {
  count                          = var.monitor_iam_activity ? 1 : 0
  name                           = "LandingZone-IAMActivity"
  http_success_feedback_role_arn = aws_iam_role.sns_feedback.arn
  http_failure_feedback_role_arn = aws_iam_role.sns_feedback.arn
  kms_master_key_id              = module.kms_key_audit.key_id
  tags                           = module.this.tags
}


resource "aws_sns_topic_policy" "iam_activity" {
  count = var.monitor_iam_activity ? 1 : 0
  arn   = aws_sns_topic.iam_activity[0].arn

  policy = data.aws_iam_policy_document.iam_activity_topic_policy.json
}

data "aws_iam_policy_document" "iam_activity_topic_policy" {
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

    resources = [aws_sns_topic.iam_activity[0].arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.audit.account_id]
    }
  }

  statement {
    sid    = "AllowServicesToPublishFromMgmtAccount"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.iam_activity[0].arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [var.management_account_id]
    }
  }

  statement {
    sid    = "AllowMgmtMasterToListSubcriptions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.management_account_id}:root"]
    }

    actions   = ["sns:ListSubscriptionsByTopic"]
    resources = [aws_sns_topic.iam_activity[0].arn]
  }

  # dynamic "statement" {
  #   for_each = length(local.security_hub_roles) > 0 ? [1] : []
  #   content {
  #     sid    = "AllowListSubscribersBySecurityHub"
  #     effect = "Allow"

  #     principals {
  #       type        = "AWS"
  #       identifiers = local.security_hub_roles
  #     }

  #     actions   = ["sns:ListSubscriptionsByTopic"]
  #     resources = [aws_sns_topic.iam_activity[0].arn]
  #   }
  # }
}

resource "aws_sns_topic_subscription" "iam_activity" {
  for_each               = var.monitor_iam_activity ? var.monitor_iam_activity_sns_subscription : {}
  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = aws_sns_topic.iam_activity[0].arn
}

resource "aws_iam_role" "sns_feedback" {
  name               = "LandingZone-SNSFeedback"
  path               = var.path
  tags               = module.this.tags
  assume_role_policy = data.aws_iam_policy_document.service_assume_role.json
}

data "aws_iam_policy_document" "service_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sns_feedback" {
  statement {
    sid = "SNSFeedbackPolicy"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]

    resources = compact([module.securityhub_org.sns_topic_security_hub_findings_arn, var.monitor_iam_activity ? aws_sns_topic.iam_activity[0].arn : null])

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.audit.account_id]
    }
  }
}

resource "aws_iam_role_policy" "sns_feedback_policy" {
  name   = "LandingZone-SNSFeedbackPolicy"
  policy = data.aws_iam_policy_document.sns_feedback.json
  role   = aws_iam_role.sns_feedback.id
}
