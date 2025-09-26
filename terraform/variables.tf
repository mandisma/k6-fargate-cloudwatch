variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "company_name" {
  type        = string
  description = "Company name"
}

# variable "create_vpc" {
#   type = bool
#   default = false
#   description = "Should create a VPC"
# }
#
# variable "vpc_cidr" {
#   description = "CIDR block for the VPC"
#   type        = string
#   default     = "10.0.0.0/16"
# }
