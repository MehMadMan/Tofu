variable "name_prefix" {
  type        = string
  description = "name prefix for environment"
}
variable "key_name" {
  type        = string
  description = "Name of the key pair"
}
variable "instance_type" {
  type = string
  description = "sku which will be used"
}