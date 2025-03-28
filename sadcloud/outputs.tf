output "created_resources" {
  description = "List of all created resources"
  value = {
    "Network Resources" = {
      "VPC" = module.network.vpc_id
      "Subnets" = {
        "Main" = module.network.main_subnet_id
        "Secondary" = module.network.secondary_subnet_id
      }
    }
    "Compute Resources" = {
      "EKS Cluster" = try(module.eks.cluster_name, null)
      "RDS Instance" = try(module.rds.db_instance_id, null)
    }
    "Storage Resources" = {
      "EBS Volumes" = try(module.ebs.volume_ids, null)
      "Glacier Vaults" = try(module.glacier.vault_names, null)
    }
    "Container Resources" = {
      "ECR Repositories" = try(module.ecr.repository_names, null)
    }
    "Messaging Resources" = {
      "SNS Topics" = try(module.sns.topic_arns, null)
      "SQS Queues" = try(module.sqs.queue_urls, null)
    }
    "Monitoring Resources" = {
      "CloudWatch Alarms" = try(module.cloudwatch.alarm_names, null)
      "CloudTrail Trails" = try(module.cloudtrail.trail_names, null)
    }
    "Security Resources" = {
      "KMS Keys" = try(module.kms.key_ids, null)
    }
    "Email Resources" = {
      "SES Identities" = try(module.ses.identity_names, null)
    }
  }
}

output "enabled_modules" {
  description = "List of enabled modules and their status"
  value = {
    "Network" = {
      "enabled" = true
      "description" = "VPC, Subnets, Internet Gateway"
    }
    "EC2" = {
      "enabled" = var.all_ec2_findings || var.all_findings
      "description" = "EC2 instances with t3.large"
    }
    "RDS" = {
      "enabled" = var.all_rds_findings || var.all_findings
      "description" = "MySQL database with db.t3.large"
    }
    "EKS" = {
      "enabled" = var.all_eks_findings || var.all_findings
      "description" = "Kubernetes cluster"
    }
    "S3" = {
      "enabled" = var.all_s3_findings || var.all_findings
      "description" = "Storage buckets"
    }
    "CloudWatch" = {
      "enabled" = var.all_cloudwatch_findings || var.all_findings
      "description" = "Monitoring and alarms"
    }
    "CloudTrail" = {
      "enabled" = var.all_cloudtrail_findings || var.all_findings
      "description" = "Activity logging"
    }
    "EBS" = {
      "enabled" = var.all_ebs_findings || var.all_findings
      "description" = "Block storage volumes"
    }
    "ECR" = {
      "enabled" = var.all_ecr_findings || var.all_findings
      "description" = "Container registry"
    }
    "Glacier" = {
      "enabled" = var.all_glacier_findings || var.all_findings
      "description" = "Long-term storage"
    }
    "KMS" = {
      "enabled" = var.all_kms_findings || var.all_findings
      "description" = "Key management"
    }
    "SES" = {
      "enabled" = var.all_ses_findings || var.all_findings
      "description" = "Email service"
    }
    "SNS" = {
      "enabled" = var.all_sns_findings || var.all_findings
      "description" = "Notification service"
    }
    "SQS" = {
      "enabled" = var.all_sqs_findings || var.all_findings
      "description" = "Message queue service"
    }
    "Config" = {
      "enabled" = var.all_config_findings || var.all_findings
      "description" = "Configuration recorder"
    }
    "Redshift" = {
      "enabled" = var.all_redshift_findings || var.all_findings
      "description" = "Data warehouse"
    }
    "IAM" = {
      "enabled" = var.all_iam_findings || var.all_findings
      "description" = "Identity and access management"
    }
  }
} 