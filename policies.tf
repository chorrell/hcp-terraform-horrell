# Deletion guard for workspaces that auto-apply. The Free plan allows one policy set and one mandatory policy, so this
# is the only set. Attach it with tfe_workspace_policy_set, not workspace_ids or global.
# The policy guards a list of high-value resource types everywhere, and every resource on github-settings. DNS records
# aren't listed, because they're replaced as a matter of course. tailscale is left off, since its applies are confirmed
# by hand.

resource "tfe_policy" "no_deletes" {
  name         = "no-deletes"
  description  = "Fails any run that deletes or replaces a protected resource type, or any resource on github-settings. Override the check to allow an intended delete."
  organization = tfe_organization.horrell.name
  kind         = "sentinel"
  policy       = file("${path.module}/policies/no-deletes.sentinel")
  enforce_mode = "soft-mandatory"
}

resource "tfe_policy_set" "deletion_guard" {
  name         = "deletion-guard"
  description  = "Policies that stop auto-applied runs from deleting resources."
  organization = tfe_organization.horrell.name
  kind         = "sentinel"
  policy_ids   = [tfe_policy.no_deletes.id]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tfe_workspace_policy_set" "deletion_guard" {
  for_each = merge(
    { for name, ws in tfe_workspace.this : name => ws.id if name != "tailscale" },
    # This workspace is read through a data source in self.tf, so it can't be in tfe_workspace.this.
    { "hcp-terraform" = data.tfe_workspace.self.id },
  )

  policy_set_id = tfe_policy_set.deletion_guard.id
  workspace_id  = each.value
}
