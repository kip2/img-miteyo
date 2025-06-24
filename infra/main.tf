# Terraform全体で使われる変数
variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

# Terraform全体で使われる変数
variable "aws_profile" {
  type    = string
  default = "admin"
}

terraform {
  # terraform CLIの要件
  required_version = "~> 1"

  # 使用するプロバイダー(AWS)
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.1"
    }
  }

  backend "s3" {
    bucket  = "kore-miteyo-bucket"
    region  = "ap-northeast-1"
    profile = "admin"
    key     = "kore-miteyo.tfstate"
    encrypt = true
  }
}

# TerraformがAWSに接続するための設定
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "network" {
  source = "./network"
}

module "middleware" {
  source                                      = "./middleware"
  kore_miteyo_db_subnet_group_name            = module.network.kore_miteyo_db_subnet_group_name
  kore_miteyo_db_security_group_id            = module.network.kore_miteyo_db_security_group_id
  kore_miteyo_redis_security_group_id         = module.network.kore_miteyo_redis_security_group_id
  kore_miteyo_vpc_connector_security_group_id = module.network.kore_miteyo_vpc_connector_security_group_id
  kore_miteyo_codebuild_security_group_id     = module.network.kore_miteyo_codebuild_security_group_id
  kore_miteyo_redis_subnet_group_name         = module.network.kore_miteyo_redis_subnet_group_name
}

module "secrets" {
  source = "./secrets"
}

module "app" {
  source                          = "./app"
  kore_miteyo_vpc_id              = module.network.kore_miteyo_vpc_id
  kore_miteyo_db_subnet_ids       = module.network.kore_miteyo_db_subnet_ids
  kore_miteyo_vpc_connector_sg_id = module.network.kore_miteyo_vpc_connector_security_group_id
  kore_miteyo_secrets_manager_arn = module.secrets.kore_miteyo_secrets_manager_arn
  apprunner_instance_role_arn     = module.iam.apprunner_instance_role_arn
  apprunner_ecr_access_role_arn   = module.iam.apprunner_ecr_access_role_arn
}

module "iam" {
  source                          = "./iam"
  kore_miteyo_db_subnet_arns      = module.network.kore_miteyo_db_subnet_arns
  kore_miteyo_private_subnet_arns = module.network.kore_miteyo_private_subnet_arns
}

module "codebuild" {
  source                                  = "./codebuild"
  kore_miteyo_secrets_manager_arn         = module.secrets.kore_miteyo_secrets_manager_arn
  kore_miteyo_vpc_id                      = module.network.kore_miteyo_vpc_id
  kore_miteyo_codebuild_subnet_ids        = module.network.kore_miteyo_private_subnet_ids
  kore_miteyo_db_security_group_id        = module.network.kore_miteyo_db_security_group_id
  kore_miteyo_codebuild_security_group_id = module.network.kore_miteyo_codebuild_security_group_id
  kore_miteyo_service_role_arn            = module.iam.codebuild_service_role_arn
}
