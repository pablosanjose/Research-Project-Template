# Research project template

Code, analysis and data workflow for a paper whose manuscript lives on Overleaf.
See the group's guide ("Overleaf + Claude") for the full walkthrough.

```text
simulations/      Julia package MyPaperPackage: src/, test/, run/ (Slurm jobs), out/ (logs)
analysis/         plotting environment: plots.example.jl, output/
data/             simulation results (gitignored): synced with ./syncdata.sh, or a link on the cluster
manuscript/       the paper: a separate clone of the Overleaf project (gitignored)
```

First, once per new project (renames the Julia package everywhere, gives it a new UUID, then deletes itself):

```bash
./rename-package.sh TwistedBilayer && git add -A && git commit -m "Rename package"
```

On Julia 1.10, also run once `cd analysis && julia --project=. -e 'using Pkg; Pkg.develop(path="../simulations")'` and commit
`analysis/Manifest.toml` (Julia 1.11+ finds the package through `[sources]` on its own).

Quick start on a laptop:

```bash
git clone git@github.com:GROUP/PROJECT.git && cd PROJECT
git clone https://git.overleaf.com/PROJECT-ID manuscript      # optional: the paper
./syncdata.sh                                                 # pull data from the cluster
julia --project=simulations -e 'using Pkg; Pkg.instantiate()'
julia --project=analysis -e 'using Pkg; Pkg.instantiate()'
```

On the cluster:

```bash
git clone git@github.com:GROUP/PROJECT.git && cd PROJECT
ln -s /storage/mygroup/myproject/data data                    # same path as REMOTE_PATH in syncdata.conf
sbatch simulations/run/job.example.jl                         # always from the repository root
```
