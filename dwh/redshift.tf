resource "random_password" "redshift" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_redshift_subnet_group" "this" {
  name       = "${var.name}-redshift-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.name}-redshift-subnet-group"
  }
}

resource "aws_iam_role" "redshift" {
  name = "${var.name}-redshift-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "redshift_s3" {
  name = "${var.name}-redshift-s3-policy"
  role = aws_iam_role.redshift.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.extracted_files.arn,
          "${aws_s3_bucket.extracted_files.arn}/*",
          aws_s3_bucket.financial_reports.arn,
          "${aws_s3_bucket.financial_reports.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.common.arn
      }
    ]
  })
}

resource "aws_redshift_cluster" "this" {
  cluster_identifier        = "${var.name}-redshift"
  database_name             = var.redshift_database_name
  master_username           = var.redshift_master_username
  master_password           = random_password.redshift.result
  node_type                 = var.redshift_node_type
  cluster_type              = "single-node"
  encrypted                 = true
  kms_key_id                = aws_kms_key.common.arn
  cluster_subnet_group_name = aws_redshift_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.redshift.id]
  iam_roles                 = [aws_iam_role.redshift.arn]
  skip_final_snapshot       = true

  tags = {
    Name = "${var.name}-redshift"
  }
}
