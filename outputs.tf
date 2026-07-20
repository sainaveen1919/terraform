output "il_vpc_id" {
  value = module.il.vpc_id
}

output "il_asg_name" {
  value = module.il.asg_name
}

output "il_rds_cluster_endpoint" {
  value = module.il.rds_cluster_endpoint
}

output "il_eks_cluster_name" {
  value = module.il.eks_cluster_name
}

output "il_api_gateway_endpoint" {
  value = module.il.api_gateway_endpoint
}

output "il_documents_bucket" {
  value = module.il.documents_bucket
}

output "dwh_vpc_id" {
  value = module.dwh.vpc_id
}

output "dwh_asg_name" {
  value = module.dwh.asg_name
}

output "dwh_redshift_endpoint" {
  value = module.dwh.redshift_endpoint
}

output "dwh_extraction_state_machine_arn" {
  value = module.dwh.extraction_state_machine_arn
}

output "dwh_loading_state_machine_arn" {
  value = module.dwh.loading_state_machine_arn
}

output "dwh_extracted_files_bucket" {
  value = module.dwh.extracted_files_bucket
}

output "dwh_glue_scripts_bucket" {
  value = module.dwh.glue_scripts_bucket
}

output "dwh_financial_reports_bucket" {
  value = module.dwh.financial_reports_bucket
}
