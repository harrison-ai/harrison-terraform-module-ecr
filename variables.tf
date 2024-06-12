variable "name" {
  type        = string
  description = "Name of the ECR Repository"
}

variable "mutable_tags" {
  type        = bool
  default     = true
  description = "Boolean setting for repository tag mutability"
}

variable "account_ids" {
  type        = list(string)
  default     = []
  description = "List of AWS Account ID's that will be granted access to the repository"
}

variable "untagged_images_to_keep" {
  type        = number
  default     = 1
  description = "Number of untagged images to keep"
}

variable "tagged_images_to_keep" {
  type        = number
  default     = 5
  description = "Number of tagged images to keep"
}

variable "override_policy" {
  type        = bool
  default     = false
  description = "Boolean setting to override the default policy"
}

variable "policy" {
  type        = string
  default     = null
  description = "A json encoded policy to override the default policy"
}

variable "override_lifecycle_policy" {
  type        = bool
  default     = false
  description = "Boolean setting to override the default lifecycle policy"
}

variable "lifecycle_policy" {
  type        = map(any)
  default     = null
  description = "A lifecycle policy to override the default policy"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resource"
}
