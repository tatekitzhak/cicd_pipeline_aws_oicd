# IAM instance profile for SSM so the CD job can run SSM SendCommand on this instance.

locals {
  # Generates a timestamp like: 2026-02-23T14:30:05Z
  raw_time = timestamp()
  
  # Formats to: 20260223143005 (no special characters)
  formatted_time = formatdate("YYYYMMDDHHmmss", local.raw_time)
}

resource "aws_iam_role" "ec2_ssm" {
  name        = "ec2-ssm-role-${local.formatted_time }" # Example: CreatedDate = "20260223143005"
  description = "Role for EC2 so GitHub Actions CD can run SSM SendCommand"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ec2-ssm-role-${local.formatted_time }" # Example: CreatedDate = "20260223143005"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_managed" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm.name
}
