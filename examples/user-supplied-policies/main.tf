# override default lifecycle policy and repository policy with user supplied policies

locals {

  untagged_policy = {
    rulePriority = 1
    description  = "Expire untagged Images"
    selection = {
      tagStatus   = "untagged"
      countType   = "imageCountMoreThan"
      countNumber = 1
    }
    action = {
      type = "expire"
    }
  }

  prod_policy = {
    rulePriority = 2
    description  = "Expire production Images"
    selection = {
      tagStatus     = "tagged"
      tagPrefixList = ["prod"]
      countType     = "imageCountMoreThan"
      countNumber   = 10
    }
    action = {
      type = "expire"
    }
  }

  dev_policy = {
    rulePriority = 3
    description  = "Expire dev Images"
    selection = {
      tagStatus     = "tagged"
      tagPrefixList = ["dev"]
      countType     = "imageCountMoreThan"
      countNumber   = 10
    }
    action = {
      type = "expire"
    }
  }

  tagged_policy = {
    rulePriority = 4
    description  = "Expire images that don't match above rules"
    selection = {
      tagStatus   = "any"
      countType   = "imageCountMoreThan"
      countNumber = 10
    }
    action = {
      type = "expire"
    }
  }

  #  user supplied lifecycle policy
  effective_policy = {
    rules = [
      local.untagged_policy,
      local.prod_policy,
      local.dev_policy,
      local.tagged_policy,
    ]
  }

}

#  user supplied repository policy
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
      identifiers = ["552365532775"]
    }
  }
}


resource "random_pet" "this" {
  length    = 2
  separator = "-"
}


module "example" {
  source = "../../"

  name                      = random_pet.this.id
  override_policy           = true
  policy                    = data.aws_iam_policy_document.this.json
  override_lifecycle_policy = true
  lifecycle_policy          = local.effective_policy
}
