# AGENTS.md

Terraform for the `horrell` HCP Terraform organization: org settings, projects, workspaces, notifications and variable sets, via the `hashicorp/tfe` provider. It's the source of truth for workspace settings in [cloudflare-horrell](https://github.com/chorrell/cloudflare-horrell), [tailscale-horrell](https://github.com/chorrell/tailscale-horrell), [horrell.ca](https://github.com/chorrell/horrell.ca) and [github-settings](https://github.com/chorrell/github-settings). The Terraform lives at the repo root, and the `hcp-terraform` workspace plans on every commit. See [README.md](README.md) for the bootstrap order and workflow.

## Structure

```text
├── backend.tf                  # HCP workspace horrell/hcp-terraform (cloud block); flat root module, no submodules
├── versions.tf                 # Terraform ~> 1.16, hashicorp/tfe ~> 0.82
├── provider.tf                 # Token from TFE_TOKEN (owners team token)
├── organization.tf             # tfe_organization + the two projects
├── workspaces.tf               # local.workspaces map -> tfe_workspace + tfe_workspace_settings; Default Project looked up
├── policies.tf                 # Sentinel deletion-guard policy set (one allowed on Free), on every auto-applying workspace
├── policies/                   # Sentinel policy source (no-deletes.sentinel)
├── notifications.tf            # Email alerts on every auto-applying workspace
├── variable_sets.tf            # Variable sets, non-sensitive variables, attachments
├── workspace_variables.tf      # Non-sensitive workspace variables
├── variables.tf                # organization_email, alert_emails (values on the hcp-terraform workspace)
├── self.tf                     # This workspace's own settings via data "tfe_workspace"
└── .github/workflows/
    ├── terraform.yml           # fmt, validate, tflint; aggregate `Terraform Validation` check
    ├── markdownlint.yml        # Stub calling chorrell/workflows
    └── zizmor.yml              # Stub calling chorrell/workflows
```

## Rules

- **Never manage a sensitive value here.** Don't add a `tfe_variable` with `sensitive = true` and a real value, because it would be stored in state. Sensitive variables are set by hand in the HCP UI and stay out of this config.
- **No email addresses in the code.** Pass them through `variables.tf`, with values set as Terraform variables on the `hcp-terraform` workspace.
- **Keep `prevent_destroy`** on the organization, projects, workspaces, variable sets and the policy set. Workspaces hold state and VCS connections, and a destroy or replace would lose them.
  - `prevent_destroy` only covers resources still in config. A PR that removes a workspace from `local.workspaces` plans a plain destroy, so check every plan's "to destroy" count.
- **Renaming a map key or resource needs a `moved` block**, or Terraform plans a destroy and create.
- **One owner per setting.**
  - `auto_apply`, execution mode and remote state sharing belong to `tfe_workspace_settings`. Don't also set them on `tfe_workspace`.
  - Variable set attachments belong to `tfe_project_variable_set` / `tfe_workspace_variable_set`. Don't set `workspace_ids` on the variable set.
- **The `deletion-guard` policy set is the only one the Free plan allows.** Attach workspaces with `tfe_workspace_policy_set` in `policies.tf`, not `workspace_ids` or `global`. It covers every auto-applying workspace, including `hcp-terraform` through `data.tfe_workspace.self`.
  - `no-deletes` fails a delete or replace of a type in its `protected_types` list, and any delete at all on `github-settings`. Add a type there when a workspace gains a resource that a destroy would lose for good. Don't add DNS records or zone settings, because they're replaced routinely.
  - Keep the policy's HCP name `no-deletes`, and check the plan's "to destroy" count if you change it.
  - `prevent_destroy` stops a plan before Sentinel runs, so the policy matters most when a resource's config block is removed.
- **Don't change settings in the HCP UI.** The next apply reverts them. Make the change here.
- **New workspaces are created in the HCP UI and imported.** The team token can't create a GitHub App VCS connection, so creating a `tfe_workspace` fails on apply.
- When adding a workspace, attach it to `deletion-guard` unless its applies are confirmed by hand, and add its `Terraform Cloud/horrell/<name>` check to the owning repo's required checks in [github-settings](https://github.com/chorrell/github-settings) (`repos.yaml`).
- Run `terraform fmt -recursive`, `terraform validate` and `tflint` from the repo root, or `pre-commit run --all-files`. Provider bumps need the lock file for both platforms: `terraform providers lock -platform=linux_amd64 -platform=darwin_arm64`.
- Commits and PR titles use conventional commits (`feat(workspaces): ...`, `chore(deps): ...`). Branch from `main` with a `feature/` prefix. Keep PR bodies to a few bullets on intent.
