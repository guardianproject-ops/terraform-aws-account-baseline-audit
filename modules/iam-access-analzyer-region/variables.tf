variable "iam_access_analyzer_unused_access_age" {
  type        = number
  description = "The specified access age in days for which to generate findings for unused access"
  default     = 60
}

variable "iam_access_analyzer_enabled" {
  type        = bool
  default     = true
  description = <<-DOC
  Whether to enable IAM Access Analyzer in the AWS Organization.
DOC
}
