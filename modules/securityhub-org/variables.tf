variable "aws_security_hub" {
  type = object({
    aggregator_linking_mode      = optional(string, "SPECIFIED_REGIONS")
    auto_enable_controls         = optional(bool, true)
    control_finding_generator    = optional(string, "SECURITY_CONTROL")
    create_cis_metric_filters    = optional(bool, true)
    disabled_control_identifiers = optional(list(string), null)
    enabled_control_identifiers  = optional(list(string), null)
    product_arns                 = optional(list(string), [])
    standards_arns               = optional(list(string), null)
  })
  default     = {}
  description = "AWS Security Hub settings"

  validation {
    condition     = contains(["SECURITY_CONTROL", "STANDARD_CONTROL"], var.aws_security_hub.control_finding_generator)
    error_message = "The \"control_finding_generator\" variable must be set to either \"SECURITY_CONTROL\" or \"STANDARD_CONTROL\"."
  }

  validation {
    condition     = contains(["SPECIFIED_REGIONS", "ALL_REGIONS"], var.aws_security_hub.aggregator_linking_mode)
    error_message = "The \"aggregator_linking_mode\" variable must be set to either \"SPECIFIED_REGIONS\" or \"ALL_REGIONS\"."
  }

  validation {
    condition     = try(length(var.aws_security_hub.enabled_control_identifiers), 0) == 0 || try(length(var.aws_security_hub.disabled_control_identifiers), 0) == 0
    error_message = "Only one of \"enabled_control_identifiers\" or \"disabled_control_identifiers\" variable can be set."
  }
}

variable "governed_regions" {
  description = "List of AWS regions to enable LandingZone, GuardDuty, etc in"
  type        = list(string)
}

variable "audit_kms_key_id" {
  description = "The main CMK KMS key used for the audit account"
  type        = string
}

variable "logging_account_id" {
  type        = string
  description = <<-EOT
The account id for the AWS Control Tower Log archive account
EOT
}

variable "sns_topic_arn_feedback" {
  type = string
}

variable "aws_security_hub_sns_subscription" {
  type = map(object({
    endpoint = string
    protocol = string
  }))
  default     = {}
  description = "Subscription options for the LandingZone-SecurityHubFindings SNS topic"
}

variable "aws_organization_root_id" {
  type        = string
  description = <<-EOT
The organization root id, this is NOT the root account id, this is a property of the AWS Organization resource it self.
Use: aws organizations list-roots --query "Roots[0].Id"
EOT
}
