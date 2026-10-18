resource "tfe_organization" "horrell" {
  name  = "horrell"
  email = var.organization_email

  collaborator_auth_policy      = "password"
  cost_estimation_enabled       = true
  allow_force_delete_workspaces = true

  # Settings -> Version Control. Untouched workspaces post a passing status, so every
  # `Terraform Cloud/horrell/<workspace>` check reports on every PR and rulesets can require them.
  send_passing_statuses_for_untriggered_speculative_plans = true
  speculative_plan_management_enabled                     = true
  aggregated_commit_status_enabled                        = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "tfe_project" "horrell_ca" {
  name         = "Horrell-ca"
  organization = tfe_organization.horrell.name
  description  = "For management of Horrell.ca and related resources"

  lifecycle {
    prevent_destroy = true
  }
}

resource "tfe_project" "horrell_info" {
  name         = "Horrell-info"
  organization = tfe_organization.horrell.name

  lifecycle {
    prevent_destroy = true
  }
}
