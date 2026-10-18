# AGENTS.md

The GitHub template (`is_template: true`) that new `chorrell` repositories are
created from. It contains only shared configuration, no application code. See
[README.md](README.md) for what each file does and the checklist for new
repositories.

## Structure

```text
├── .pre-commit-config.yaml     # actionlint, gitleaks, markdownlint-cli2 (Docker), hygiene hooks, zizmor
├── .markdownlint.yaml          # MD013 (line length) disabled
├── .gitignore                  # Language-agnostic: OS files, .env*, editor dirs, .claude/settings.local.json
├── .gitattributes              # * text=auto
├── AGENTS.md / CLAUDE.md       # Agent guidance; CLAUDE.md only imports AGENTS.md
├── LICENSE                     # MPL-2.0
└── .github/
    ├── CODEOWNERS              # * @chorrell
    ├── dependabot.yml          # github-actions + pre-commit, monthly, grouped, 7-day cooldown
    ├── zizmor.yml              # chorrell/* may be tag-pinned; everything else hash-pinned
    └── workflows/
        ├── markdownlint.yml    # PR stub calling chorrell/workflows markdownlint.yml@v1
        └── zizmor.yml          # PR + main stub calling chorrell/workflows zizmor.yml@v1
```

## Rules

- **Everything here is copied into every new repository.** Keep it
  language-agnostic. Python, Docker, Terraform and similar hooks, Dependabot
  ecosystems and ignores belong in the repositories that need them.
- **Keep this in sync with my other repositories.** When a shared default
  changes (a hook, the Dependabot layout, the markdownlint stub), change it here
  too, so new repositories don't start out of date.
- **Reusable workflows live in [chorrell/workflows](https://github.com/chorrell/workflows).**
  Workflows here are short stubs that own their triggers, `permissions` and
  `concurrency` and call the shared workflow by tag (`@v1`). Third-party actions
  are pinned by commit hash with a version comment; zizmor enforces this.
- **Repository settings aren't configured here.** Merge settings, rulesets and
  required status checks are managed by Terraform in
  [chorrell/github-settings](https://github.com/chorrell/github-settings)
  (`repos.yaml`). Don't change them in the GitHub UI.
- Run `pre-commit run --all-files` before pushing (the markdownlint hook needs
  Docker). CI runs markdownlint on pull requests to `main`, and zizmor on
  every pull request and push to `main`. `zizmor / zizmor` is a required check
  on every repository, so don't remove the zizmor stub.
- Dependabot opens grouped monthly PRs: `ci(deps): ...` for Actions,
  `chore(deps): ...` for pre-commit hooks.
- Commits and PR titles use conventional commits (`feat: ...`, `ci: ...`,
  `chore(deps): ...`). Branch from `main` with a `feature/` prefix. PRs are
  squash-merged, so keep PR bodies short and focused on intent.
