# Looked up by HCP username rather than email, so no address is in the code. Notifications go to the account's email.
data "tfe_organization_membership" "owner" {
  # A literal, not tfe_organization.horrell.name, so a pending org update doesn't defer this read to apply time.
  organization = "horrell"
  username     = "chorrell2022"
}

# Merges apply without a confirm, and nobody watches the runs, so email the owner when one starts applying, waits for
# approval or fails. tailscale confirms applies by hand in the HCP UI and has no notification.
resource "tfe_notification_configuration" "apply_alerts" {
  for_each = { for name, ws in local.workspaces : name => ws if lookup(ws, "auto_apply", true) }

  name             = "${each.key} apply alerts"
  workspace_id     = tfe_workspace.this[each.key].id
  destination_type = "email"
  enabled          = true
  email_user_ids   = [data.tfe_organization_membership.owner.user_id]
  triggers = [
    "run:applying",
    "run:pending_apply_approval",
    "run:run_errored",
  ]

  lifecycle {
    # The live notifications also fire on "workspace:deleted", which the API accepts but the provider's validation
    # rejects (tfe 0.82). Ignoring triggers keeps that trigger instead of planning to remove it. A notification created
    # from this config won't have it; add it in the HCP UI.
    ignore_changes = [triggers]
  }
}
