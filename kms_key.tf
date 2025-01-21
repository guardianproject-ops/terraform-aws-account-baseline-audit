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
