# Non-sensitive workspace variables. Sensitive ones (DIGITALOCEAN_TOKEN, SPACES_*, TAILSCALE_OAUTH_CLIENT_ID,
# TFC_WORKLOAD_IDENTITY_AUDIENCE) are set by hand in the HCP UI and not managed here.

resource "tfe_variable" "horrell_ca_alert_emails" {
  workspace_id = tfe_workspace.this["horrell-ca"].id
  key          = "alert_emails"
  value        = jsonencode(["chrishorrell@icloud.com"])
  category     = "terraform"
  hcl          = true
}
