variable "postgresql" {
  type = any
}

variable "workload" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  default = {}
}
