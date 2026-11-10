# .github

GitHub reads a few files from a public repository named `.github` and applies them to every repository of this account that has none of its own: here, a pull request template and issue forms.

**Don't edit them here.** They are copies of the same paths in [spdolan/project-standards](https://github.com/spdolan/project-standards), the one place spdolan's maintenance standards live. Each copied file starts with a "Generated from" line, and `SYNCED_FROM` records the release they came from.

| File | Does |
|---|---|
| `sync.txt` | the paths to copy, one per line (a trailing `/` copies a whole directory) |
| `scripts/sync.sh` | copies them from an extracted source into this repository; never runs anything it fetched |
| `.github/workflows/sync.yml` | weekly, or from the Actions tab with an optional tag, branch or sha: fetches project-standards' latest release and commits any change to `main` |

To pick up a new release now: Actions → **Sync from project-standards** → Run workflow. To sync from a local checkout:

```sh
scripts/sync.sh ~/code/project-standards "local ($(git -C ~/code/project-standards rev-parse --short HEAD))"
```

To mirror another file (`SECURITY.md`, `CONTRIBUTING.md`), add it to project-standards first, then its path to `sync.txt`.
