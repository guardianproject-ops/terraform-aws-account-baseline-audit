locals {
  enabled                     = module.this.enabled
  iam_access_analyzer_enabled = local.enabled && var.iam_access_analyzer_enabled
}

data "aws_region" "current" {}

resource "aws_accessanalyzer_analyzer" "this" {
  count         = local.iam_access_analyzer_enabled ? 1 : 0
  analyzer_name = "organization-${data.aws_region.current.name}"
  type          = "ORGANIZATION"
  tags          = module.this.tags
}

resource "aws_accessanalyzer_analyzer" "unused_access" {
  count         = local.iam_access_analyzer_enabled ? 1 : 0
  analyzer_name = "organization-unused-access-${data.aws_region.current.name}"
  type          = "ORGANIZATION_UNUSED_ACCESS"
  tags          = module.this.tags
  configuration {
    unused_access {
      unused_access_age = var.iam_access_analyzer_unused_access_age
    }
  }
}
