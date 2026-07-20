resource "aws_db_subnet_group" "rds" {
  name       = "${var.name}-rds-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.name}-rds-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier          = "${var.name}-aurora-mysql"
  engine                      = "aurora-mysql"
  database_name               = var.rds_database_name
  master_username             = var.rds_master_username
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.rds.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.common.arn
  skip_final_snapshot         = true

  tags = {
    Name = "${var.name}-aurora-mysql"
  }
}

resource "aws_rds_cluster_instance" "writer" {
  identifier           = "${var.name}-aurora-writer"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = var.rds_instance_class
  engine               = aws_rds_cluster.aurora.engine
  db_subnet_group_name = aws_db_subnet_group.rds.name
  availability_zone    = data.aws_availability_zones.available.names[0]
}

resource "aws_rds_cluster_instance" "reader" {
  identifier           = "${var.name}-aurora-reader"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = var.rds_instance_class
  engine               = aws_rds_cluster.aurora.engine
  db_subnet_group_name = aws_db_subnet_group.rds.name
  availability_zone    = data.aws_availability_zones.available.names[1]
  promotion_tier       = 1
}
