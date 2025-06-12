# VPC設定
resource "aws_vpc" "kore_miteyo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "kore-miteyo-vpc"
  }
}

# サブネット設定
resource "aws_subnet" "kore_miteyo_ingress_1a" {
  vpc_id            = aws_vpc.kore_miteyo.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.az_a
  tags = {
    Name = "kore-miteyo-ingress-1a"
  }
}

# サブネット設定2
resource "aws_subnet" "kore_miteyo_ingress_1c" {
  vpc_id            = aws_vpc.kore_miteyo.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_c
  tags = {
    Name = "kore-miteyo-ingress-1c"
  }
}

# サブネット設定3
resource "aws_subnet" "kore_miteyo_container_1a" {
  vpc_id            = aws_vpc.kore_miteyo.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = var.az_a
  tags = {
    Name = "kore-miteyo-container-1a"
  }
}

# サブネット設定4
resource "aws_subnet" "kore_miteyo_container_1c" {
  vpc_id            = aws_vpc.kore_miteyo.id
  cidr_block        = "10.0.9.0/24"
  availability_zone = var.az_c
  tags = {
    Name = "kore-miteyo-container-1c"
  }
}

# サブネット設定5
resource "aws_subnet" "kore_miteyo_db_1a" {
  vpc_id            = aws_vpc.kore_miteyo.id
  cidr_block        = "10.0.16.0/24"
  availability_zone = var.az_a
  tags = {
    Name = "kore-miteyo-db-1a"
  }
}

# サブネット設定6
resource "aws_subnet" "kore_miteyo_db_1c" {
  vpc_id            = aws_vpc.kore_miteyo.id
  cidr_block        = "10.0.17.0/24"
  availability_zone = var.az_c
  tags = {
    Name = "kore-miteyo-db-1c"
  }
}

# サブネットグループ設定
resource "aws_db_subnet_group" "kore_miteyo" {
  name = "kore-miteyo-db"
  subnet_ids = [
    aws_subnet.kore_miteyo_db_1a.id,
    aws_subnet.kore_miteyo_db_1c.id
  ]
}

# インターネット接続
# VPCに対する外部接続
resource "aws_internet_gateway" "kore_miteyo" {
  vpc_id = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-igw"
  }
}

# インターネット接続設定
# インターネット向けルートを持つ
resource "aws_route_table" "kore_miteyo_public" {
  vpc_id = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-public"
  }
}

# インターネット接続設定
resource "aws_route" "kore_miteyo_public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.kore_miteyo_public.id
  gateway_id             = aws_internet_gateway.kore_miteyo.id
}

# インターネット接続設定(1a)
# ingressサブネットに紐づく(パブリックサブネット)
resource "aws_route_table_association" "kore_miteyo_public_1a" {
  subnet_id      = aws_subnet.kore_miteyo_ingress_1a.id
  route_table_id = aws_route_table.kore_miteyo_public.id
}

# インターネット接続設定(1c)
# ingressサブネットに紐づく(パブリックサブネット)
resource "aws_route_table_association" "kore_miteyo_public_1c" {
  subnet_id      = aws_subnet.kore_miteyo_ingress_1c.id
  route_table_id = aws_route_table.kore_miteyo_public.id
}

# インターネット接続
# VPCに対する退部接続
resource "aws_route_table" "kore_miteyo_private_1a" {
  vpc_id = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-private-1a"
  }
}

#---------------------
# プライベートサブネット(1a)用設定
#=====================

# NAT Gateway 経由でインターネットで出るためのルート
resource "aws_route" "kore_miteyo_private_1a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.kore_miteyo_private_1a.id
  gateway_id             = aws_nat_gateway.nat_1a.id
}

# サブネットにルートテーブルを関連付ける
resource "aws_route_table_association" "kore_miteyo_private_1a" {
  subnet_id      = aws_subnet.kore_miteyo_private_1a.id
  route_table_id = aws_route_table.kore_miteyo_private_1a.id
}

#---------------------
# プライベートサブネット(1c)用設定
#=====================

