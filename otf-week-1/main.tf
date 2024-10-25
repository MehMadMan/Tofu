data "aws_ami" "latest_amzn2_ami" { #data block to search for aws-ami for linux 2 with hvm
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
data "aws_vpc" "default" { #to get the default vpc cider block
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}
resource "aws_instance" "ec2_instance" {                         #ec2 for hosting wordpress
  ami                         = data.aws_ami.latest_amzn2_ami.id #AMI for linux instance
  instance_type               = "t2.micro"                       #Free tier t2.micro instance
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2-wordpress-sg.id]
  #wordpress deployment
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                amazon-linux-extras install docker -y
                service docker start
                usermod -a -G docker ec2-user
                docker run -d \
                -e WORDPRESS_DB_HOST=${aws_db_instance.db_mariadb.address}
                -e WORDPRESS_DB_USER=${aws_db_instance.db_mariadb.username}
                -e WORDPRESS_DB_PASSWORD=${aws_db_instance.db_mariadb.password}
                -e WORDPRESS_DB_NAME=${aws_db_instance.db_mariadb.db_name}
                -p 80:80 ${var.image.name}:${var.image.tag}
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
  ingress {
    description = "mariadb port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = concat([data.aws_vpc.default.cidr_block]) # mariadb instance
  }
  # Needs to be able to get to docker hub to download images
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}
resource "aws_db_instance" "db_mariadb" {
  identifier        = "${var.name-prefix}-mariadb"
  instance_class    = "db.t3.micro"
  allocated_storage = "20"
  engine            = "mariadb"
  engine_version    = "10.6"

  db_name  = "worpress"
  username = "admin"
  password = "password"

  skip_final_snapshot = true
}
