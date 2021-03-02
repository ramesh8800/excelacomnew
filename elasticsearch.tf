main.tf
--------------------
provider "aws" {
  region = var.region
}

resource "aws_security_group" "es" {
  name = var.security_grop_name
  description = "Allow inbound traffic to ElasticSearch from VPC CIDR"
  vpc_id = var.vpc_id

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name = var.domain_name
  elasticsearch_version = var.es_version

  cluster_config {
      instance_count = 1
      instance_type = var.instance_type
      zone_awareness_enabled = false

  }

  vpc_options {
      subnet_ids = [ var.subnet_id ]

      security_group_ids = [
          aws_security_group.es.id
      ]
  }

  ebs_options {
      ebs_enabled = true
      volume_size = var.ebs_volume_size
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "es:*",
          "Principal": "*",
          "Effect": "Allow",
          "Resource": "*"
      }
  ]
}
  CONFIG

  snapshot_options {
      automated_snapshot_start_hour = 23
  }

  tags = {
      Domain = var.domain_name
  }
}


----------------------------
variable.tf
-----------------

variable "region" {
    description = "region name"
    default = "us-east-2"
}
variable "vpc_id" {
    description = "vpc id"
    default = "vpc-04cbc1ac7a6211c6c"
}
variable "security_grop_name" {
    description = "security group name"
    default = "elastic-es-sg"
}
variable "domain_name" {
    description = "elasticsearch domain name"
    default = "elastic-domain"
}
variable "es_version" {
    description = "elasticsearch version"
    default = "7.7"
}
variable "instance_type" {
    description = "instance type"
    default = "r5.large.elasticsearch"
}
variable "subnet_id" {
    description = "enter your subnet id"
    default = "subnet-0641fdf173336da80"
}
variable "ebs_volume_size" {
    description = "enter your ebs volume size"
    default = "10"
}
