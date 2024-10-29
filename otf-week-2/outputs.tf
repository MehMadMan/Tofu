output "instance_arn" {
  value       = module.aws_instance.instance_arn
  description = "ARN for deployed ec2 resource"
}
output "public-ip" {
  value = "http://${module.aws_instance.public-ip}"
}
output "ami-name" {
  value = module.aws_instance.AMI_name
}
output "default-vpc-cidr" {
  value = module.aws_db_instance.default-vpc-cidr
}