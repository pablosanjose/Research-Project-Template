# Research project template

A GitHub template for the simulations behind a paper: a Julia package with the models, Slurm jobs that
run on the group's cluster, and the scripts that turn their data into figures. The manuscript lives
elsewhere (for example on Overleaf, in its own VS Code window); copy final figures into it by hand.

```text
simulations/        Julia package MyPaperPackage: src/ (models), test/, run/ (Slurm jobs), out/ (logs)
analysis/           plotting environment: plots.example.jl, output/ (generated figures)
data/               simulation results (contents gitignored): written by jobs, pulled with ./sync-data.sh
sync-data.sh, .conf data transfer between the cluster and laptops
CLAUDE.md           rules for Claude Code (and other assistants, through .github/)
```

Needs Julia 1.10 or later, Git, and passwordless SSH to the cluster.

## Start a project (project owner, once)

1. On GitHub, **Use this template → Create a new repository** (private), and clone it.
2. Rename the package and commit. The script replaces `MyPaperPackage` everywhere, gives the package a
   fresh UUID (each package needs its own, or Julia mixes them up between projects), and deletes itself:

   ```bash
   ./rename-package.sh TwistedBilayer && git add -A && git commit -m "Rename package"
   ```

3. Install both environments and commit the resulting `Manifest.toml` files, which record the exact
   package versions:

   ```bash
   julia --project=simulations -e 'using Pkg; Pkg.instantiate()'
   julia --project=analysis -e 'using Pkg; Pkg.instantiate()'
   ```

   Julia 1.11 and later find the package from `analysis/` by themselves (a `[sources]` entry). On Julia
   1.10, link it once before instantiating, and commit `analysis/Manifest.toml`:
   `cd analysis && julia --project=. -e 'using Pkg; Pkg.develop(path="../simulations")'`.

4. Point `sync-data.conf` at the repository's clone on the cluster, and commit it:

   ```bash
   REMOTE=mycluster                              # an SSH alias everyone defines in ~/.ssh/config
   REMOTE_PATH=myproject/data                    # data/ of the clone on the cluster (relative to home)
   ```

   The alias is the only thing the repository knows about the cluster; user names stay in each person's
   `~/.ssh/config`:

   ```text
   Host mycluster
       HostName login.cluster.example.org
       User alice
   ```

## On a laptop

```bash
git clone git@github.com:GROUP/PROJECT.git && cd PROJECT
julia --project=simulations -e 'using Pkg; Pkg.instantiate()'
julia --project=analysis -e 'using Pkg; Pkg.instantiate()'
./sync-data.sh                                   # pull the data from the cluster
```

| Command | Does |
| --- | --- |
| `./sync-data.sh` | Pulls new and changed files from the cluster into `data/`; never deletes anything |
| `./sync-data.sh -n` | Dry run: shows what would be copied |
| `./sync-data.sh --push` | Copies local files to the cluster, after asking (rarely needed) |

Personal settings (for example a different local folder, or a clone elsewhere on the cluster) go in
`sync-data.local.conf`, which is gitignored.
On Windows, run the script in WSL. Recent macOS versions ship a reduced `rsync`; if the script complains,
`brew install rsync`.

- **Model code** belongs in `simulations/src/`; job and plotting scripts only call package functions. After
  changing the package, run its tests: `julia --project=simulations -e 'using Pkg; Pkg.test()'`.
- **Figures.** Copy `analysis/plots.example.jl` to `plots.jl` and adapt it. Each figure is a builder function
  (data as positional arguments, looks as keywords), saved to `analysis/output/` at journal-column size with
  LaTeX fonts. `loaddata` warns if the data came from uncommitted code.
- **In VS Code,** the Julia REPL starts in the `analysis` environment; switch in the status bar.

## On the cluster

Once per person, clone the repository into your home folder, at the path set in `REMOTE_PATH`. Jobs write
their results to the clone's own `data/` folder, which the clone already contains:

```bash
git clone git@github.com:GROUP/PROJECT.git myproject && cd myproject
```

To run a computation, copy `simulations/run/job.example.jl` under a new name (say `bands.jl`) and adapt it.
Commit the code, then submit from the repository root:

```bash
sbatch simulations/run/bands.jl
```

The job installs and precompiles anything new once (so after a `git pull` there is nothing else to do),
starts one Julia worker per Slurm task, and writes `data/bands.fig1.jld2`, saving each case as soon as it is
ready. The file includes `meta`: the Git commit, whether the code had uncommitted changes, Julia version,
date, node, worker count and job ID, so every figure can be traced to the code that made it. Slurm logs go to
`simulations/out/`; they are only for monitoring and can be deleted.

At publication, archive the final data (for example on Zenodo) and cite its DOI in the paper.

## Working with Claude

Claude Code follows `CLAUDE.md`. It never touches `data/` or pushes data to the cluster, never submits jobs
or starts long computations unless asked, commits only when asked, and proposes a plan before changes across
many files. Personal preferences go in a gitignored `CLAUDE.local.md`.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Job stops with “Run from the repository root” | `cd` to the repository root, then `sbatch simulations/run/yourjob.jl` |
| Job runs but no log appears | `simulations/out/` is missing, so Slurm drops the log: `git checkout simulations/out` |
| `sync-data.sh` can't reach the cluster | Connect the VPN; check that `ssh mycluster` logs in without a password |
| “Package MyPaperPackage not found” | Run the instantiate commands; on Julia 1.10, link the package as in step 3 |
| A figure warns its data came from uncommitted code | Commit the code and rerun the job before the figure goes into the paper |
