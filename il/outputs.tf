output "vpc_id" {
  value = aws_vpc.this.id
}

output "asg_name" {
  value = aws_autoscaling_group.backend.name
}

output "rds_cluster_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}

output "api_gateway_endpoint" {
  value = aws_api_gateway_stage.services.invoke_url
}

output "documents_bucket" {
  value = aws_s3_bucket.documents.id
}

output "common_kms_key_arn" {
  value = aws_kms_key.common.arn
}
