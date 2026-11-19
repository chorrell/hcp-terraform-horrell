# Non-sensitive workspace variables. Sensitive ones (DIGITALOCEAN_TOKEN, SPACES_*, TAILSCALE_OAUTH_CLIENT_ID,
# TFC_WORKLOAD_IDENTITY_AUDIENCE, GITHUB_APP_*) are set by hand in the HCP UI and not managed here.

resource "tfe_variable" "horrell_ca_alert_emails" {
  workspace_id = tfe_workspace.this["horrell-ca"].id
  key          = "alert_emails"
  value        = jsonencode(var.alert_emails)
  category     = "terraform"
  hcl          = true
}

# The GitHub App ARC registers runners with, owned by and installed on the horrell-consulting organization. Not secret;
# its private key is the sensitive github_app_private_key, set by hand in the HCP UI.
resource "tfe_variable" "doks_runners_arc_github_app_id" {
  workspace_id = tfe_workspace.this["doks-runners-arc"].id
  key          = "github_app_id"
  value        = "5836037"
  category     = "terraform"
}

resource "tfe_variable" "doks_runners_arc_github_app_installation_id" {
  workspace_id = tfe_workspace.this["doks-runners-arc"].id
  key          = "github_app_installation_id"
  value        = "183750005"
  category     = "terraform"
}
