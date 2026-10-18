# Deletion guard for workspaces that auto-apply settings with no undo. The Free plan allows one policy set and one
# mandatory policy, so this is the only set. Attach it with tfe_workspace_policy_set, not workspace_ids or global.
# The Cloudflare workspaces aren't attached, because their records are replaced as a matter of course.

resource "tfe_policy" "no_deletes" {
  name         = "no-deletes"
  description  = "Fails any run that deletes or replaces a managed resource. Override the check to allow an intended delete."
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
  for_each = toset(["github-settings"])

  policy_set_id = tfe_policy_set.deletion_guard.id
  workspace_id  = tfe_workspace.this[each.key].id
}
