# Variable sets and their non-sensitive variables. Sensitive values (CLOUDFLARE_API_TOKEN, cloudflare_api_token_info,
# and the workspace secrets for horrell-ca and tailscale) are set by hand in the HCP UI and deliberately not managed
# here, so they never appear in this repo or its state.

locals {
  # Each domain has a project-scoped "shared" set (also reaches the DigitalOcean workspace) and a workspace-scoped
  # "cloudflare" set attached only to that domain's Cloudflare workspaces.
  variable_sets = {
    "horrell-ca-shared" = {
      description = "Shared values for horrell.ca compute + Cloudflare workspaces"
      project     = "horrell_ca"
    }
    "horrell-ca-cloudflare" = {
      description = "Shared horrell.ca Cloudflare context (API token + zone ID) for the 4 CF workspaces (dns/r2/settings/waf), not the DO workspace"
      workspaces  = ["horrell-ca-dns", "horrell-ca-r2", "horrell-ca-settings", "horrell-ca-waf"]
    }
    "horrell-info-shared" = {
      description = "Shared values for horrell.info workspaces (mirrors horrell-ca-shared)"
      project     = "horrell_info"
    }
    "horrell-info-cloudflare" = {
      description = "Shared horrell.info Cloudflare context (API token + zone ID), mirrors horrell-ca-cloudflare"
      workspaces  = ["horrell-info-dns", "horrell-info-redirects", "horrell-info-settings"]
    }
  }

  droplet_ip            = "104.248.104.116"
  cloudflare_account_id = "e7416f9d749bd2630587e84e69741c73"

  # Keyed "<variable set>/<key>".
  variable_set_variables = {
    "horrell-ca-shared/TF_VAR_droplet_ip" = {
      category    = "env"
      value       = local.droplet_ip
      description = "Reserved IP of the horrell.ca droplet"
    }
    "horrell-ca-shared/TF_VAR_cloudflare_account_id" = {
      category    = "env"
      value       = local.cloudflare_account_id
      description = "Cloudflare account ID"
    }
    "horrell-ca-cloudflare/cloudflare_zone_id" = {
      category    = "terraform"
      value       = "d57ba770e40ceb23096aeb3ce0be6aea"
      description = "Zone ID for horrell.ca"
    }
    "horrell-info-shared/TF_VAR_droplet_ip" = {
      category    = "env"
      value       = local.droplet_ip
      description = "Reserved IP of the horrell.ca droplet (horrell.info redirects to horrell.ca)"
    }
    "horrell-info-shared/TF_VAR_cloudflare_account_id" = {
      category    = "env"
      value       = local.cloudflare_account_id
      description = "Cloudflare account ID (preemptive, for future horrell.info resources like R2)"
    }
    "horrell-info-cloudflare/cloudflare_zone_id_info" = {
      category    = "terraform"
      value       = "b012ab754016f45b8439625997d0beb4"
      description = "Zone ID for horrell.info"
    }
  }
}

resource "tfe_variable_set" "this" {
  for_each = local.variable_sets

  name         = each.key
  description  = each.value.description
  organization = tfe_organization.horrell.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "tfe_variable" "variable_set" {
  for_each = local.variable_set_variables

  variable_set_id = tfe_variable_set.this[split("/", each.key)[0]].id
  key             = split("/", each.key)[1]
  value           = each.value.value
  category        = each.value.category
  description     = each.value.description
}

resource "tfe_project_variable_set" "this" {
  for_each = { for name, vs in local.variable_sets : name => vs.project if can(vs.project) }

  variable_set_id = tfe_variable_set.this[each.key].id
  project_id      = local.projects[each.value]
}

resource "tfe_workspace_variable_set" "this" {
  for_each = merge([
    for name, vs in local.variable_sets : {
      for ws in try(vs.workspaces, []) : "${name}/${ws}" => { variable_set = name, workspace = ws }
    }
  ]...)

  variable_set_id = tfe_variable_set.this[each.value.variable_set].id
  workspace_id    = tfe_workspace.this[each.value.workspace].id
}
