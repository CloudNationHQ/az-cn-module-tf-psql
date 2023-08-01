variable "postgresql" {
  type = any
}

variable "workload" {
  type = string
}

variable "environment" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "tags" {
  default = {}
}