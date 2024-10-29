variable "image" {
  type = object({
    name = string
    tag  = string
  })
  default = {
    name = "wordpress"
    tag  = "latest"
  }
}

