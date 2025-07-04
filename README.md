# An Opinionated Terraform Module to deploy ECR Repositories

A Terraform Module to be used for deploying ECR Repositories with the following design goals:

- Allow Lambda or EKS from selected AWS Accounts to pull from repository.
- The ability to provide a custom ECR Resource Policy.
- Aggressive by default lifecycle policy:
    - 1 x Untagged image allowed.
    - 10 x Tagged images allowed.

Opinionated in that this is designed primarily for publishing Docker images into a central or shared AWS account, from which they are to be consumed via EKS or Lambda functions in other AWS Accounts.

## Usage

### Minimal example (no Cross Account sharing)

```terraform
module "example" {
  source = "github.com/harrison-ai/harrison-terraform-module-ecr?ref=0.1.3"

  name = "example"
}
```

### Complete Example with Cross Account Sharing

```terraform
module "example" {
  source = "github.com/harrison-ai/harrison-terraform-module-ecr?ref=0.1.3"

  name                    = random_pet.this.id
  account_ids             = ["012345678912", "001122334455"]
  cross_account_service   = "EKS"
  tagged_images_to_keep   = 30
  untagged_images_to_keep = 3
}
```

### Override lifecycle or repository policy

Both the lifecycle policy and repository policy can be overriden with custom user supplied policies.  Please see `examples/user-supplied-policies` for a complete example


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_ecr_repository_policy.override](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks_cross_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_cross_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | List of AWS Account ID's that will be granted access to the repository | `list(string)` | `[]` | no |
| <a name="input_cross_account_service"></a> [cross\_account\_service](#input\_cross\_account\_service) | The service for which to configure cross account pull permissions on the repo.  Valid options are EKS or Lambda | `string` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | A lifecycle policy to override the default policy | `map(any)` | `null` | no |
| <a name="input_mutable_tags"></a> [mutable\_tags](#input\_mutable\_tags) | Boolean setting for repository tag mutability | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECR Repository | `string` | n/a | yes |
| <a name="input_override_lifecycle_policy"></a> [override\_lifecycle\_policy](#input\_override\_lifecycle\_policy) | Boolean setting to override the default lifecycle policy | `bool` | `false` | no |
| <a name="input_override_policy"></a> [override\_policy](#input\_override\_policy) | Boolean setting to override the default policy | `bool` | `false` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A json encoded policy to override the default policy | `string` | `null` | no |
| <a name="input_tagged_images_to_keep"></a> [tagged\_images\_to\_keep](#input\_tagged\_images\_to\_keep) | Number of tagged images to keep | `number` | `5` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_untagged_images_to_keep"></a> [untagged\_images\_to\_keep](#input\_untagged\_images\_to\_keep) | Number of untagged images to keep | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ECR Repository ARN |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | ECR Repository URL |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