# プライベートサブネット 1c 用ルートテーブル定義
resource "aws_route_table" "kore_miteyo_private_1c" {
  vpc_id = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-private-1c"
  }
}

# NAT Gateway(1c)経由でインターネトへ出るルートを追加
resource "aws_route" "kore_miteyo_private_1c" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.kore_miteyo_private_1c.id
  gateway_id             = aws_nat_gateway.nat_1c.id
}

# プライベートサブネット 1c にルートテーブルを関連付ける
resource "aws_route_table_association" "kore_miteyo_private_1c" {
  subnet_id      = aws_subnet.kore_miteyo_private_1c.id
  route_table_id = aws_route_table.kore_miteyo_private_1c.id
}

#---------------------
# NAT Gateway (1a) ゾーン用
#=====================

# Elastic IP (EIP) を確保:NAT Gatewayに割り当てるための固定グローバルIPアドレス
resource "aws_eip" "nat_1a" {
  domain = "vpc"
  tags = {
    Name = "kore-miteyo-natgw-1a"
  }
}

# NAT Gatewayを作成
resource "aws_nat_gateway" "nat_1a" {
  subnet_id     = aws_subnet.kore_miteyo_ingress_1a.id
  allocation_id = aws_eip.nat_1a.id
  tags = {
    Name = "kore-miteyo-1a"
  }
}

#---------------------
# NAT Gateway (1c) ゾーン用
#=====================

# Elastic IP (EIP) を確保:NAT Gatewayに割り当てるための固定グローバルIPアドレス
resource "aws_eip" "nat_1c" {
  domain = "vpc"
  tags = {
    Name = "kore-miteyo-natgw-1c"
  }
}

# NAT Gatewayを作成(1cゾーン)
resource "aws_nat_gateway" "nat_1c" {
  subnet_id     = aws_subnet.kore_miteyo_ingress_1c.id
  allocation_id = aws_eip.nat_1c.id
  tags = {
    Name = "kore-miteyo-1c"
  }
}

#---------------------
# フロントエンドサービス用セキュリティグループ
#=====================

# フロントエンドサービスセキュリティグループを作成
resource "aws_security_group" "kore_miteyo_frontend" {
  name        = "kore-miteyo-frontend"
  description = "A security group for the frontend"
  vpc_id      = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-frontend"
  }
}

