provider "tfe" {
  # Reads TFE_TOKEN from the environment: the owners team token, stored as a sensitive environment variable on this
  # workspace. Locally, `terraform login` credentials are used instead.
  organization = "horrell"
}
