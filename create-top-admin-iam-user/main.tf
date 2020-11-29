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

#########################################
# IAM user, login profile and access key
#########################################
module "iam_user_login_access_key" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "3.4.0"

  name          = "iam_user_top_admin"
  force_destroy = true

  create_iam_user_login_profile = true

  pgp_key = "keybase:apprenticecto"

  password_reset_required = false

  # SSH public key
  upload_iam_user_ssh_key = false

  ssh_public_key = ""
}

#############################################################################################
# IAM group where IAM user is allowed to assume admin role in current AWS account
#############################################################################################

data "aws_caller_identity" "current" {}

module "iam_group_complete" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "3.4.0"

  name = "admins"

  assumable_roles = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin"]
 

  group_users = [
    module.iam_user_login_access_key.this_iam_user_name,
  ]
}

####################################################
# Extending policies of IAM group admins
####################################################
module "iam_group_complete_with_custom_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "3.4.0"

  name = module.iam_group_complete.group_name

  create_group = false

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}