# フロントエンドへのHTTPアクセスを同じVPC無いから許可
resource "aws_vpc_security_group_ingress_rule" "kore_miteyo_frontend" {
  security_group_id = aws_security_group.kore_miteyo_frontend.id
  cidr_ipv4         = aws_vpc.kore_miteyo.cidr_block
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# フロントエンドサービスからの全外向き通信を許可
resource "aws_vpc_security_group_egress_rule" "kore_miteyo_frontend" {
  security_group_id = aws_security_group.kore_miteyo_frontend.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#---------------------
# バックエンドサービス用セキュリティグループ
#=====================

# バックエンドサービス用のsキュリティグループ
resource "aws_security_group" "kore_miteyo_backend" {
  name        = "kore-miteyo-backend"
  description = "A security group for the backend"
  vpc_id      = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-backend"
  }
}

# バックエンドへの通信(ポート8080)をVPC内から許可
resource "aws_vpc_security_group_ingress_rule" "kore_miteyo_backend" {
  security_group_id = aws_security_group.kore_miteyo_backend.id
  cidr_ipv4         = aws_vpc.kore_miteyo.cidr_block
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

# バックエンドからの外向き通信をすべて許可
resource "aws_vpc_security_group_egress_rule" "kore_miteyo_backend" {
  security_group_id = aws_security_group.kore_miteyo_backend.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#---------------------
# DBインスタンス用セキュリティグループ
#=====================

# DBインスタンス用セキュリティグループ
resource "aws_security_group" "kore_miteyo_db" {
  name        = "kore-miteyo-db"
  description = "A security group to connect the database"
  vpc_id      = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-db"
  }
}

# VPC内の通信(5432)を許可
resource "aws_vpc_security_group_ingress_rule" "kore_miteyo_db" {
  security_group_id = aws_security_group.kore_miteyo_db.id
  cidr_ipv4         = aws_vpc.kore_miteyo.cidr_block
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

# CodeBuildからのDB接続専用許可
resource "aws_vpc_security_group_ingress_rule" "kore_miteyo_db_codebuild" {
  security_group_id            = aws_security_group.kore_miteyo_db.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.kore_miteyo_codebuild.id
}

# DBからの外向き通信を許可
resource "aws_vpc_security_group_egress_rule" "kore_miteyo_db" {
  security_group_id = aws_security_group.kore_miteyo_db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


#---------------------
# VPCコネクター用セキュリティグループ
#=====================

# App RunnerなどからDBに接続する場合のVPCコネクタ用セキュリティグループ
resource "aws_security_group" "kore_miteyo_vpc_connector" {
  name        = "kore-miteyo-vpc-connector"
  description = "A security group to connect the database with VPC connector"
  vpc_id      = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-vpc-connector"
  }
}

# VPCコネkツアからの外向き通信を許可
resource "aws_vpc_security_group_egress_rule" "kore_miteyo_vpc_connector" {
  security_group_id = aws_security_group.kore_miteyo_vpc_connector.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#---------------------
# プライベートサブネット NAT Gateway
#=====================

# プライベートサブネット(1a)
resource "aws_subnet" "kore_miteyo_private_1a" {
  vpc_id            = aws_vpc.kore_miteyo.id
  cidr_block        = "10.0.18.0/24"
  availability_zone = var.az_a
  tags = {
    Name = "kore-miteyo-private-1a"
  }
}

# プライベートサブネット(1c)
resource "aws_subnet" "kore_miteyo_private_1c" {
  vpc_id            = aws_vpc.kore_miteyo.id
  cidr_block        = "10.0.19.0/24"
  availability_zone = var.az_c
  tags = {
    Name = "kore-miteyo-private-1c"
  }
}

# NAT Gateway用EIP(1a)
resource "aws_eip" "kore_miteyo_private_nat_1a" {
  domain = "vpc"
  tags = {
    Name = "kore-miteyo-private-1a"
  }
}

# NAT Gateway(1a)
resource "aws_nat_gateway" "kore_miteyo_private_nat_1a" {
  subnet_id     = aws_subnet.kore_miteyo_private_1a.id
  allocation_id = aws_eip.kore_miteyo_private_nat_1a.id
  tags = {
    Name = "kore-miteyo-private-1a"
  }
}

# NAT Gateway用EIP(1c)
resource "aws_eip" "kore_miteyo_private_nat_1c" {
  domain = "vpc"
  tags = {
    Name = "kore-miteyo-private-1c"
  }
}

# NAT Gateway(1c)
resource "aws_nat_gateway" "kore_miteyo_private_nat_1c" {
  subnet_id     = aws_subnet.kore_miteyo_private_1c.id
  allocation_id = aws_eip.kore_miteyo_private_nat_1c.id
  tags = {
    Name = "kore-miteyo-private-1c"
  }
}

#---------------------
# CodeBuild用セキュリティグループ
#=====================

# CodeBuildに割り当てるセキュリティグループ
resource "aws_security_group" "kore_miteyo_codebuild" {
  name        = "kore-miteyo-codebuild"
  description = "A security group to connect the database"
  vpc_id      = aws_vpc.kore_miteyo.id
  tags = {
    Name = "kore-miteyo-codebuild"
  }
}

# CodeBuildに対してVPC内からの全ポート(TCP)通信を許可
resource "aws_vpc_security_group_ingress_rule" "kore_miteyo_codebuild" {
  security_group_id = aws_security_group.kore_miteyo_codebuild.id
  cidr_ipv4         = aws_vpc.kore_miteyo.cidr_block
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
}

# CodeBuildからの全外向き通信を許可
resource "aws_vpc_security_group_egress_rule" "kore_miteyo_codebuild" {
  security_group_id = aws_security_group.kore_miteyo_codebuild.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
