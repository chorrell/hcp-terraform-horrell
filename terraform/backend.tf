terraform {
  cloud {
    organization = "horrell"

    workspaces {
      name = "hcp-terraform"
    }
  }
}
