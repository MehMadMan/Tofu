variable "name_prefix" {
  type        = string
  description = "name prefix for environment"
}
variable "instance_class" {
  type        = string
  description = "DB instance class"
  default     = "db.t3.micro"
}
variable "allocated_storage" {
  type        = number
  description = "allocated storage for mariaDB"
  default     = 20
}
variable "engine" {
  type        = string
  description = "DB engine"
  default     = "mariadb"
}
variable "engine_version" {
  type        = string
  description = "mariaDB version"
  default     = "10.6"
}
variable "dbname" {
  type        = string
  description = "DB name"
}
variable "db_username" {
  type        = string
  description = "DB username"
}
variable "db_user_password" {
  type        = string
  description = "db user password"
}
variable "tags" {
  type = map(string)
  description = "Set your infrastructure tags"
  default = {}
}