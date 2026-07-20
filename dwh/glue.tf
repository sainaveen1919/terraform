resource "aws_iam_role" "glue" {
  name = "${var.name}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_data" {
  name = "${var.name}-glue-data-policy"
  role = aws_iam_role.glue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.extracted_files.arn,
          "${aws_s3_bucket.extracted_files.arn}/*",
          aws_s3_bucket.glue_scripts.arn,
          "${aws_s3_bucket.glue_scripts.arn}/*",
          aws_s3_bucket.financial_reports.arn,
          "${aws_s3_bucket.financial_reports.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.common.arn
      }
    ]
  })
}

resource "aws_glue_job" "extraction" {
  name     = "${var.name}-extraction-job"
  role_arn = aws_iam_role.glue.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.glue_scripts.id}/scripts/extraction.py"
  }

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  default_arguments = {
    "--TempDir"             = "s3://${aws_s3_bucket.extracted_files.id}/tmp/"
    "--job-language"        = "python"
    "--enable-metrics"      = "true"
    "--enable-continuous-cloudwatch-log" = "true"
  }
}

resource "aws_glue_job" "loading" {
  name     = "${var.name}-loading-job"
  role_arn = aws_iam_role.glue.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.glue_scripts.id}/scripts/loading.py"
  }

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  default_arguments = {
    "--TempDir"             = "s3://${aws_s3_bucket.extracted_files.id}/tmp/"
    "--job-language"        = "python"
    "--enable-metrics"      = "true"
    "--enable-continuous-cloudwatch-log" = "true"
  }
}

resource "aws_glue_catalog_database" "extraction" {
  name = "${var.name}_extraction"
}

resource "aws_glue_crawler" "extraction_files" {
  name          = "${var.name}-extraction-files-crawler"
  database_name = aws_glue_catalog_database.extraction.name
  role          = aws_iam_role.glue.arn

  s3_target {
    path = "s3://${aws_s3_bucket.extracted_files.id}/"
  }
}
