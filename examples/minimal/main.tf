# minimal example with no cross account sharing

resource "random_pet" "this" {
  length    = 2
  separator = "-"
}

module "example" {
  source = "../../"

  name = random_pet.this.id
}
