output "kore_miteyo_vpc_id" {
  value = aws_vpc.kore_miteyo.id
}

output "kore_miteyo_db_subnet_ids" {
  value = [
    aws_subnet.kore_miteyo_db_1a.id,
    aws_subnet.kore_miteyo_db_1c.id
  ]
}

output "kore_miteyo_db_subnet_arns" {
  value = [
    aws_subnet.kore_miteyo_db_1a.arn,
    aws_subnet.kore_miteyo_db_1c.arn
  ]
}

output "kore_miteyo_private_subnet_arns" {
  value = [
    aws_subnet.kore_miteyo_private_1a.arn,
    aws_subnet.kore_miteyo_private_1c.arn
  ]
}

output "kore_miteyo_private_subnet_ids" {
  value = [
    aws_subnet.kore_miteyo_private_1a.id,
    aws_subnet.kore_miteyo_private_1c.id
  ]
}

output "kore_miteyo_db_subnet_group_name" {
  value = aws_db_subnet_group.kore_miteyo.name
}

output "kore_miteyo_db_security_group_id" {
  value = aws_security_group.kore_miteyo_db.id
}

output "kore_miteyo_redis_security_group_id" {
  value = aws_security_group.kore_miteyo_redis.id
}

output "kore_miteyo_vpc_connector_security_group_id" {
  value = aws_security_group.kore_miteyo_vpc_connector.id
}

output "kore_miteyo_redis_subnet_group_name" {
  value = aws_elasticache_subnet_group.kore_miteyo_redis.name
}

output "kore_miteyo_codebuild_security_group_id" {
  value = aws_security_group.kore_miteyo_codebuild.id
}
