# hcp-terraform-horrell

[![terraform](https://github.com/chorrell/hcp-terraform-horrell/actions/workflows/terraform.yml/badge.svg)](https://github.com/chorrell/hcp-terraform-horrell/actions/workflows/terraform.yml)

This repo is the source of truth for the `horrell` [HCP Terraform](https://app.terraform.io/app/horrell) organization. It covers the org settings, projects, each workspace's VCS connection and run settings, run notifications, and variable sets. The HCP workspace `hcp-terraform` manages them with the [`hashicorp/tfe`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs) provider. Change these settings here, not in the HCP UI, because the next apply reverts UI edits.

The workspaces hold state for [cloudflare-horrell](https://github.com/chorrell/cloudflare-horrell), [tailscale-horrell](https://github.com/chorrell/tailscale-horrell) and [horrell.ca](https://github.com/chorrell/horrell.ca).

## What's managed

| File | Manages |
| --- | --- |
| [`terraform/organization.tf`](terraform/organization.tf) | Org settings (commit statuses, speculative plan cancellation) and the `Horrell-ca` / `Horrell-info` projects |
| [`terraform/workspaces.tf`](terraform/workspaces.tf) | The nine workspaces: VCS repo, working directory, trigger prefixes, Terraform version, destroy plans off. Auto-apply and remote state go through `tfe_workspace_settings` |
| [`terraform/notifications.tf`](terraform/notifications.tf) | Email alerts (applying, pending approval, errored) on every auto-applying workspace |
| [`terraform/variable_sets.tf`](terraform/variable_sets.tf) | The four variable sets, their non-sensitive variables, and their project and workspace attachments |
| [`terraform/workspace_variables.tf`](terraform/workspace_variables.tf) | Non-sensitive workspace variables (`alert_emails` on `horrell-ca`) |
| [`terraform/imports.tf`](terraform/imports.tf) | One-time `import` blocks for the objects created by hand. Delete it after the first apply |

**Not managed:** sensitive variable values (`CLOUDFLARE_API_TOKEN`, `cloudflare_api_token_info`, `DIGITALOCEAN_TOKEN`, `SPACES_*`, `TAILSCALE_OAUTH_CLIENT_ID`, `TFC_WORKLOAD_IDENTITY_AUDIENCE`). They're set by hand in the HCP UI, so they never end up in this repo or its state.

## Bootstrap (one time, in order)

1. **Workspace.** In org `horrell`, create workspace `hcp-terraform` in the Default Project. Connect it to this repo, with working directory `terraform`, trigger prefix `terraform/`, and auto-apply **off**. Then set these by hand, because `tfe_workspace_settings` doesn't manage them:
   - Terraform version `~> 1.16.0`.
   - **Allow destroy plans off** (Settings → Destruction and Deletion). It's on by default, and this workspace manages every other one.

   If HCP's GitHub App is installed for selected repositories only, add this repo to the installation first, or HCP can't connect to it.
2. **Token.** The Free plan has no custom teams, so the only team token is the `owners` team's, which is org admin. Create it (Organization settings → Teams → owners → Team API token). Add it to the workspace as the **sensitive environment variable** `TFE_TOKEN`. Don't use a personal user token.
3. **Import.** Merge the import PR. Its speculative plan must read `49 to import, 0 to add, 0 to change, 0 to destroy`. Confirm the apply in the HCP UI.
4. **Self-management.** In a follow-up PR, delete `imports.tf` and add `self.tf` with:
   - `data "tfe_workspace"` for `hcp-terraform`
   - a `tfe_workspace_settings` that turns auto-apply on
   - the workspace's email notification

   Then add `Terraform Cloud/horrell/hcp-terraform` to the required checks in [github-settings](https://github.com/chorrell/github-settings).

## Day to day

- **Making a change:** edit `terraform/` in a PR.
  - CI (`Terraform Validation`) runs fmt, validate and tflint.
  - HCP posts a speculative plan as `Terraform Cloud/horrell/hcp-terraform`. Read it before merging, because once auto-apply is on, merging applies it.
- **Adding a workspace:** add it to `local.workspaces` in `workspaces.tf`. Then add its `Terraform Cloud/horrell/<name>` check to the owning repo's required checks in github-settings.
- **Sensitive values:** set or rotate them in the HCP UI. A sensitive `tfe_variable` here would put its value in state.
- **Local plan:** run `terraform login`, then `terraform init` and `terraform plan` in `terraform/`. Plans run remotely. `terraform apply` from a laptop fails because the workspace is VCS-connected.
- **Linting:** run `pre-commit install` once. The hooks run actionlint, gitleaks, markdownlint (Docker), zizmor, `terraform fmt`, `terraform validate`, tflint and trivy.

> This repo is **private** because it contains account IDs and email addresses.

## License

[MPL-2.0](LICENSE)
