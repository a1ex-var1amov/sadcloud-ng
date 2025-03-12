resource "aws_ebs_volume" "main" {
  availability_zone = "us-east-1a"
  size              = 1
  encrypted = !var.ebs_volume_unencrypted

  count = var.ebs_volume_unencrypted || var.ebs_snapshot_unencrypted ? 1 : 0
}

resource "aws_ebs_encryption_by_default" "main" {
  count = var.ebs_default_encryption_disabled ? 1 : 0

  enabled = false  # Dangerous: Disables encryption by default for all new EBS volumes
}

resource "aws_ebs_snapshot" "main_snapshot" {
  volume_id = aws_ebs_volume.main[0].id

  count = var.ebs_snapshot_unencrypted ? 1 : 0
}

# Unencrypted EBS volume
resource "aws_ebs_volume" "unencrypted" {
  count = var.ebs_volume_unencrypted ? 1 : 0

  availability_zone = var.availability_zone
  size             = 10
  encrypted        = false  # Dangerous: Explicitly disabled encryption
  
  tags = {
    Name = "${var.name}-unencrypted"
  }
}

# Oversized volume with gp2 type
resource "aws_ebs_volume" "oversized" {
  count = var.create_oversized_volume ? 1 : 0

  availability_zone = var.availability_zone
  size             = 1000  # Dangerous: Unnecessarily large volume
  type             = var.create_gp2_volume ? "gp2" : "gp3"  # Dangerous: Using older gp2 type
  encrypted        = true
  
  tags = {
    Name = "${var.name}-oversized"
  }
}

# Volume with misconfigured IOPS
resource "aws_ebs_volume" "misconfigured_iops" {
  count = var.create_misconfigured_iops ? 1 : 0

  availability_zone = var.availability_zone
  size             = 100
  type             = "io2"
  iops             = 100000  # Dangerous: Excessive IOPS
  encrypted        = true
  
  tags = {
    Name = "${var.name}-misconfigured-iops"
  }
}

# Volume without delete on termination
resource "aws_ebs_volume" "no_delete" {
  count = var.disable_delete_on_termination ? 1 : 0

  availability_zone = var.availability_zone
  size             = 10
  encrypted        = true
  
  tags = {
    Name = "${var.name}-no-delete"
  }

  lifecycle {
    prevent_destroy = true  # Dangerous: Prevents volume deletion
  }
}

# Unused volume
resource "aws_ebs_volume" "unused" {
  count = var.create_unused_volume ? 1 : 0

  availability_zone = var.availability_zone
  size             = 20
  encrypted        = true
  
  tags = {
    Name = "${var.name}-unused"
  }
  # Dangerous: No attachment to any EC2 instance
}

# Untagged volume
resource "aws_ebs_volume" "untagged" {
  count = var.create_untagged_volume ? 1 : 0

  availability_zone = var.availability_zone
  size             = 10
  encrypted        = true
  # Dangerous: No tags for resource tracking
}

# Volume without backup
resource "aws_ebs_volume" "no_backup" {
  count = var.create_volume_without_backup ? 1 : 0

  availability_zone = var.availability_zone
  size             = 10
  encrypted        = true
  
  tags = {
    Name = "${var.name}-no-backup"
    Backup = "false"  # Dangerous: Explicitly disabled backups
  }
}

# Unencrypted snapshot
resource "aws_ebs_snapshot" "unencrypted" {
  count = var.ebs_snapshot_unencrypted ? 1 : 0

  volume_id = aws_ebs_volume.unencrypted[0].id
  
  tags = {
    Name = "${var.name}-unencrypted-snapshot"
  }
}

# Public snapshot
resource "aws_ebs_snapshot" "public" {
  count = var.create_public_snapshot ? 1 : 0

  volume_id = var.ebs_volume_unencrypted ? aws_ebs_volume.unencrypted[0].id : aws_ebs_volume.no_backup[0].id
  
  tags = {
    Name = "${var.name}-public-snapshot"
  }
}

# Make snapshot public
resource "aws_snapshot_create_volume_permission" "public" {
  count = var.create_public_snapshot ? 1 : 0

  snapshot_id = aws_ebs_snapshot.public[0].id
  account_id  = "all"  # Dangerous: Makes snapshot public to all AWS accounts
}
