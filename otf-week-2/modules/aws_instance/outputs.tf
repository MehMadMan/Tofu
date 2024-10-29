output "instance_arn" {
  value       = aws_instance.ec2_instance.arn
  description = "ARN for deployed ec2 resource"
}
output "public-ip" {
  value = "http://${aws_instance.ec2_instance.public_ip}"
}
output "AMI_name" {
  value = aws_instance.ec2_instance.ami
}