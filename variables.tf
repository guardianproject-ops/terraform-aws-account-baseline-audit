variable "guardduty_enabled" {
  type        = bool
  default     = true
  description = <<-DOC
  Whether to enable GuardDuty in the AWS Organization.
DOC
}

variable "guardduty_auto_enable_organization_members" {
  type        = string
  default     = "ALL"
  description = <<-DOC
  Indicates the auto-enablement configuration of GuardDuty for the member accounts in the organization. Valid values are `ALL`, `NEW`, `NONE`.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration#auto_enable_organization_members
  DOC

}

variable "guardduty_cloudwatch_event_rule_pattern_detail_type" {
  type        = string
  default     = "GuardDuty Finding"
  description = <<-DOC
  The detail-type pattern used to match events that will be sent to SNS.

  For more information, see:
  https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html
  https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html
  https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html
  DOC
}

variable "guardduty_create_sns_topic" {
  type        = bool
  default     = false
  description = <<-DOC
  Flag to indicate whether an SNS topic should be created for notifications. If you want to send findings to a new SNS
  topic, set this to true and provide a valid configuration for subscribers.
  DOC
}

variable "guardduty_cloudwatch_enabled" {
  type        = bool
  default     = false
  description = <<-DOC
  Flag to indicate whether CloudWatch logging should be enabled for GuardDuty
  DOC
}

variable "guardduty_finding_publishing_frequency" {
  type        = string
  default     = null
  description = <<-DOC
  The frequency of notifications sent for finding occurrences. If the detector is a GuardDuty member account, the value
  is determined by the GuardDuty master account and cannot be modified, otherwise it defaults to SIX_HOURS.

  For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.
  Valid values for standalone and master accounts: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency
  DOC
}

variable "guardduty_findings_notification_arn" {
  default     = null
  type        = string
  description = <<-DOC
  The ARN for an SNS topic to send findings notifications to. This is only used if create_sns_topic is false.
  If you want to send findings to an existing SNS topic, set this to the ARN of the existing topic and set
  create_sns_topic to false.
  DOC
}

variable "guardduty_kubernetes_audit_logs_enabled" {
  type        = bool
  default     = false
  description = <<-DOC
  If `true`, enables Kubernetes audit logs as a data source for Kubernetes protection.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#audit_logs
  DOC
}

variable "guardduty_malware_protection_scan_ec2_ebs_volumes_enabled" {
  type        = bool
  default     = false
  description = <<-DOC
  Configure whether Malware Protection is enabled as data source for EC2 instances EBS Volumes in GuardDuty.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#malware-protection
DOC
}

variable "guardduty_s3_protection_enabled" {
  type        = bool
  default     = true
  description = <<-DOC
  If `true`, enables S3 protection.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#s3-logs
  DOC
}

variable "guardduty_subscribers" {
  type = map(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
  }))
  default     = {}
  description = <<-DOC
  A map of subscription configurations for SNS topics

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference

  protocol:
    The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially
    supported, see link) (email is an option but is unsupported in terraform, see link).
  endpoint:
    The endpoint to send data to, the contents will vary with the protocol. (see link for more information)
  endpoint_auto_confirms:
    Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is
    false.
  raw_message_delivery:
    Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not
    wrapped in JSON with the original message in the message property). Default is false.
  DOC
}

variable "guardduty_detector_features" {
  type = map(object({
    feature_name = string
    status       = string
    additional_configuration = optional(object({
      addon_name = string
      status     = string
    }), null)
  }))
  default     = {}
  nullable    = false
  description = <<-DOC
  A map of detector features for streaming foundational data sources to detect communication with known malicious domains and IP addresses and identify anomalous behavior.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/guardduty-features-activation-model.html#guardduty-features

  feature_name:
    The name of the detector feature. Possible values include: S3_DATA_EVENTS, EKS_AUDIT_LOGS, EBS_MALWARE_PROTECTION, RDS_LOGIN_EVENTS, EKS_RUNTIME_MONITORING, LAMBDA_NETWORK_LOGS, RUNTIME_MONITORING. Specifying both EKS Runtime Monitoring (EKS_RUNTIME_MONITORING) and Runtime Monitoring (RUNTIME_MONITORING) will cause an error. You can add only one of these two features because Runtime Monitoring already includes the threat detection for Amazon EKS resources. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorFeatureConfiguration.html.
  status:
    The status of the detector feature. Valid values include: ENABLED or DISABLED.
  additional_configuration:
    Optional information about the additional configuration for a feature in your GuardDuty account. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorAdditionalConfiguration.html.
  addon_name:
    The name of the add-on for which the configuration applies. Possible values include: EKS_ADDON_MANAGEMENT, ECS_FARGATE_AGENT_MANAGEMENT, and EC2_AGENT_MANAGEMENT. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorAdditionalConfiguration.html.
  status:
    The status of the add-on. Valid values include: ENABLED or DISABLED.
  DOC
}


variable "securityhub_enabled" {
  type        = bool
  default     = true
  description = <<-DOC
  Whether to enable SecurityHub in the AWS Organization.
DOC
}

variable "management_account_id" {
  type        = string
  description = <<-EOT
The account id for the AWS Organizations root account
EOT
}

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

variable "kms_key_policy_audit" {
  type        = list(string)
  default     = []
  description = "A list of valid KMS key policy JSON document for use with audit KMS key"
}

variable "aws_auditmanager" {
  type = object({
    enabled               = bool
    reports_bucket_prefix = string
  })
  default = {
    enabled               = true
    reports_bucket_prefix = "audit-manager-reports"
  }
  description = "AWS Audit Manager config settings"
}

variable "monitor_iam_activity" {
  type        = bool
  default     = true
  description = "Whether IAM activity should be monitored"
}

variable "monitor_iam_activity_sns_subscription" {
  type = map(object({
    endpoint = string
    protocol = string
  }))
  default     = {}
  description = "Subscription options for the LandingZone-IAMActivity SNS topic"
}


variable "logging_account_id" {
  type        = string
  description = <<-EOT
The account id for the AWS Control Tower Log archive account
EOT
}

variable "path" {
  type        = string
  default     = "/"
  description = "Optional path for all IAM users, user groups, roles, and customer managed policies created by this module"
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
