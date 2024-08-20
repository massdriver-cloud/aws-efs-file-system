## AWS Elastic File System (EFS)

Amazon Elastic File System (EFS) provides scalable file storage for use with Amazon EC2. It's easy to use, allowing you to create and configure file systems quickly and simply. With EFS, data is stored across multiple Availability Zones (AZs) and it can grow or shrink automatically as you add or remove files. It is ideal for workloads that require a high level of durability and availability.

### Design Decisions

- **Encrypted Storage**: The EFS is encrypted using an AWS KMS key to ensure data at rest is secure.
  
- **Lifecycle Policies**: Lifecycle policies are configured to transition files that haven't been accessed for a certain period to Infrequent Access (IA) storage, reducing storage costs.
  
- **Backup Policy**: AWS backup policy is enabled based on variable settings, facilitating automated backups.
  
- **Mount Targets**: EFS mount targets are created in each subnet to ensure availability and accessibility from different subnets within the VPC.
  
- **Security Group Rules**: The security group allows NFS traffic from the VPC, ensuring only authorized VPC traffic can access the EFS.

### Runbook

#### Unable to Mount EFS

Having trouble mounting the EFS file system to an EC2 instance?

Verify the EFS mount target

```sh
aws efs describe-mount-targets --file-system-id <file-system-id>
```

Check for the mount target existence and its lifecycle state. Ensure it is in the "available" state.

Mount the EFS file system manually

```sh
sudo mount -t nfs4 -o nfsvers=4.1 <file-system-dns-name>:/ <mount-point>
```

Ensure that the mount command returns without errors. If any errors occur, confirm that the `<file-system-dns-name>` is correct and accessible.

#### EFS Access Denied

Running into access denied errors while accessing the EFS from your EC2 instance?

Verify EFS IAM Policy

```sh
aws efs describe-file-systems --file-system-id <file-system-id>
```

Ensure that the appropriate IAM policies have been applied and the EC2 instance has the necessary permissions.

#### Insufficient Throughput

Are you experiencing insufficient throughput for your EFS file system?

Check throughput mode

```sh
aws efs describe-file-systems --file-system-id <file-system-id>
```

Review the `throughputMode` parameter. If it’s set to "provisioned", ensure `ProvisionedThroughputInMibps` is set appropriately to meet your needs. Adjust if necessary.

#### NFS Port Unreachable

Unable to reach the NFS port (2049) on your EFS mount target?

Update Security Group Rules

```sh
aws ec2 describe-security-groups --group-ids <security-group-id>
```

Confirm that the security group associated with the mount target allows inbound traffic on port 2049 from your EC2 instances.

#### Backup Issues

Backups not being created as expected?

Verify Backup Policy

```sh
aws efs describe-backup-policy --file-system-id <file-system-id>
```

Check the status of the backup policy for your EFS file system. Ensure that `"Status": "ENABLED"` is present in the policy output.

#### Data Not Transitioning to Infrequent Access

Lifecycle policies not transitioning data to Infrequent Access?

Review Lifecycle Policies

```sh
aws efs describe-lifecycle-configuration --file-system-id <file-system-id>
```

Ensure that the lifecycle configuration contains appropriate lifecycle policies, and verify the `TransitionToInfrequentAccess` setting.

