# How To Manage Assumable Roles in AWS with Terraform

![GitHub license](https://img.shields.io/badge/license-MIT-informational)
![GitHub version](https://img.shields.io/badge/terraform-v0.13.5-success)
![GitHub version](https://img.shields.io/badge/terraform%20vpc%20module-~%3E%202.64-success)
![GitHub version](https://img.shields.io/badge/terraform%20ec2--instance%20module-~%3E%202.15-success)
![GitHub version](https://img.shields.io/badge/local__machine__OS-OSX-blue)

## Setting-Up Your Environment in AWS

Check my [repo](https://github.com/apprenticecto/create-aws-ec2-with-terraform), which illustrates how to set-up [Terraform](https://www.terraform.io/) and [AWS CLI](https://aws.amazon.com/cli/) in order to provision infrastructure on AWS using Terraform.

This repo leverages my [create-aws-ec2-with-terraform repo](https://github.com/apprenticecto/create-aws-ec2-with-terraform) to set-up a basic ec2 instance, included in the free-tier program.

## Create IAM Assumable Role, Group and User and Manage Permissions
This repo builds:

- an IAM role `ec2_read` with an attached [ec2 instances reading policy](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-policies-ec2-console.html)
- an IAM group `admins` with a specific S3 policy and the capability to assume the role `ec2_read` for its members
- an IAM user `ec2_read` belonging to the `admins` group, and the only trusted role `ec2_read` arn.

#### Clone the Repo

You can clone this repo and cd into the folder `manage-assumable-roles-terraform`.

#### Create PGP Key to encrypt the IAM USer Access Key

Install GPG with `brew install gnupg` or update it with `brew upgrade gnupg`.

Create your [PGP Key](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/generating-a-new-gpg-key) to ensure that the user access key and password are encrypted in the terraform state. 

You need an RSA 4096 key. Add your username and email.

After creation, launch the command `gpg --list-secret-keys --keyid-format LONG`, to check your newly created key.

Now enter `gpg --export "your_username" | base64` to convert your public key to base64 format.

Now you can add the output to the string into the `main.tf` file.

If you prefer using [keybase](keybase.io), you can create a txt file with your just exported key and upload it into your `public/your_username` path and reference the pgp_key in `main.tf` as `keybase:your_username`.

#### Let's Build

Launch the following commands:

- `terraform init`
- `terraform plan`
- `terraform apply` and enter yes when required (or use the `-auto-approve` option).

## Sign-in With Our Added User

To login with the `iam_user_ec2_reader` user to the console (the user has been given console access by setting `create_iam_user_login_profile = true`), you need:

- the userID, which can is part of the output information in `this_iam_user_arn`
- the user name, which is defined in `main.tf`, as well as displayed as output
The password can be obtained by running the command shown as output: `keybase_password_decrypt_command`.

You can check in the IAM service that everything is set-up as expected.

Please note that you cannot access your ec2 instance information through the EC2 service.

Now you can select `switch role` from your account menu. You'll need to enter the following information:
- your account ID
- name of the role you want to assume with this user (´eks_cluster_mgmt´)
- a color to highlight your role.
 
After completion, you should be able to access your ec2 instance information (you'll see only a part of them, as this depends on the permissions which are set in the code). 

## Destroy Your Configuration

After successfully testing, you can logout and destroy your configuration by launching `terraform destroy` entering yes when required or using the `-auto-approve` option.

## Final Considerations

This setting is managed within the same AWS account, but the same approach can be applied to assume roles in different accounts, a common use case for production-ready scenarios. 

## Documentation

The code contained in this repo was built upon the following documentation:

- [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Security Blog - How to use trust policies with IAM roles](https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/)
- [AWS Identity and Access Management (IAM) Terraform module and submodules](https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest) and [examples](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/examples). 
- [Modules code](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules). 

## Authors

This repository is maintained by [ApprenticeCTO](https://github.com/apprenticecto).

## License

MIT Licensed. See LICENSE for full details.


