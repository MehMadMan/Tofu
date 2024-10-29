module "aws_instance" {
  source        = "./modules/aws_instance"
  name_prefix   = "opentufo-week2"
  instance_type = "t2.micro"
  ami           = module.aws_instance.AMI_name
  user_data     = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d \
                -e WORDPRESS_DB_HOST=${module.aws_db_instance.address} \
                -e WORDPRESS_DB_USER=${module.aws_db_instance.username} \
                -e WORDPRESS_DB_PASSWORD=${module.aws_db_instance.password} \
                -e WORDPRESS_DB_NAME=${module.aws_db_instance.db_name} \
                -p 80:80 ${var.image.name}:${var.image.tag}
              EOF
  tags = {
    Name = "ec2instance"
  }
}
module "aws_db_instance" {
  source           = "./modules/aws_db_instance"
  instance_class   = "db.t3.micro"
  db_user_password = "superpass"
  db_username      = "admin"
  dbname           = "wordpress"
  name_prefix      = "opentufo-week2"
}
