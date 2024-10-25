data "aws_ami" "latest_amzn2_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
data "aws_vpc" "default_vpc" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}
resource "aws_instance" "ec2_instance" {                         #ec2 for hosting wordpress
  ami                         = data.aws_ami.latest_amzn2_ami.id #AMI for linux instance
  instance_type               = "t2.micro"                       #Free tier t2.micro instance
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ec2-wordpress-sg.id,
  aws_security_group.mariadb_sg.id]
  #wordpress deployment
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d \
                -e WORDPRESS_DB_HOST=${aws_db_instance.mariadb.address} \
                -e WORDPRESS_DB_USER=${aws_db_instance.mariadb.username} \
                -e WORDPRESS_DB_PASSWORD=${aws_db_instance.mariadb.password} \
                -e WORDPRESS_DB_NAME=${aws_db_instance.mariadb.db_name} \
                -p 80:80 ${var.image.name}:${var.image.tag}
              EOF
  tags = {
    Name = "${var.name-prefix}-ec2instance"

  }
}
resource "aws_db_instance" "mariadb" {
  identifier = "${var.name-prefix}-mariadb-instance"
  instance_class = "db.t3.micro"#same free and t2 marco
  allocated_storage = 20
  engine            = "mariadb"
  engine_version    = "10.6"
  db_name           = "wordpress" # logical database name

  username               = "admin"
  password               = "yourpassword"
  vpc_security_group_ids = [aws_security_group.mariadb_sg.id]
  skip_final_snapshot    = true
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
resource "aws_security_group" "mariadb_sg" {
  name        = "${var.name-prefix}=mariadb-sg"
  description = "sg for maria db to access the 3306 from ec2"
  ingress {
    description = "3306 ingress permission"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default_vpc.cidr_block]
  }
}