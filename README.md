# An Opinionated Terraform Module to deploy ECR Repositories

A Terraform Module to be used for deploying ECR Repositories with the following design goals:

- Selected AWS Accounts can pull from repository
- The ability to provide a custom ECR Resource Policy
- Aggressive by default lifecycle policy:
    - 1 x Untagged image allowed
    - 10 x Tagged images allowed

Opinionated in that this is designed primarily for publishing Docker images into a central or shared AWS account, from which they are to be consumed via `docker pull` in other AWS Accounts.

## Usage

### Minimal example (no Cross Account sharing)

```terraform
module "example" {
  source = "git@github.com:harrison-ai/harrison-terraform-module-ecr.git"

  name = "example"
}
```

### Complete Example with Cross Account Sharing

```terraform
module "example" {
  source = "git@github.com:harrison-ai/harrison-terraform-module-ecr.git"

  name                    = "example"
  account_ids             = ["012345678912"]
  tagged_images_to_keep   = 30
  untagged_images_to_keep = 3
}
```

### Override Default Policy with User Supplied Policy

```terraform
module "example" {
  source = "git@github.com:harrison-ai/harrison-terraform-module-ecr.git"

  name            = "example"
  override_policy = true
  policy          = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "01"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    principals {
      type        = "AWS"
      identifiers = ["012345678912"]
    }
  }
}
```
