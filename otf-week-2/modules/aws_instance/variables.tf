variable "name_prefix" {
  type        = string
  description = "name prefix for environment"
}
variable "descriptions" {
  type        = string
  description = "set infrastructure description"
  default     = "openTofu week 2 infrastructure"
}
variable "ami" {
  type        = string
  description = "EC2 AMI"
  validation {
    condition     = length(regex("^ami-[0-9a-z]{17}$", var.ami)) > 0
    error_message = "not valid AMI"
  }
}
variable "instance_type" {
  type        = string
  description = "SKU for EC2"
  default     = "t2.micro"
  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "invalide instance type must use either t2 or t3.micro"
  }
}
variable "user_data" {
  type        = string
  description = "Launch script for EC2"
  default     = ""
}
variable "tags" {
  type        = map(string)
  description = "Set your infrastructure tags"
  default     = {}
}
