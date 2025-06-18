variable "kore_miteyo_secrets_manager_arn" {
  type = string
}

variable "kore_miteyo_vpc_id" {
  type = string
}

variable "kore_miteyo_codebuild_subnet_ids" {
  type = list(string)
}

variable "kore_miteyo_db_security_group_id" {
  type = string
}

variable "kore_miteyo_codebuild_security_group_id" {
  type = string
}

variable "kore_miteyo_service_role_arn" {
  type = string
}
