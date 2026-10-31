# hcp-terraform-horrell

[![terraform](https://github.com/chorrell/hcp-terraform-horrell/actions/workflows/terraform.yml/badge.svg)](https://github.com/chorrell/hcp-terraform-horrell/actions/workflows/terraform.yml)

This repo is the source of truth for the `horrell` [HCP Terraform](https://app.terraform.io/app/horrell) organization. It covers the org settings, projects, each workspace's VCS connection and run settings, run notifications, and variable sets. The HCP workspace `hcp-terraform` manages them with the [`hashicorp/tfe`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs) provider. Change these settings here, not in the HCP UI, because the next apply reverts UI edits.

The workspaces hold state for [cloudflare-horrell](https://github.com/chorrell/cloudflare-horrell), [tailscale-horrell](https://github.com/chorrell/tailscale-horrell), [horrell.ca](https://github.com/chorrell/horrell.ca) and [github-settings](https://github.com/chorrell/github-settings).

## What's managed

| File | Manages |
| --- | --- |
| [`organization.tf`](organization.tf) | Org settings (commit statuses, speculative plan cancellation) and the `Horrell-ca` / `Horrell-info` projects. The Default Project is looked up, not managed |
| [`workspaces.tf`](workspaces.tf) | The ten workspaces: VCS repo, working directory, trigger prefixes, Terraform version, destroy plans off. Auto-apply and remote state go through `tfe_workspace_settings` |
| [`notifications.tf`](notifications.tf) | Email alerts (applying, pending approval, errored) on every auto-applying workspace |
| [`policies.tf`](policies.tf) | The `deletion-guard` Sentinel policy set and its `no-deletes` policy ([`policies/`](policies)), attached to every auto-applying workspace (all but `tailscale`) |
| [`variable_sets.tf`](variable_sets.tf) | The four variable sets, their non-sensitive variables, and their project and workspace attachments |
| [`workspace_variables.tf`](workspace_variables.tf) | Non-sensitive workspace variables (`alert_emails` on `horrell-ca`) |
| [`variables.tf`](variables.tf) | `organization_email` and `alert_emails`, so no email address is in the code. Their values live on the `hcp-terraform` workspace |
| [`self.tf`](self.tf) | This workspace's own auto-apply setting and email notification (self-managed through a data source) |

**Not managed:** sensitive variable values (`CLOUDFLARE_API_TOKEN`, `cloudflare_api_token_info`, `DIGITALOCEAN_TOKEN`, `SPACES_*`, `TAILSCALE_OAUTH_CLIENT_ID`, `TFC_WORKLOAD_IDENTITY_AUDIENCE`, `GITHUB_APP_ID`, `GITHUB_APP_INSTALLATION_ID`, `GITHUB_APP_PEM_FILE`). They're set by hand in the HCP UI, so they never end up in this repo or its state.

## Bootstrap (one time, in order)

1. **Workspace.** In org `horrell`, create workspace `hcp-terraform` in the Default Project. Connect it to this repo with the default (root) working directory, automatic run triggering set to always trigger runs, and auto-apply **off**. Then set these by hand, because `tfe_workspace_settings` doesn't manage them:
   - Terraform version `~> 1.16.0`.
   - **Allow destroy plans off** (Settings → Destruction and Deletion). It's on by default, and this workspace manages every other one.

   If HCP's GitHub App is installed for selected repositories only, add this repo to the installation first, or HCP can't connect to it.
2. **Token.** The Free plan has no custom teams, so the only team token is the `owners` team's, which is org admin. Create it under Organization settings → API tokens → Team Tokens → Create a team token, and pick the `owners` team. Add it to the workspace as the **sensitive environment variable** `TFE_TOKEN`. Don't use a personal user token. Also add the **Terraform variables** `organization_email` (the org's admin email) and `alert_emails` (HCL list, for example `["you@example.com"]`).
3. **Import.** Merge the import PR. Its speculative plan must read `49 to import, 0 to add, 1 to change, 0 to destroy`. The one change is `tfe_organization.horrell`'s `email` becoming sensitive, and the plan says the value is unchanged. Anything else changing means the config doesn't match the live settings. Confirm the apply in the HCP UI.
4. **Self-management.** Merge the self-management PR. It deletes `imports.tf` and adds [`self.tf`](self.tf), which turns on this workspace's auto-apply and adds its email notification. Then make `Terraform Cloud/horrell/hcp-terraform` a required check in [github-settings](https://github.com/chorrell/github-settings). It runs on HCP Terraform with apply-on-merge, so merging that change applies it.

## Day to day

- **Making a change:** edit the `.tf` files in a PR.
  - CI (`Terraform Validation`) runs fmt, validate and tflint.
  - HCP posts a speculative plan as `Terraform Cloud/horrell/hcp-terraform` on every PR, including docs-only ones, where it should show no changes. Read it before merging, because once auto-apply is on, merging applies it.
- **Adding a workspace:** create it by hand in the HCP UI first, connected to its repo through the GitHub App, with auto-apply off. The `owners` team token can't create a GitHub App VCS connection, because that needs a user with a linked GitHub account. Then add it to `local.workspaces` in `workspaces.tf` with an `import` block, and match the live values so the plan shows only the import. Delete the `import` block once it has been applied. Then add its `Terraform Cloud/horrell/<name>` check to the owning repo's required checks in github-settings.
- **Deletion guard:** every auto-applying workspace is attached to `deletion-guard`. Its `no-deletes` policy fails a plan that deletes or replaces a protected resource type, such as a workspace, droplet, reserved IP, Spaces or R2 bucket, DNSSEC or ruleset. On `github-settings` it fails any delete. DNS records aren't protected, since they're replaced routinely. A failure posts as `sentinel/horrell/<name>`, and the PR's `Terraform Cloud/horrell/<name>` check fails with it. The policy is soft-mandatory, so for an intended delete, an org owner overrides the policy check on that run in the HCP UI. The Free plan allows one policy set and one mandatory policy, so add other workspaces to this set rather than creating another.
- **Sensitive values:** set or rotate them in the HCP UI. A sensitive `tfe_variable` here would put its value in state.
- **Local plan:** run `terraform login`, then `terraform init` and `terraform plan` from the repo root. Plans run remotely. `terraform apply` from a laptop fails because the workspace is VCS-connected.
- **Linting:** run `pre-commit install` once. The hooks run gitleaks, markdownlint (Docker), zizmor, `terraform fmt`, `terraform validate`, tflint and trivy. zizmor is the workflow linter; actionlint isn't used because it rejects GitHub's `$/` self-repository `uses:` syntax ([rhysd/actionlint#711](https://github.com/rhysd/actionlint/issues/711)).

> This repo is **private** because it contains account IDs and email addresses.

## License

[MPL-2.0](LICENSE)
