resource "aws_s3_bucket" "extracted_files" {
  bucket = "${local.bucket_prefix}-extracted-files"

  tags = {
    Name = "${var.name}-extracted-files"
  }
}

resource "aws_s3_bucket" "glue_scripts" {
  bucket = "${local.bucket_prefix}-glue-scripts"

  tags = {
    Name = "${var.name}-glue-scripts"
  }
}

resource "aws_s3_bucket" "financial_reports" {
  bucket = "${local.bucket_prefix}-financial-reports"

  tags = {
    Name = "${var.name}-financial-reports"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = {
    extracted_files   = aws_s3_bucket.extracted_files.id
    glue_scripts      = aws_s3_bucket.glue_scripts.id
    financial_reports = aws_s3_bucket.financial_reports.id
  }

  bucket = each.value

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = {
    extracted_files   = aws_s3_bucket.extracted_files.id
    glue_scripts      = aws_s3_bucket.glue_scripts.id
    financial_reports = aws_s3_bucket.financial_reports.id
  }

  bucket = each.value

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.common.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = {
    extracted_files   = aws_s3_bucket.extracted_files.id
    glue_scripts      = aws_s3_bucket.glue_scripts.id
    financial_reports = aws_s3_bucket.financial_reports.id
  }

  bucket                  = each.value
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
