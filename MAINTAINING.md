# Maintaining the templates (window A: this GitHub template repository)

This repository is the **research project template** (Levels 2–3) and also the home of all
maintenance material for the whole paper workflow. `MAINTAINING.md` and `maintenance/` are
removed from every new project by `rename-package.sh`. Never run that script here.

To have Claude Code read this automatically in this clone, create a gitignored
`CLAUDE.local.md` at the repository root containing the single line `@MAINTAINING.md`.
(The repository's `CLAUDE.md` holds the rules for *projects made from* the template; while
maintaining, follow this file first.)

## 1. The system

| Level | What | Lives on | Template |
| --- | --- | --- | --- |
| 1. Manuscript | The paper's LaTeX, notes and marked edits | Overleaf; VS Code users clone it through Overleaf's Git integration | The Overleaf template project (window B) |
| 2. Code | Julia package, Slurm jobs, figure scripts | One private GitHub repository per project | This repository |
| 3. Data | Simulation results (~1 GB per project) | The group's own cluster; laptops pull with `syncdata.sh` | This repository |

Roles: **writer** (Level 1 only), **writer and researcher** (all levels in one VS Code window,
the paper cloned inside the research repository as `manuscript/`), **researcher** (Levels 2–3).

Two VS Code windows maintain the templates:

| Window | Folder | Maintains | Instructions |
| --- | --- | --- | --- |
| A | Clone of `github.com/pablosanjose/Research-Project-Template` (this one) | Research template, rollouts to research projects, the guide, releases | This file |
| B | Git clone of the Overleaf template project | Overleaf paper template, rollouts to papers | `maintenance/overleaf-template.md` (read there through a gitignored `CLAUDE.local.md`) |

Local paths are in `maintenance/projects.local.md` (gitignored;
copy it from `projects.local.md.example` and fill it in with the user if missing).

## 2. Design decisions for Levels 2–3 (do not undo without asking)

- The manuscript clone sits inside each research repository as `manuscript/` (gitignored here).
  In the combined window GitDoc is scoped with `"gitdoc.filePattern": "**/manuscript/**"`:
  the paper syncs to Overleaf on save; research code is committed by hand or by asking Claude.
- Julia package in `simulations/` (Julia ≥ 1.10; `analysis/Project.toml` finds it through
  `[sources]` on 1.11+, on 1.10 the owner runs `Pkg.develop(path="../simulations")` once in
  `analysis/`). `rename-package.sh` sets the package name and a fresh UUID.
- Jobs: `simulations/run/job.example.jl`, submitted with `sbatch` from the repository root.
  Instantiate and precompile in the main process before `addprocs`; one worker per Slurm task;
  results saved incrementally to `data/<script>.<what>.jld2` with `meta` (git commit, dirty
  flag, Julia version, date, host, workers, job id). Logs in `simulations/out/` are temporary.
- Figures: `analysis/plots.example.jl`, builder functions (data positional, looks as keywords),
  CairoMakie with LaTeX fonts at journal-column size, output to `analysis/output/`; copying
  into `manuscript/figures/` is manual.
- Data: `syncdata.sh` (rsync over SSH; pull by default; `--push` asks; never deletes). Shared
  settings in `syncdata.conf` (an SSH alias, never user names); personal overrides in
  `syncdata.local.conf`. On the cluster `data/` is a symlink to the project's storage.
  Assumes passwordless SSH.
- LaTeX Workshop recompiles on file change (interval 3 s) in the combined window too.
- Shell scripts must run on macOS's Bash 3.2: no `mapfile`, guard empty arrays under `set -u`.
- Everything here must stay **public-safe**: no real names, emails or affiliations (Alice/Bob
  and placeholders).

## 3. Infrastructure versus content in research projects

| Infrastructure (rolled out) | Content (never overwritten) |
| --- | --- |
| `.vscode/`, `.claude/settings.json`, `.github/`, `CLAUDE.md` (with the project's package name), `syncdata.sh`, `.gitignore` | `simulations/`, `analysis/`, `data/`, `manuscript/`, `syncdata.conf`, `README.md` |

## 4. Procedures

**Change the research template.** Edit here, then test: `shellcheck` all scripts; JSON and
TOML must parse; run `rename-package.sh` in a scratch copy (`cp -r . /tmp/t && cd /tmp/t &&
git init -q && git add -A && git commit -qm t && ./rename-package.sh TestPkg`) and check that no
`MyPaperPackage` remains and the maintenance files are gone.
Commit and push (ask first).

**Roll out to research projects** (ask first; list them from `projects.local.md`):
`maintenance/rollout-research.sh PATH`, review `git -C PATH diff` (project-specific additions
to `CLAUDE.md` would be overwritten), then commit and push in that project.

**The guide.** Two Markdown files in `maintenance/guide/`, kept in step with both templates
(window B tells the user when a Level 1 change needs a guide update here):
`overleaf-claude-guide.md`, the full guide (all levels, owner setup), and `joining-a-paper.md`,
the co-author quick-start (Level 1 only; it points to the full guide). There is no PDF version.

**Releases** (only this repository has them; ask first). A release holds four files: both
template zips and the two guide files. Build the zips from the clones:

```bash
OT=$(…path of the Overleaf template clone, from projects.local.md…)
git -C "$OT" archive --format=zip --prefix=overleaf-paper-template/ -o /tmp/overleaf-paper-template.zip HEAD   # the guide expects this folder name
git archive --format=zip --prefix=research-project-template/ -o /tmp/research-project-template.zip HEAD
gh release create vX.Y /tmp/overleaf-paper-template.zip /tmp/research-project-template.zip \
   maintenance/guide/overleaf-claude-guide.md maintenance/guide/joining-a-paper.md \
   --repo pablosanjose/Research-Project-Template --title "…" --notes "…what changed…"
```

(`git archive` takes only committed files, so commit first. To fix files in an existing
release instead: `gh release upload vX.Y FILES --clobber --repo …`.)

## 5. Known limitations and open questions

- GitDoc may miss the repository at startup (no mirror icon): GitDoc: Disable, then Enable.
  Its `excludeBranches` only works at startup and across all repositories in a window.
- Slow job start-up on the cluster may come from the Julia depot on NFS; not yet measured.
- Untested in real use: the Julia examples on the cluster, GitDoc's path scoping in the
  combined window, and the OverleafMCP route (Claude Desktop; stale-write risk).
