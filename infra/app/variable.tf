variable "kore_miteyo_vpc_id" {
  type = string
}

variable "kore_miteyo_db_subnet_ids" {
  type = list(string)
}

variable "kore_miteyo_vpc_connector_sg_id" {
  type = string
}

variable "kore_miteyo_secrets_manager_arn" {
  type = string
}

variable "apprunner_instance_role_arn" {
  type = string
}

variable "apprunner_ecr_access_role_arn" {
  type = string
}
