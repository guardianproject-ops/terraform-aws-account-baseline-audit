
<!-- markdownlint-disable -->
# terraform-aws-account-baseline-audit


<!-- markdownlint-restore -->

<!-- [![README Header][readme_header_img]][readme_header_link] -->

[![The Guardian][logo]][website]

<!--




  ** DO NOT EDIT THIS FILE
  **
  ** This file was automatically generated by the `build-harness`.
  ** 1) Make all changes to `README.yaml`
  ** 2) Run `make init` (you only need to do this once)
  ** 3) Run`make readme` to rebuild this file.
  **
  ** (We maintain HUNDREDS of open source projects. This is how we maintain our sanity.)
  **





-->

Terraform module for bringing an AWS Control Tower Audit account into governance.

---






It's 100% Open Source and licensed under the [GNU General Public License](LICENSE).









## Introduction


This module should be used on Audit accounts created by Control Tower.
It sets up the following features:

  - Guard Duty for the entire AWS Org (You must run the corresponding root account baseline module first!)
  - Security Hub for the entire AWS Org
  - IAM user usage alerts 
  - IAM Access Analyzer for the entire AWS Org


You must run our [terraform-aws-account-baseline-root](https://gitlab.com/guardianproject-ops/terraform-aws-account-baseline-root) module first to setup administrator delegation for many of the services.



## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

Also, because of a bug in the Terraform registry ([hashicorp/terraform#21417](https://github.com/hashicorp/terraform/issues/21417)),
the registry shows many of our inputs as required when in fact they are optional.
The table below correctly indicates which inputs are required.



To apply the account level baselines use:

```terraform
module "audit" {
  source                   = "git::https://gitlab.com/guardianproject-ops/terraform-aws-account-baseline-audit?ref=main"
  guardduty_enabled        = var.guardduty_enabled
  governed_regions         = var.governed_regions
  aws_organization_root_id = var.aws_organization_root_id
  management_account_id    = var.management_account_id
  logging_account_id       = var.logging_account_id
  context                  = module.this.context
}
```

Then for each region where you want the IAM Access Analyzer to be enabled, run the following with a provider in each region:

```terraform
module "audit_baseline_region" {
  source           = "git::https://gitlab.com/guardianproject-ops/terraform-aws-account-baseline-audit//modules/iam-access-analzyer-region?ref=main"
  context          = module.this.context
}
```






<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.78.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.78.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_guardduty_org"></a> [guardduty\_org](#module\_guardduty\_org) | ./modules/guardduty-org | n/a |
| <a name="module_kms_key_audit"></a> [kms\_key\_audit](#module\_kms\_key\_audit) | cloudposse/kms-key/aws | 0.12.2 |
| <a name="module_securityhub_org"></a> [securityhub\_org](#module\_securityhub\_org) | ./modules/securityhub-org | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.sns_feedback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.sns_feedback_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_sns_topic.iam_activity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.iam_activity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.iam_activity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.iam_activity_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_feedback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aws_auditmanager"></a> [aws\_auditmanager](#input\_aws\_auditmanager) | AWS Audit Manager config settings | <pre>object({<br/>    enabled               = bool<br/>    reports_bucket_prefix = string<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "reports_bucket_prefix": "audit-manager-reports"<br/>}</pre> | no |
| <a name="input_aws_organization_root_id"></a> [aws\_organization\_root\_id](#input\_aws\_organization\_root\_id) | The organization root id, this is NOT the root account id, this is a property of the AWS Organization resource it self.<br/>Use: aws organizations list-roots --query "Roots[0].Id" | `string` | n/a | yes |
| <a name="input_aws_security_hub"></a> [aws\_security\_hub](#input\_aws\_security\_hub) | AWS Security Hub settings | <pre>object({<br/>    aggregator_linking_mode      = optional(string, "SPECIFIED_REGIONS")<br/>    auto_enable_controls         = optional(bool, true)<br/>    control_finding_generator    = optional(string, "SECURITY_CONTROL")<br/>    create_cis_metric_filters    = optional(bool, true)<br/>    disabled_control_identifiers = optional(list(string), null)<br/>    enabled_control_identifiers  = optional(list(string), null)<br/>    product_arns                 = optional(list(string), [])<br/>    standards_arns               = optional(list(string), null)<br/>  })</pre> | `{}` | no |
| <a name="input_aws_security_hub_sns_subscription"></a> [aws\_security\_hub\_sns\_subscription](#input\_aws\_security\_hub\_sns\_subscription) | Subscription options for the LandingZone-SecurityHubFindings SNS topic | <pre>map(object({<br/>    endpoint = string<br/>    protocol = string<br/>  }))</pre> | `{}` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_governed_regions"></a> [governed\_regions](#input\_governed\_regions) | List of AWS regions to enable LandingZone, GuardDuty, etc in | `list(string)` | n/a | yes |
| <a name="input_guardduty_auto_enable_organization_members"></a> [guardduty\_auto\_enable\_organization\_members](#input\_guardduty\_auto\_enable\_organization\_members) | Indicates the auto-enablement configuration of GuardDuty for the member accounts in the organization. Valid values are `ALL`, `NEW`, `NONE`.<br/><br/>For more information, see:<br/>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration#auto_enable_organization_members | `string` | `"ALL"` | no |
| <a name="input_guardduty_cloudwatch_enabled"></a> [guardduty\_cloudwatch\_enabled](#input\_guardduty\_cloudwatch\_enabled) | Flag to indicate whether CloudWatch logging should be enabled for GuardDuty | `bool` | `false` | no |
| <a name="input_guardduty_cloudwatch_event_rule_pattern_detail_type"></a> [guardduty\_cloudwatch\_event\_rule\_pattern\_detail\_type](#input\_guardduty\_cloudwatch\_event\_rule\_pattern\_detail\_type) | The detail-type pattern used to match events that will be sent to SNS.<br/><br/>For more information, see:<br/>https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html<br/>https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html<br/>https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html | `string` | `"GuardDuty Finding"` | no |
| <a name="input_guardduty_create_sns_topic"></a> [guardduty\_create\_sns\_topic](#input\_guardduty\_create\_sns\_topic) | Flag to indicate whether an SNS topic should be created for notifications. If you want to send findings to a new SNS<br/>topic, set this to true and provide a valid configuration for subscribers. | `bool` | `false` | no |
| <a name="input_guardduty_detector_features"></a> [guardduty\_detector\_features](#input\_guardduty\_detector\_features) | A map of detector features for streaming foundational data sources to detect communication with known malicious domains and IP addresses and identify anomalous behavior.<br/><br/>For more information, see:<br/>https://docs.aws.amazon.com/guardduty/latest/ug/guardduty-features-activation-model.html#guardduty-features<br/><br/>feature\_name:<br/>  The name of the detector feature. Possible values include: S3\_DATA\_EVENTS, EKS\_AUDIT\_LOGS, EBS\_MALWARE\_PROTECTION, RDS\_LOGIN\_EVENTS, EKS\_RUNTIME\_MONITORING, LAMBDA\_NETWORK\_LOGS, RUNTIME\_MONITORING. Specifying both EKS Runtime Monitoring (EKS\_RUNTIME\_MONITORING) and Runtime Monitoring (RUNTIME\_MONITORING) will cause an error. You can add only one of these two features because Runtime Monitoring already includes the threat detection for Amazon EKS resources. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorFeatureConfiguration.html.<br/>status:<br/>  The status of the detector feature. Valid values include: ENABLED or DISABLED.<br/>additional\_configuration:<br/>  Optional information about the additional configuration for a feature in your GuardDuty account. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorAdditionalConfiguration.html.<br/>addon\_name:<br/>  The name of the add-on for which the configuration applies. Possible values include: EKS\_ADDON\_MANAGEMENT, ECS\_FARGATE\_AGENT\_MANAGEMENT, and EC2\_AGENT\_MANAGEMENT. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorAdditionalConfiguration.html.<br/>status:<br/>  The status of the add-on. Valid values include: ENABLED or DISABLED. | <pre>map(object({<br/>    feature_name = string<br/>    status       = string<br/>    additional_configuration = optional(object({<br/>      addon_name = string<br/>      status     = string<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_guardduty_enabled"></a> [guardduty\_enabled](#input\_guardduty\_enabled) | Whether to enable GuardDuty in the AWS Organization. | `bool` | `true` | no |
| <a name="input_guardduty_finding_publishing_frequency"></a> [guardduty\_finding\_publishing\_frequency](#input\_guardduty\_finding\_publishing\_frequency) | The frequency of notifications sent for finding occurrences. If the detector is a GuardDuty member account, the value<br/>is determined by the GuardDuty master account and cannot be modified, otherwise it defaults to SIX\_HOURS.<br/><br/>For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.<br/>Valid values for standalone and master accounts: FIFTEEN\_MINUTES, ONE\_HOUR, SIX\_HOURS."<br/><br/>For more information, see:<br/>https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency | `string` | `null` | no |
| <a name="input_guardduty_findings_notification_arn"></a> [guardduty\_findings\_notification\_arn](#input\_guardduty\_findings\_notification\_arn) | The ARN for an SNS topic to send findings notifications to. This is only used if create\_sns\_topic is false.<br/>If you want to send findings to an existing SNS topic, set this to the ARN of the existing topic and set<br/>create\_sns\_topic to false. | `string` | `null` | no |
| <a name="input_guardduty_kubernetes_audit_logs_enabled"></a> [guardduty\_kubernetes\_audit\_logs\_enabled](#input\_guardduty\_kubernetes\_audit\_logs\_enabled) | If `true`, enables Kubernetes audit logs as a data source for Kubernetes protection.<br/><br/>For more information, see:<br/>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#audit_logs | `bool` | `false` | no |
| <a name="input_guardduty_malware_protection_scan_ec2_ebs_volumes_enabled"></a> [guardduty\_malware\_protection\_scan\_ec2\_ebs\_volumes\_enabled](#input\_guardduty\_malware\_protection\_scan\_ec2\_ebs\_volumes\_enabled) | Configure whether Malware Protection is enabled as data source for EC2 instances EBS Volumes in GuardDuty.<br/><br/>For more information, see:<br/>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#malware-protection | `bool` | `false` | no |
| <a name="input_guardduty_s3_protection_enabled"></a> [guardduty\_s3\_protection\_enabled](#input\_guardduty\_s3\_protection\_enabled) | If `true`, enables S3 protection.<br/><br/>For more information, see:<br/>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#s3-logs | `bool` | `true` | no |
| <a name="input_guardduty_subscribers"></a> [guardduty\_subscribers](#input\_guardduty\_subscribers) | A map of subscription configurations for SNS topics<br/><br/>For more information, see:<br/>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference<br/><br/>protocol:<br/>  The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially<br/>  supported, see link) (email is an option but is unsupported in terraform, see link).<br/>endpoint:<br/>  The endpoint to send data to, the contents will vary with the protocol. (see link for more information)<br/>endpoint\_auto\_confirms:<br/>  Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is<br/>  false.<br/>raw\_message\_delivery:<br/>  Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not<br/>  wrapped in JSON with the original message in the message property). Default is false. | <pre>map(object({<br/>    protocol               = string<br/>    endpoint               = string<br/>    endpoint_auto_confirms = bool<br/>    raw_message_delivery   = bool<br/>  }))</pre> | `{}` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kms_key_policy_audit"></a> [kms\_key\_policy\_audit](#input\_kms\_key\_policy\_audit) | A list of valid KMS key policy JSON document for use with audit KMS key | `list(string)` | `[]` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_logging_account_id"></a> [logging\_account\_id](#input\_logging\_account\_id) | The account id for the AWS Control Tower Log archive account | `string` | n/a | yes |
| <a name="input_management_account_id"></a> [management\_account\_id](#input\_management\_account\_id) | The account id for the AWS Organizations root account | `string` | n/a | yes |
| <a name="input_monitor_iam_activity"></a> [monitor\_iam\_activity](#input\_monitor\_iam\_activity) | Whether IAM activity should be monitored | `bool` | `true` | no |
| <a name="input_monitor_iam_activity_sns_subscription"></a> [monitor\_iam\_activity\_sns\_subscription](#input\_monitor\_iam\_activity\_sns\_subscription) | Subscription options for the LandingZone-IAMActivity SNS topic | <pre>map(object({<br/>    endpoint = string<br/>    protocol = string<br/>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_path"></a> [path](#input\_path) | Optional path for all IAM users, user groups, roles, and customer managed policies created by this module | `string` | `"/"` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_securityhub_enabled"></a> [securityhub\_enabled](#input\_securityhub\_enabled) | Whether to enable SecurityHub in the AWS Organization. | `bool` | `true` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_guardduty_detector_arn"></a> [guardduty\_detector\_arn](#output\_guardduty\_detector\_arn) | The ARN of the GuardDuty detector. |
| <a name="output_guardduty_detector_id"></a> [guardduty\_detector\_id](#output\_guardduty\_detector\_id) | The ID of the GuardDuty detector. |
| <a name="output_guardduty_sns_topic_name"></a> [guardduty\_sns\_topic\_name](#output\_guardduty\_sns\_topic\_name) | The name of the SNS topic created by the component |
| <a name="output_guardduty_sns_topic_subscriptions"></a> [guardduty\_sns\_topic\_subscriptions](#output\_guardduty\_sns\_topic\_subscriptions) | The SNS topic subscriptions created by the component |
| <a name="output_kms_key_audit_arn"></a> [kms\_key\_audit\_arn](#output\_kms\_key\_audit\_arn) | The ARN of the KMS key used for audit logs. |
| <a name="output_kms_key_audit_id"></a> [kms\_key\_audit\_id](#output\_kms\_key\_audit\_id) | The ID of the KMS key used for audit logs. |
| <a name="output_sns_topic_monitor_iam_activity_arn"></a> [sns\_topic\_monitor\_iam\_activity\_arn](#output\_sns\_topic\_monitor\_iam\_activity\_arn) | ARN of the SNS Topic in the Audit account for IAM activity monitoring notifications |
| <a name="output_sns_topic_monitor_iam_activity_name"></a> [sns\_topic\_monitor\_iam\_activity\_name](#output\_sns\_topic\_monitor\_iam\_activity\_name) | NAME of the SNS Topic in the Audit account for IAM activity monitoring notifications |
| <a name="output_sns_topic_security_hub_findings_arn"></a> [sns\_topic\_security\_hub\_findings\_arn](#output\_sns\_topic\_security\_hub\_findings\_arn) | n/a |
| <a name="output_sns_topic_security_hub_findings_name"></a> [sns\_topic\_security\_hub\_findings\_name](#output\_sns\_topic\_security\_hub\_findings\_name) | n/a |
<!-- markdownlint-restore -->




## Help

**Got a question?** We got answers.

File a GitLab [issue](https://gitlab.com/guardianproject-ops/terraform-aws-account-baseline-audit/-/issues), send us an [email][email] or join our [Matrix Community][matrix].

## Matrix Community

[![Matrix badge](https://img.shields.io/badge/Matrix-%23guardianproject%3Amatrix.org-blueviolet)][matrix]

Join our [Open Source Community][matrix] on Matrix. It's **FREE** for everyone!
This is the best place to talk shop, ask questions, solicit feedback, and work
together as a community to build on our open source code.

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://gitlab.com/guardianproject-ops/terraform-aws-account-baseline-audit/-/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or help out with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitLab
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2021-2025 The Guardian Project










## License

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

```text
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```






## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained by [The Guardian Project][website].

[![The Guardian Project][logo]][website]

We're a [collective of designers, developers, and ops][website] folk focused on useable
privacy and security with a focus on digital human rights and humanitarian projects.

Everything we do is 100% FOSS.

Follow us on [Mastodon][mastodon] or [twitter][twitter], [apply for a job][join], or
[partner with us][partner].

We offer [paid support][contact] on all of our projects.

Check out [our other DevOps projects][gitlab] or our [entire other set of
projects][nonops] related to privacy and security related software, or [hire
us][website] to get support with using our projects.


## Contributors

<!-- markdownlint-disable -->
|  [![Abel Luck][abelxluck_avatar]][abelxluck_homepage]<br/>[Abel Luck][abelxluck_homepage] |
|---|
<!-- markdownlint-restore -->

  [abelxluck_homepage]: https://gitlab.com/abelxluck

  [abelxluck_avatar]: https://secure.gravatar.com/avatar/0f605397e0ead93a68e1be26dc26481a?s=200&amp;d=identicon


<!-- markdownlint-disable -->
  [website]: https://guardianproject.info/?utm_source=gitlab&utm_medium=readme&utm_campaign=guardianproject-ops/terraform-aws-account-baseline-audit&utm_content=website
  [gitlab]: https://www.gitlab.com/guardianproject-ops
  [contact]: https://guardianproject.info/contact/
  [matrix]: https://matrix.to/#/%23guardianproject:matrix.org
  [readme_header_img]: https://gitlab.com/guardianproject/guardianprojectpublic/-/raw/master/Graphics/GuardianProject/pngs/logo-color-w256.png
  [readme_header_link]: https://guardianproject.info?utm_source=gitlab&utm_medium=readme&utm_campaign=guardianproject-ops/terraform-aws-account-baseline-audit&utm_content=readme_header_link
  [readme_commercial_support_img]: https://www.sr2.uk/readme/paid-support.png
  [readme_commercial_support_link]: https://www.sr2.uk/?utm_source=gitlab&utm_medium=readme&utm_campaign=guardianproject-ops/terraform-aws-account-baseline-audit&utm_content=readme_commercial_support_link
  [partner]: https://guardianproject.info/how-you-can-work-with-us/
  [nonops]: https://gitlab.com/guardianproject
  [mastodon]: https://social.librem.one/@guardianproject
  [twitter]: https://twitter.com/guardianproject
  [email]: mailto:support@guardianproject.info
  [join_email]: mailto:jobs@guardianproject.info
  [join]: https://guardianproject.info/contact/join/
  [logo_square]: https://assets.gitlab-static.net/uploads/-/system/group/avatar/3262938/guardianproject.png?width=88
  [logo]: https://gitlab.com/guardianproject/guardianprojectpublic/-/raw/master/Graphics/GuardianProject/pngs/logo-color-w256.png
  [logo_black]: https://gitlab.com/guardianproject/guardianprojectpublic/-/raw/master/Graphics/GuardianProject/pngs/logo-black-w256.png
  [cdr]: https://digiresilience.org
  [cdr-tech]: https://digiresilience.org/tech/
<!-- markdownlint-restore -->
