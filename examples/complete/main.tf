# complete example with cross account sharing

resource "random_pet" "this" {
  length    = 2
  separator = "-"
}

module "example" {
  source = "../../"

  name                    = random_pet.this.id
  account_ids             = ["012345678912", "001122334455"]
  cross_account_service   = "EKS"
  tagged_images_to_keep   = 30
  untagged_images_to_keep = 3
}
