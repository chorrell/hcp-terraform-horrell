# The team token can't create a workspace with a GitHub App VCS connection (that needs a user who has linked a GitHub
# account), so horrell-ca-cache was created by hand in the HCP UI and is adopted here. Delete this file once it's applied.
import {
  to = tfe_workspace.this["horrell-ca-cache"]
  id = "horrell/horrell-ca-cache"
}
