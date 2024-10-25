output "instance_arn" {
  value = aws_instance.ec2_instance.arn
  description = "ARN for deployed ec2 resource"
}
output "public ip" {
  value = ""
}