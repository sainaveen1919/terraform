output "vpc_id" {
  value = aws_vpc.this.id
}

output "asg_name" {
  value = aws_autoscaling_group.linux.name
}

output "redshift_endpoint" {
  value = aws_redshift_cluster.this.endpoint
}

output "extraction_state_machine_arn" {
  value = aws_sfn_state_machine.extraction.arn
}

output "loading_state_machine_arn" {
  value = aws_sfn_state_machine.loading.arn
}

output "extracted_files_bucket" {
  value = aws_s3_bucket.extracted_files.id
}

output "glue_scripts_bucket" {
  value = aws_s3_bucket.glue_scripts.id
}

output "financial_reports_bucket" {
  value = aws_s3_bucket.financial_reports.id
}

output "common_kms_key_arn" {
  value = aws_kms_key.common.arn
}
