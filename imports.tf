# The team token can't create a workspace with a GitHub App VCS connection (that needs a user who has linked a GitHub
# account), so horrell-ca-cache was created by hand in the HCP UI and is adopted here. Delete this file once it's applied.
import {
  to = tfe_workspace.this["horrell-ca-cache"]
  id = "horrell/horrell-ca-cache"
}

# Created by hand in the HCP UI for the same reason. Delete this block once it's applied.
import {
  to = tfe_workspace.this["horrell-consulting-github-settings"]
  id = "horrell/horrell-consulting-github-settings"
}
