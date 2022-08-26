data "aws_region" "current" {}


resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.mutable_tags ? "MUTABLE" : "IMMUTABLE"
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


# created if account_ids are not supplied and override_policy is true
resource "aws_ecr_repository_policy" "override" {
  count      = length(var.account_ids) == 0 && var.override_policy ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = var.policy

}


# created if account_ids are supplied and override_policy is false
resource "aws_ecr_repository_policy" "default" {
  count = length(var.account_ids) > 0 && !var.override_policy ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.default[0].json
}


# default policy if cross account ids are supplied
# if no cross account ids are supplied, no policy is created
data "aws_iam_policy_document" "default" {
  count = length(var.account_ids) > 0 ? 1 : 0

  statement {
    sid    = "AllowAccountID"
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
    sid    = "AllowService"
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
      values   = [for id in var.account_ids : "arn:aws:lambda:${data.aws_region.current.name}:${id}:function:*"]
    }
  }
}
