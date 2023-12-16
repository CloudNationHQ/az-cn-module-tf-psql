variable "postgresql" {
  type = any
}

variable "tags" {
  default = {}
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}
