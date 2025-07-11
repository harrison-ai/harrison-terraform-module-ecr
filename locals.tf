locals {

  untagged_policy = {
    rulePriority = 1
    description  = "Expire untagged Images"
    selection = {
      tagStatus   = "untagged"
      countType   = "imageCountMoreThan"
      countNumber = var.untagged_images_to_keep
    }
    action = {
      type = "expire"
    }
  }

  tagged_policy = {
    rulePriority = 2
    description  = "Expire tagged Images"
    selection = {
      tagStatus   = "any"
      countType   = "imageCountMoreThan"
      countNumber = var.tagged_images_to_keep
    }
    action = {
      type = "expire"
    }
  }

  effective_policy = {
    rules = [
      local.untagged_policy,
      local.tagged_policy,
    ]
  }

  lambda_cross_account_enabled = alltrue([length(var.account_ids) > 0, var.cross_account_service == "Lambda"])
  eks_cross_account_enabled    = alltrue([length(var.account_ids) > 0, var.cross_account_service == "EKS"])

}
