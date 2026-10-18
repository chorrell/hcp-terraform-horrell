# This workspace manages its own run settings with the provider's self-managed pattern: it reads itself through a data
# source rather than a tfe_workspace resource, so a bad change can't replace or disconnect the workspace that would
# have to undo it. Its VCS connection, Terraform version and destroy-plan setting are set by hand (see README).

data "tfe_workspace" "self" {
  name         = "hcp-terraform"
  organization = tfe_organization.horrell.name
}

resource "tfe_workspace_settings" "self" {
  workspace_id = data.tfe_workspace.self.id
  auto_apply   = true
}

resource "tfe_notification_configuration" "self_apply_alerts" {
  name             = "hcp-terraform apply alerts"
  workspace_id     = data.tfe_workspace.self.id
  destination_type = "email"
  enabled          = true
  email_user_ids   = [data.tfe_organization_membership.owner.user_id]
  triggers = [
    "run:applying",
    "run:pending_apply_approval",
    "run:run_errored",
  ]

  lifecycle {
    # Matches apply_alerts in notifications.tf: add "workspace:deleted" in the HCP UI, since the provider rejects it.
    ignore_changes = [triggers]
  }
}
