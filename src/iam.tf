data "aws_iam_policy_document" "read" {
  statement {
    sid    = "Read"
    effect = "Allow"
    resources = [
      aws_efs_file_system.main.arn
    ]
    actions = [
      "elasticfilesystem:ClientMount"
    ]
  }
}

data "aws_iam_policy_document" "read_write" {
  statement {
    sid    = "ReadWrite"
    effect = "Allow"
    resources = [
      aws_efs_file_system.main.arn
    ]
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
  }
}

data "aws_iam_policy_document" "root" {
  statement {
    sid    = "Root"
    effect = "Allow"
    resources = [
      aws_efs_file_system.main.arn
    ]
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite"
    ]
  }
}

resource "aws_iam_policy" "read" {
  name        = "${var.md_metadata.name_prefix}-read"
  description = " EFS read policy: ${var.md_metadata.name_prefix}"

  policy = data.aws_iam_policy_document.read.json
}

resource "aws_iam_policy" "read_write" {
  name        = "${var.md_metadata.name_prefix}-read-write"
  description = "EFS read/write policy: ${var.md_metadata.name_prefix}"

  policy = data.aws_iam_policy_document.read_write.json
}

resource "aws_iam_policy" "root" {
  name        = "${var.md_metadata.name_prefix}-root"
  description = "EFS root access policy: ${var.md_metadata.name_prefix}"

  policy = data.aws_iam_policy_document.root.json
}
