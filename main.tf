data "aws_region" "current" {}


resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.mutable_tags ? "MUTABLE" : "IMMUTABLE"
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = true
  }
}

# default lifecycle policy if override lifecycle policy is not supplied
resource "aws_ecr_lifecycle_policy" "default" {
  count = var.override_lifecycle_policy ? 0 : 1

  repository = aws_ecr_repository.this.name
  policy     = jsonencode(local.effective_policy)
}


# override lifecycle policy - user supplied
resource "aws_ecr_lifecycle_policy" "this" {
  count = var.override_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = jsonencode(var.lifecycle_policy)
}


# override repo policy - user supplied
resource "aws_ecr_repository_policy" "override" {
  count      = length(var.account_ids) == 0 && var.override_policy ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = var.policy

}

# default repo policy if cross account pull access is desired and override repo policy is not provided
resource "aws_ecr_repository_policy" "default" {
  count = (local.eks_cross_account_enabled || local.lambda_cross_account_enabled) && !var.override_policy ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.default[0].json
}

# default repo policy if cross account pull access is desired
# configures a policy for cross account pulls from either EKS or Lambda
data "aws_iam_policy_document" "default" {
  count = anytrue([local.eks_cross_account_enabled, local.lambda_cross_account_enabled]) ? 1 : 0

  source_policy_documents = [
    local.eks_cross_account_enabled ? data.aws_iam_policy_document.eks_cross_account[0].json : jsonencode({}),
    local.lambda_cross_account_enabled ? data.aws_iam_policy_document.lambda_cross_account[0].json : jsonencode({}),
  ]
}

# Lambda cross account pull policy
data "aws_iam_policy_document" "lambda_cross_account" {
  count = local.lambda_cross_account_enabled ? 1 : 0

  statement {
    sid    = "AllowLambdaAccountID"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    principals {
      type        = "AWS"
      identifiers = [for id in var.account_ids : "arn:aws:iam::${id}:root"]
    }
  }
  statement {
    sid    = "AllowLambdaCrossAccountPull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "aws:sourceARN"
      values   = [for id in var.account_ids : "arn:aws:lambda:${data.aws_region.current.region}:${id}:function:*"]
    }
  }
}

# EKS cross account pull policy
data "aws_iam_policy_document" "eks_cross_account" {
  count = local.eks_cross_account_enabled ? 1 : 0

  statement {
    sid    = "AllowEKSCrossAccountPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
    ]
    principals {
      type = "AWS"
      identifiers = [
        for account in var.account_ids : "arn:aws:iam::${account}:root"
      ]
    }
  }
}

moved {
  from = module.example.aws_ecr_lifecycle_policy.this
  to   = module.example.aws_ecr_lifecycle_policy.this[0]
}
