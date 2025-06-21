resource "aws_rds_cluster" "kore_miteyo_db" {
  cluster_identifier     = "kore-miteyo-db"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = "15.4"
  db_subnet_group_name   = var.kore_miteyo_db_subnet_group_name
  vpc_security_group_ids = [var.kore_miteyo_db_security_group_id, var.kore_miteyo_vpc_connector_security_group_id]
  skip_final_snapshot    = true

  database_name               = "app"
  master_username             = "app"
  manage_master_user_password = true

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1.0
  }
}

resource "aws_rds_cluster_instance" "kore_miteyo_db" {
  identifier           = "kore-miteyo-db-instance"
  cluster_identifier   = aws_rds_cluster.kore_miteyo_db.id
  engine               = aws_rds_cluster.kore_miteyo_db.engine
  engine_version       = aws_rds_cluster.kore_miteyo_db.engine_version
  instance_class       = "db.serverless"
  db_subnet_group_name = var.kore_miteyo_db_subnet_group_name
}
