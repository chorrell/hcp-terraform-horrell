# One-time imports of the objects that were configured by hand before this repo existed (chorrell/cloudflare-horrell#59).
# Import blocks are idempotent once applied; delete this file in a follow-up PR after the first apply.

import {
  to = tfe_organization.horrell
  id = "horrell"
}

import {
  to = tfe_project.horrell_ca
  id = "prj-pKSRNhA4p2px8NC3"
}

import {
  to = tfe_project.horrell_info
  id = "prj-Hriim4EG85Rirzjh"
}

locals {
  projects_import = {
    horrell_ca   = "prj-pKSRNhA4p2px8NC3"
    horrell_info = "prj-Hriim4EG85Rirzjh"
  }

  import_workspace_ids = {
    "tailscale"              = "ws-it9UzTWVRVovBLc8"
    "horrell-ca"             = "ws-xt6jbGzm686aPERu"
    "horrell-info-dns"       = "ws-5u7m6vb64hmrg3to"
    "horrell-ca-r2"          = "ws-UWqxeJnnCiDpoDTo"
    "horrell-ca-dns"         = "ws-EvDStAbkYfi7jL91"
    "horrell-ca-settings"    = "ws-2tqvWqYMG1xbpAZw"
    "horrell-ca-waf"         = "ws-ZMLr7VzgYSP3CrN5"
    "horrell-info-settings"  = "ws-xBz26Ev5o2B3qPkm"
    "horrell-info-redirects" = "ws-Ubo88fBX4tZ144ub"
  }

  import_notification_ids = {
    "horrell-ca"             = "nc-uQaSe5yKry6CDoMf"
    "horrell-ca-dns"         = "nc-i37XYigadVDaUWGe"
    "horrell-ca-r2"          = "nc-Kj7y446VTx29fn1W"
    "horrell-ca-settings"    = "nc-rMvoenyvek7EtyQs"
    "horrell-ca-waf"         = "nc-PHRR5PM8wV5bXfri"
    "horrell-info-dns"       = "nc-gqeHECgc2B9YCZFP"
    "horrell-info-redirects" = "nc-MuLeVRHPabfKLBcA"
    "horrell-info-settings"  = "nc-BNe6AmGfAC1hA6Mo"
  }

  import_variable_set_ids = {
    "horrell-ca-shared"       = "varset-ayJtxjjZG4ZNDUq4"
    "horrell-ca-cloudflare"   = "varset-qQaHpkTNfBB1WYSF"
    "horrell-info-shared"     = "varset-Ujcspo1DuBAa7MeA"
    "horrell-info-cloudflare" = "varset-hTEkNMWri5hztnUi"
  }

  import_variable_set_variable_ids = {
    "horrell-ca-shared/TF_VAR_droplet_ip"              = "var-3JvaMwaYCm5Z7RsM"
    "horrell-ca-shared/TF_VAR_cloudflare_account_id"   = "var-vgw3EqMsg9Nu8ATQ"
    "horrell-ca-cloudflare/cloudflare_zone_id"         = "var-GWRgnRNZv4GfaYAj"
    "horrell-info-shared/TF_VAR_droplet_ip"            = "var-KaBjuZV7Pb7UssMU"
    "horrell-info-shared/TF_VAR_cloudflare_account_id" = "var-GjVtnoDneFWgQuzG"
    "horrell-info-cloudflare/cloudflare_zone_id_info"  = "var-yk7Wzu4EqPpEwmKq"
  }
}

import {
  for_each = local.import_workspace_ids
  to       = tfe_workspace.this[each.key]
  id       = each.value
}

import {
  for_each = local.import_workspace_ids
  to       = tfe_workspace_settings.this[each.key]
  id       = each.value
}

import {
  for_each = local.import_notification_ids
  to       = tfe_notification_configuration.apply_alerts[each.key]
  id       = each.value
}

import {
  for_each = local.import_variable_set_ids
  to       = tfe_variable_set.this[each.key]
  id       = each.value
}

import {
  for_each = local.import_variable_set_variable_ids
  to       = tfe_variable.variable_set[each.key]
  id       = "horrell/${local.import_variable_set_ids[split("/", each.key)[0]]}/${each.value}"
}

import {
  to = tfe_variable.horrell_ca_alert_emails
  id = "horrell/horrell-ca/var-MJrRAuY1Pb5N6yyU"
}

import {
  for_each = { for name, vs in local.variable_sets : name => vs.project if can(vs.project) }
  to       = tfe_project_variable_set.this[each.key]
  id       = "horrell/${local.projects_import[each.value]}/${each.key}"
}

import {
  for_each = merge([
    for name, vs in local.variable_sets : {
      for ws in try(vs.workspaces, []) : "${name}/${ws}" => { variable_set = name, workspace = ws }
    }
  ]...)
  to = tfe_workspace_variable_set.this[each.key]
  id = "horrell/${each.value.workspace}/${each.value.variable_set}"
}
