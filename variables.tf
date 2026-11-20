variable "r53_profile_name" {
  description = "The name of the route53 profile"
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.r53_profile_id) != "" || trimspace(var.r53_profile_name) != ""
    error_message = "r53_profile_name must be provided when r53_profile_id is not set."
  }
}

variable "r53_zone_ids" {
  description = "The list of Route53 Private Zone IDs to associate with the Route53 Profile"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "r53_profile_id" {
  description = "The Id of an existing Route 53 profile. Setting this prevents a new profile from being created."
  type        = string
  default     = ""
}