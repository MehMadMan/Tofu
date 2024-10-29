output "rds_endpoint" {
  description = "MariaDB RDS endpoint"
  value       = aws_db_instance.mariadb.endpoint
}
output "default-vpc-cidr" {
  value = data.aws_vpc.default_vpc.cidr_block
}
output "username" {
  description = "username for the DB"
  value = aws_db_instance.mariadb.username
}
output "password" {
  description = "db username password"
  value = aws_db_instance.mariadb.password
}
output "db_name" {
  description = "DB name which data getting saved"
  value = aws_db_instance.mariadb.db_name
}
output "address" {
  description = "address fot the DB"
  value = aws_db_instance.mariadb.address
}