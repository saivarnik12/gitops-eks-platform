terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "saivarnik-terraform-state"
    key            = "eks-platform/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  cluster_name = "eks-${var.environment}-cluster"

  common_tags = {
    Project     = "gitops-eks-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "devops"
  }
}

module "vpc" {
  source             = "../../modules/vpc"
  cluster_name       = local.cluster_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.common_tags
}

module "eks" {
  source              = "../../modules/eks"
  cluster_name        = local.cluster_name
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types
  desired_nodes       = var.desired_nodes
  min_nodes           = var.min_nodes
  max_nodes           = var.max_nodes
  tags                = local.common_tags
}
