# How To Build AWS Multi-Account Structure With Terraform

![GitHub license](https://img.shields.io/badge/license-MIT-informational)
![GitHub version](https://img.shields.io/badge/terraform-v0.13.5-success)
![GitHub version](https://img.shields.io/badge/terraform%20vpc%20module-~%3E%202.64-success)
![GitHub version](https://img.shields.io/badge/terraform%20ec2--instance%20module-~%3E%202.15-success)
![GitHub version](https://img.shields.io/badge/local__machine__OS-OSX-blue)

This repo builds an admin user in your AWS account, enabling the possibility to assume roles and custom managed policies association.

That's the basis to further develop a production-grade multi-account scenario.

## Ensure proper permissions to your programmatic AWS User

Set the user with programmatic access you created to set-up Terraform and initialize AWS CLI is associated with the 'AdministratorAccess' group. 

## Create Top Admin IAM User and Grant Permissions

Cd into the folder `create-top-admin-iam-user`

#### Create PGP Key to encrypt the IAM USer Access Key

Install GPG with `brew install gnupg` or update it with `brew upgrade gnupg`.

Create your [PGP Key](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/generating-a-new-gpg-key) to ensure that the user access key and password are encrypted in the terraform state. 

You need an RSA 4096 key. Add your username and email.

After creation, launch the command `gpg --list-secret-keys --keyid-format LONG`, to check your newly created key.

Now enter `gpg --export "your_username" | base64` to convert your public key to base64 format.

Now you can add the output to the string into the `main.tf` file.

If you prefer using keybase](keybase.io), you can create a txt file with your just exported key and upload it into your `public/your_username` path and reference the pgp_key in `main.tf` as `keybase:your_username`.

#### Grant Administrator permission in the Account

By using submodules [iam-group-with-assumable-roles-policy](https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-group-with-assumable-roles-policy) and [iam-group-with-policies](https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-group-with-policies) we create the "admin group" and associate the iam user.

The newly created IAM user is allowed to assume an admin role in the current AWS account. This is the basis to manage multi-accounts scenarios, where for instance this user could be granted admin access in a development account. 

Also, a custom [AWS managed policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html#aws-managed-policies) regarding Full S3 Access is added.

#### Create Your User and Permissions

Launch the following commands:

- `terraform init`
- `terraform plan`
- `terraform apply` and enter yes when required (or use the `-auto-approve` option).

## Manual Tests 

To manually check that your desired configuration has been properly set-up, you should login to your AWS console by using the newly create IAM User, as the user has been given console access (by setting `create_iam_user_login_profile = true`). 

You need:

- the userID, which can be found as output information in `this_iam_user_arn`
- the user name, which is defined in `main.tf`, as well as displayed as output
- the password, which can be got by running the command displayed as output: `keybase_password_decrypt_command`.
- to open IAM services and check that the admin group is created and the user is associated with it
- to check permissions and check that "admins" and "AmazonFullS3Access" are listed.

## Destroy Your Configuration

After successfully testing, you can logout and destroy your configuration, by launching `terraform destroy` entering yes when required or using the `-auto-approve` option.

## Documentation

The code contained in this repo was built upon the following documentation:

- [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Identity and Access Management (IAM) Terraform module and submodules](https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest) and [examples](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/examples). 
- [Modules code](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules). 

## Authors

This repository is maintained by [ApprenticeCTO](https://github.com/apprenticecto) with great help from [Terraform AWS Documentation](https://learn.hashicorp.com/collections/terraform/aws-get-started).

## License

MIT Licensed. See LICENSE for full details.


