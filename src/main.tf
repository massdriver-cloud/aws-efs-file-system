
locals {
  create_lifecycle = var.retention.transition_to_ia != "DISABLED"
}

resource "aws_efs_file_system" "main" {
  creation_token = var.md_metadata.name_prefix
  encrypted      = true
  kms_key_id     = module.kms.key_arn

  // specifying this block twice due to bug: https://github.com/hashicorp/terraform-provider-aws/issues/21862
  dynamic "lifecycle_policy" {
    for_each = local.create_lifecycle ? [1] : []
    content {
      transition_to_ia = var.retention.transition_to_ia
    }
  }
  dynamic "lifecycle_policy" {
    for_each = local.create_lifecycle ? [1] : []
    content {
      // hardcoding to the only available value (as of 7/22/2022)
      transition_to_primary_storage_class = "AFTER_1_ACCESS"
    }
  }

  performance_mode = var.storage.performance_mode

  throughput_mode                 = var.storage.throughput_mode
  provisioned_throughput_in_mibps = var.storage.throughput_mode == "provisioned" ? var.storage.provisioned_throughput_in_mibps : 0
}

resource "aws_efs_backup_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  backup_policy {
    status = var.retention.backup ? "ENABLED" : "DISABLED"
  }
}