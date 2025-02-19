# https://developer.hashicorp.com/terraform/tutorials/aws/aws-rds

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "metastore"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}


resource "aws_db_subnet_group" "metastore" {
  name       = "metastore"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "metastore"
  }
}


resource "aws_db_instance" "metastore" {
  identifier             = "metastore"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.1"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.metastore.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.metastore.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
