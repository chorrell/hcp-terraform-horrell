# The team token can't create a workspace with a GitHub App VCS connection (that needs a user who has linked a GitHub
# account), so doks-runners-arc is created by hand in the HCP UI and adopted here. Delete this file once it's applied.
import {
  to = tfe_workspace.this["doks-runners-arc"]
  id = "horrell/doks-runners-arc"
}
