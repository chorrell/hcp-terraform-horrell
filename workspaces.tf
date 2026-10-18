locals {
  # GitHub App installation that connects HCP Terraform to github.com/chorrell.
  github_app_installation_id = "ghain-auj1gVJBwevGsznW"

  # Every workspace in the org except this one, which manages its own settings in self.tf.
  workspaces = {
    "horrell-ca" = {
      project             = "horrell_ca"
      repo                = "chorrell/horrell.ca"
      working_directory   = "terraform"
      terraform_version   = "~>1.16.0"
      global_remote_state = true
    }
    "horrell-ca-dns" = {
      project           = "horrell_ca"
      repo              = "chorrell/cloudflare-horrell"
      working_directory = "horrell.ca/dns"
    }
    "horrell-ca-r2" = {
      project           = "horrell_ca"
      repo              = "chorrell/cloudflare-horrell"
      working_directory = "horrell.ca/r2"
    }
    "horrell-ca-settings" = {
      project           = "horrell_ca"
      repo              = "chorrell/cloudflare-horrell"
      working_directory = "horrell.ca/settings"
    }
    "horrell-ca-waf" = {
      project           = "horrell_ca"
      repo              = "chorrell/cloudflare-horrell"
      working_directory = "horrell.ca/waf"
    }
    "horrell-info-dns" = {
      project           = "horrell_info"
      repo              = "chorrell/cloudflare-horrell"
      working_directory = "horrell.info/dns"
    }
    "horrell-info-redirects" = {
      project           = "horrell_info"
      repo              = "chorrell/cloudflare-horrell"
      working_directory = "horrell.info/redirects"
    }
    "horrell-info-settings" = {
      project           = "horrell_info"
      repo              = "chorrell/cloudflare-horrell"
      working_directory = "horrell.info/settings"
    }
    "tailscale" = {
      project           = "horrell_ca"
      repo              = "chorrell/tailscale-horrell"
      working_directory = "terraform"
      # Applies are confirmed by hand in the HCP UI.
      auto_apply = false
    }
  }

  projects = {
    horrell_ca   = tfe_project.horrell_ca.id
    horrell_info = tfe_project.horrell_info.id
  }

  # cloudflare-horrell has several roots, so each workspace only runs for changes in its own folder.
  # The single-root repos (horrell.ca, tailscale-horrell) leave file triggers off and track the default branch.
  monorepo = "chorrell/cloudflare-horrell"
}

resource "tfe_workspace" "this" {
  for_each = local.workspaces

  name         = each.key
  organization = tfe_organization.horrell.name
  project_id   = local.projects[each.value.project]

  working_directory     = each.value.working_directory
  terraform_version     = lookup(each.value, "terraform_version", "~> 1.16.0")
  file_triggers_enabled = each.value.repo == local.monorepo
  trigger_prefixes      = each.value.repo == local.monorepo ? ["${each.value.working_directory}/"] : []

  # Nobody can queue a whole-workspace destroy run, which auto-apply would apply without a confirm.
  # Enable it only to decommission a workspace.
  allow_destroy_plan = false

  # Only queue runs for changes, never for every push.
  queue_all_runs = false

  vcs_repo {
    identifier                 = each.value.repo
    branch                     = each.value.repo == local.monorepo ? "main" : null
    github_app_installation_id = local.github_app_installation_id
  }

  lifecycle {
    prevent_destroy = true
    # force_delete is a provider-only flag with no API value. Remote state sharing is owned by tfe_workspace_settings.
    ignore_changes = [force_delete, global_remote_state, remote_state_consumer_ids]
  }
}

resource "tfe_workspace_settings" "this" {
  for_each = local.workspaces

  workspace_id        = tfe_workspace.this[each.key].id
  auto_apply          = lookup(each.value, "auto_apply", true)
  global_remote_state = lookup(each.value, "global_remote_state", false)

  # The cloudflare-horrell workspaces were created through the API with execution mode set on the workspace;
  # horrell-ca and tailscale inherit the org default. Both resolve to remote.
  execution_mode = each.value.repo == local.monorepo ? "remote" : null
}
