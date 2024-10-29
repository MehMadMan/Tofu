data "aws_vpc" "default_vpc" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

resource "aws_db_instance" "mariadb" {
  identifier             = "${var.name_prefix}-mariadb-instance"
  instance_class         = var.instance_class #same free and t2 marco
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  db_name                = var.dbname # logical database name
  username               = var.db_username
  password               = var.db_user_password
  vpc_security_group_ids = [aws_security_group.mariadb_sg.id]
  skip_final_snapshot    = true
  tags                   = var.tags
}

resource "aws_security_group" "mariadb_sg" {
  name        = "${var.name_prefix}-mariadb-sg"
  description = "sg for maria db to access the 3306 from ec2"
  ingress {
    description = "3306 ingress permission"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default_vpc.cidr_block]
  }
}