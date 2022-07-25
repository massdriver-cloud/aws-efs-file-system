
locals {
  vpc_id           = element(split("/", var.vpc.data.infrastructure.arn), 1)
  subnet_ids       = [for subnet in var.vpc.data.infrastructure.internal_subnets : element(split("/", subnet["arn"]), 1)]
  create_lifecycle = var.retention.transition_to_ia != "DISABLED"
  nfs_port         = 2049
  nfs_protocol     = "TCP"
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

  tags = {
    "Name" = var.md_metadata.name_prefix
  }
}

resource "aws_efs_backup_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  backup_policy {
    status = var.retention.backup ? "ENABLED" : "DISABLED"
  }
}

resource "aws_efs_mount_target" "main" {
  for_each        = toset(local.subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.key
  security_groups = [aws_security_group.mount.id]
}

resource "aws_security_group" "mount" {
  vpc_id      = local.vpc_id
  name        = var.md_metadata.name_prefix
  description = "Control traffic to/from EFS ${var.md_metadata.name_prefix}"
}

resource "aws_security_group_rule" "vpc_ingress" {
  count = 1

  description = "Allow VPC"

  type        = "ingress"
  from_port   = local.nfs_port
  to_port     = local.nfs_port
  protocol    = local.nfs_protocol
  cidr_blocks = [var.vpc.data.infrastructure.cidr]

  security_group_id = aws_security_group.mount.id
}
