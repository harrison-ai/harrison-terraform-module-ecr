resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.mutable ? "MUTABLE" : "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = jsonencode(local.effective_policy)
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
# if not cross account ids supplied, no policy is created
data "aws_iam_policy_document" "default" {
  count = length(var.account_ids) > 0 ? 1 : 0

  statement {
    sid    = "01"
    effect = "Allow"
    actions = [
      "ecr:GetRegistryPolicy",
      "ecr:PutImageTagMutability",
      "ecr:DescribeImageScanFindings",
      "ecr:StartImageScan",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeRegistry",
      "ecr:DescribeImageReplicationStatus",
      "ecr:GetAuthorizationToken",
      "ecr:ListTagsForResource",
      "ecr:UploadLayerPart",
      "ecr:BatchDeleteImage",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:StartLifecyclePolicyPreview",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:ReplicateImage",
      "ecr:GetRepositoryPolicy",
      "ecr:GetLifecyclePolicy"
    ]
    principals {
      type        = "AWS"
      identifiers = [for id in var.account_ids : "arn:aws:iam::${id}:root"]
    }
  }
}
