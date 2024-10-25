resource "aws_instance" "ec2_instance" { #ec2 for hosting wordpress
  ami           = var.ec2-ami-linux      #AMI for linux instance
  instance_type = "t2.micro"             #Free tier t2.micro instance
  associate_public_ip_address = true
  #wordpress deployment
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                amazon-linux-extras install docker -y
                service docker start
                docker run -d -p 80:80 nginx
EOF
  tags = {
    Name = "${var.name-prefix}-ec2instance"
  }
}
