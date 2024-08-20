## AWS EFS (Elastic File System)

AWS EFS (Elastic File System) is a scalable file storage system used with AWS cloud services and on-premises resources. It is designed to provide a simple, scalable, and elastic file system for Linux-based workloads for use with AWS Cloud services and on-premises resources. With EFS, users can create and configure file systems quickly, and automatically scale storage capacity and throughput as needed.

### Design Decisions

1. **Encryption at Rest**: The file system is configured with encryption enabled using a KMS key.
2. **Lifecycle Policies**: If configured, the file system transitions files to Infrequent Access (IA) storage class after a specified period of inactivity.
3. **IAM Policies**: The module creates three IAM policies to support different levels of access (read, read/write, root) to the EFS file system.
4. **Backup Policy**: Based on configuration, EFS backups can be enabled or disabled.
5. **Mount Targets**: Creates mount targets in specified subnets to ensure accessibility.
6. **Security Group**: A security group is created to control traffic to and from the EFS.

### Runbook

#### EFS Mount Issue

If you are experiencing issues with mounting the EFS file system, check the mount targets and security groups.

```sh
aws efs describe-mount-targets --file-system-id <file-system-id>
```
This command lists the mount targets and verifies their status.

Check security group rules to ensure the correct ports are open.

```sh
aws ec2 describe-security-groups --group-ids <security-group-id>
```
This command provides details about the security group rules.

#### Checking File System Health

To check the health status of your EFS file system.

```sh
aws efs describe-file-systems --file-system-id <file-system-id>
```

This command gives you the status of the file system which should be `available`.

#### EFS IAM Policy Issues

If there are access issues, verify the policies attached to the IAM roles or users.

```sh
aws iam list-attached-user-policies --user-name <user-name>
```
This command lists policies attached to a user.

```sh
aws iam list-attached-role-policies --role-name <role-name>
```
This command lists policies attached to a role.

#### Insufficient Throughput

If file operations are slower than expected, your EFS might not have sufficient throughput.

```sh
aws efs describe-file-systems --file-system-id <file-system-id>
```
Check the `throughput-mode` and ensure it's configured to either bursting or provisioned as needed.

#### Backup Verification

To verify the backup policy for the EFS file system.

```sh
aws efs describe-backup-policy --file-system-id <file-system-id>
```
This command shows the backup configuration, ensuring it is either `ENABLED` or `DISABLED`.

#### Network Configuration Issues

For network-related issues, ensure your VPC and subnets are properly configured.

```sh
aws ec2 describe-vpcs --vpc-ids <vpc-id>
```

This command checks your VPC configuration.

```sh
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"
```

This command provides details about subnets within your VPC, ensuring correct configuration and CIDR blocks.

