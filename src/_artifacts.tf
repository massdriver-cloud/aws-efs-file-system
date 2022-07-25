resource "massdriver_artifact" "file_system" {
  field                = "file_system"
  provider_resource_id = aws_efs_file_system.main.arn
  name                 = "AWS EFS File System: ${aws_efs_file_system.main.arn}"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          arn      = aws_efs_file_system.main.arn,
          dns_name = aws_efs_file_system.main.dns_name
        }
        security = {}
      }
      specs = {
        aws = {
          region = var.vpc.specs.aws.region
        }
      }
    }
  )
}
