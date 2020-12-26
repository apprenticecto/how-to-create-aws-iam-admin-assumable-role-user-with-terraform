terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# IAM user, login profile and access key
module "iam_user_login_access_key" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "3.4.0"

  name          = "iam_user_ec2_reader"
  force_destroy = true

  create_iam_user_login_profile = true

  pgp_key = "keybase:apprenticecto"

  password_reset_required = false

  # SSH public key
  upload_iam_user_ssh_key = false

  ssh_public_key = ""
}


# IAM group where IAM user is allowed to assume admin role in current AWS account
data "aws_caller_identity" "current" {}

module "iam_group_complete" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "3.4.0"

  name = "admins"

  assumable_roles = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2_read"]
 
  group_users = [
    module.iam_user_login_access_key.this_iam_user_name,
  ]
}

# Extending policies of IAM group admins
module "iam_group_complete_with_custom_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "3.4.0"

  name = module.iam_group_complete.group_name

  create_group = false

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}

# IAM assumable role with custom policies
module "iam_assumable_role_custom" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${module.iam_user_login_access_key.this_iam_user_name}",
  ]

  create_role = true

  role_name         = "ec2_read"
  role_requires_mfa = false

  custom_role_policy_arns = [
    module.iam_policy.arn
  ]
}

# IAM policy
module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "ec2_reading_policy"
  path        = "/"
  description = "ec2_reading_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Build EC2
variable "ami" {
  default = "ami-0c960b947cbb2dd16"
}

variable "instance_type" {
  default = "t2.micro"
}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
}