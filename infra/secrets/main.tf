locals {
  # todo: dbの接続情報の管理を考える
  # todo: terraformの書籍が参考になると思う
  kore_miteyo_secrets = {
    DATABASE_HOST     = "fill_your_db_host"
    DATABASE_PORT     = 5432
    DATABASE_NAME     = "app"
    DATABASE_USERNAME = "fill_your_db_user_name"
    DATABASE_PASSWORD = "fill_your_db_password"
  }
}

resource "aws_secretsmanager_secret" "image_manager_secrets" {
  name                    = "image-manager-secrets"
  description             = "Secrets for the image manager application"
  recovery_window_in_days = 0
  lifecycle {
    ignore_changes = [name, description]
  }
}

resource "aws_secretsmanager_secret_version" "image_manager_secrets" {
  secret_id     = aws_secretsmanager_secret.image_manager_secrets.id
  secret_string = jsonencode(local.kore_miteyo_secrets)
}
