variable "name-prefix" {
  type        = string
  description = "name prefix for environment"
}
variable "image" {
  type = object({
    name = string
    tag = string
  })
  default = {
    name = "ngnix"
    tag  = "latest"
  }
}

