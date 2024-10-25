resource "aws_instance" "ec2_instance" {          #ec2 for hosting wordpress
  ami                         = var.ec2-ami-linux #AMI for linux instance
  instance_type               = "t2.micro"        #Free tier t2.micro instance
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2-instance-sg.id]
  #wordpress deployment
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                amazon-linux-extras install docker -y
                service docker start
                usermod -a -G docker ec2-user
                docker run -d -p 80:80 nginx
                EOF
  tags = {
    Name = "${var.name-prefix}-ec2instance"

  }
}
resource "aws_security_group" "ec2-wordpress-sg" {
  name        = "${var.name-prefix}-ec2-sg"
  description = "security group to allow egress and ingress"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere (replace with a specific IP range for better security)
  }
  ingress {
    description = "HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere (replace with a specific IP range for better security)
  }

  # Needs to be able to get to docker hub to download images
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}