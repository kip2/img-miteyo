output "apprunner_instance_role_arn" {
  value = aws_iam_role.apprunner_instance_role.arn
}

output "apprunner_ecr_access_role_arn" {
  value = aws_iam_role.apprunner_ecr_kore_miteyo.arn
}

output "codebuild_service_role_arn" {
  value = aws_iam_role.codebuild_kore_miteyo.arn
}
