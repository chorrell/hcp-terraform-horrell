# The team token can't create a workspace with a GitHub App VCS connection (that needs a user who has linked a GitHub
# account), so github-settings was created by hand in the HCP UI and is adopted here. Delete this file once it's applied.
import {
  to = tfe_workspace.this["github-settings"]
  id = "ws-LVjhhFm8h28kD1wD"
}
