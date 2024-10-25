output "instance_arn" {
  value       = aws_instance.ec2_instance.arn
  description = "ARN for deployed ec2 resource"
}
output "public-ip" {
  value = "http://${aws_instance.ec2_instance.public_ip}"
}
output "ami-name" {
  value = data.aws_ami.latest_amzn2_ami.name
}
output "ami-id" {
  value = data.aws_ami.latest_amzn2_ami.id
}
output "default-vpc-cidr" {
  value = data.aws_vpc.default_vpc.cidr_block
}