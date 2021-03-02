main.tf
-------------
provider "aws" {
  region = var.region
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}-${var.environment}"
  version  = var.clusterversion

  role_arn = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


   vpc_config {
    subnet_ids =  concat(var.public_subnets, var.private_subnets)
  }

   timeouts {
     delete    =  "30m"
   }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy1,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController1
  ]
}


resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"
  description = "Allow cluster to manage node groups, fargate nodes and cloudwatch logs"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_fargate_profile" "eks_fargate" {
  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = "${var.cluster_name}-${var.environment}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids             = var.private_subnets

  selector {
    namespace = "default"
  }
  selector {
    namespace = "kube-system"
  }




  timeouts {
    create   = "30m"
    delete   = "30m"
  }
}
resource "aws_eks_fargate_profile" "coredns" {
  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = "coredns"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids             = var.private_subnets

  selector {
    labels = {
      "k8s-app" = "kube-dns"
    }
    namespace = "kube-system"
  }
}


resource "aws_iam_role" "eks_fargate_role" {
  name = "${var.cluster_name}-fargate_cluster_role"
  description = "Allow fargate cluster to allocate resources for running pods"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_fargate_role.name
}


resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_fargate_role.name
}
--------------------

variable.tf
------------------

variable "region" {
    description = "region name"
    default = "us-east-2"
}
variable "clusterversion" {
    description = "cluster version"
    default = "1.16"
}


variable "cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
  default = "galaxy7"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default = "dev"
}


variable "private_subnets" {
  description = "List of private subnet IDs"
  type    = list(string)
  default = ["subnet-0475b8ee0866ce514", "subnet-06fed82599ff539ab", "subnet-0641fdf173336da80"]
}

variable "public_subnets" {
  description = "List of private subnet IDs"
  type    = list(string)
  default = ["subnet-098e94f3cf6f12fde", "subnet-08b91d53d49eae097", "subnet-0536534c5b784cea4"]
}

----------------------

output.tf
------------

output "cluster_id" {
value  = aws_eks_cluster.eks_cluster.id
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}
