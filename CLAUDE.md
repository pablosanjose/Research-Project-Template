# Working on this research project

This repository (on GitHub) holds the research behind a paper: the Julia package with the
models, the simulation jobs, and the analysis that turns data into figures. Two things live
inside it but are **not part of it** (both are gitignored):

- `manuscript/`: a separate Git clone of the paper's Overleaf project, with its own rules.
- `data/`: simulation results, synced from the cluster with `syncdata.sh` (a link to storage on the cluster).

```text
simulations/            Julia package MyPaperPackage (environment: --project=simulations)
  src/                  models and computations: everything that defines *what* is computed
  test/                 tests for the package
  run/                  Slurm job scripts (job.example.jl), submitted from the repository root
  out/                  Slurm logs (temporary)
analysis/               plotting environment (--project=analysis)
  plots.example.jl      figure builders: data as positional arguments, looks as keywords
  output/               generated figures
syncdata.sh, .conf      data transfer with the cluster
```

Rules marked **(always)** cannot be overridden, not even by personal instructions.

## 1. Read first

1. Personal preferences: read `CLAUDE.local.md` or `.claude/CLAUDE.local.md` here if either exists.
2. If `manuscript/` exists, its rules apply to everything inside it:

@manuscript/.claude/CLAUDE.md

   Inside `manuscript/`, the paths in those rules are relative to `manuscript/`, its personal
   file is `manuscript/.claude/CLAUDE.local.md`, and its Git commands run as `git -C manuscript …`.
   The manuscript syncs with Overleaf through GitDoc on every save; never commit or push it unless asked.

## 2. Git for this repository (always)

- Start every task with `git status`. Commit or push only when the user asks, with a clear message.
- Never force-push, rebase, amend, `reset --hard` or `git clean`. Create branches only when asked.
- Never commit anything under `data/` or `manuscript/`, generated output, or large files (over ~10 MB).
- Commit `Project.toml` and `Manifest.toml` together whenever dependencies change.

## 3. Data (always)

- Never modify, move or delete anything in `data/`: it is written only by simulation jobs.
- `./syncdata.sh` pulls data from the cluster; run it when asked. Never run `./syncdata.sh --push`.

## 4. Julia

- Always use the project environments: `--project=simulations` for the package and jobs,
  `--project=analysis` for plots. Never add packages to the global environment.
- Add a dependency only to the environment that needs it, with `Pkg`, never by editing TOML files.
- Model code belongs in `simulations/src/`; job and plotting scripts only call package functions.
- After changing `simulations/src/`, run the tests: `julia --project=simulations -e 'using Pkg; Pkg.test()'`.
- Job scripts run from the repository root and save to `data/<script name>.<what>.jld2`, with `meta`
  recording the Git commit. Before a production run, commit the code so `meta.gitdirty` is false.
- Never submit Slurm jobs (`sbatch`) or start long computations unless the user asks.

## 5. Figures

- Figure builders in `analysis/` take data as positional arguments and visual options as keywords,
  and save to `analysis/output/`.
- Copy a figure into `manuscript/figures/` only when asked; that is a change to the manuscript, so
  mention it, and say whether the figure's data came from committed code.

## 6. How to work

- For anything global (renaming the package, restructuring code, changes across many files),
  first give the user a short plan and wait for approval.
- Change only what was asked. Keep the authors' code style.
