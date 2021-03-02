main.tf
------

provider "aws" {
  region = var.region
}
resource "aws_db_subnet_group" "Groups" {
  name       = "db groups"
  subnet_ids = var.private_subnets

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_security_group" "data" {
  name        = "data-SG"
  description = "Allow mysql inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Traffic"
    from_port        = 1521
    to_port          = 1521
    protocol         = "tcp"
  }

  tags = {
    Name = "data_server-SG"
  }

}


resource "aws_db_instance" "db" {
  identifier             = "${var.identifier}-${var.environment}"
  allocated_storage      = "${var.allocated_storage}"
  max_allocated_storage  = "${var.max_storage}"
  storage_type           = "${var.storage_type}"
  iops                   = "${var.iops}"
  license_model          = "license-included"
  engine                 = "${var.engine}"
  engine_version         = "${var.engine_version}"
  instance_class         = "${var.instance_class}"
  name                   = "${var.database_name}"
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.Groups.name
  vpc_security_group_ids = [aws_security_group.data.id]
  username               = "admin"
  password               = "admin123"


 depends_on = [ aws_db_subnet_group.Groups, aws_security_group.data ]

}
--------------

variable.tf
----------------

variable "region" {
    description = "region name"
    default = "us-east-2"
}
variable "identifier" {
    description = "Enter the name of our database which is unique in that region"
    default = "galaxy-g7"
}

variable "allocated_storage" {
    description = "Enter the storage of database"
    default = "100"
}

variable "max_storage" {
    description = "Enter the storage of database"
    default = "1000"
}
variable "storage_type" {
    description = "Put the type of storage you want"
    default = "io1"
}

variable "iops" {
    description = "Put the iops value"
    default = "3000"
}
variable "engine" {
    description = "Put your database engine you want eg. mysql"
    default = "oracle-se2"
}

variable "engine_version" {
    description = "Which version you want of your db engine"
    default = "19.0.0.0.ru-2020-07.rur-2020-07.r1"
}

variable "instance_class" {
    description = "Which type of instance you need like ram and cpu  eg. db.t2.micro"
    default = "db.m5.large"
}

variable "database_name" {
    description = "Enter your initial database name"
    default = "galaxy7"
}

variable "environment" {
    description = "your environment name"
    default = "dev"
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  default = ["subnet-0475b8ee0866ce514", "subnet-06fed82599ff539ab", "subnet-0641fdf173336da80"]
}

variable "vpc_id" {
  description      =  "put your vpc id"
  default = "vpc-04cbc1ac7a6211c6c"
}
