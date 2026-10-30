#!/usr/bin/env -S julia --project=simulations
#
# Example job: computes a 2D sweep and saves it to data/job.example.fig1.jld2.
# Data files are named after the script, so copy it under a new name and edit the
# computation; nothing else needs renaming (e.g. job.jl writes data/job.fig1.jld2).
#
# Run from the repository root:   sbatch simulations/run/job.example.jl
#
#SBATCH --partition=express
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --output=simulations/out/%x-%j.out

## Preamble
    isdir("simulations") || error("Run from the repository root, e.g. sbatch simulations/run/job.example.jl")

    # This script's name without .jl (here "job.example"). Under sbatch the job name defaults to the
    # script's file name, so leave out --job-name above or this name changes with it.
    const NAME = first(splitext(get(ENV, "SLURM_JOB_NAME", basename(PROGRAM_FILE))))

    # Install missing packages and precompile, once, before starting workers
    # (a quick no-op when nothing changed; needs internet only after a Manifest change)
    using Pkg
    Pkg.instantiate()
    Pkg.precompile()

    using JLD2
    using Distributed

    # One worker per Slurm task (minus this main process); outside Slurm, one per CPU thread.
    ntasks = parse(Int, get(ENV, "SLURM_NTASKS", string(Sys.CPU_THREADS)))
    addprocs(max(ntasks - nworkers(), 1); exeflags = "--project=$(Base.active_project())")

    @everywhere begin
        using MyPaperPackage
        using LinearAlgebra
        BLAS.set_num_threads(1)     # one BLAS thread per worker, to avoid oversubscribing cores
    end

## Metadata: which code produced this data
    gitcommit = try readchomp(`git rev-parse --short HEAD`) catch; "unknown" end
    gitdirty = try !isempty(readchomp(`git status --porcelain -- simulations`)) catch; true end
    meta = (; gitcommit, gitdirty, julia = string(VERSION), date = Libc.strftime("%Y-%m-%d %H:%M", time()),
              host = gethostname(), workers = nworkers(), job = get(ENV, "SLURM_JOB_ID", "local"))

## Figure 1
    xs = range(-1, 1, length = 200)
    ys = range(-1, 1, length = 200)

    outfile = joinpath("data", "$NAME.fig1.jld2")
    jldsave(outfile; xs, ys, meta)          # axes and metadata first

    cases = [
        # name         keyword arguments for the model in MyPaperPackage
        ("clean",      (; disorder = 0.0)),
        ("disordered", (; disorder = 0.1)),
    ]

    for (name, kw) in cases
        @everywhere model = MyPaperPackage.build_model(; $kw...)
        result = pmap(((x, y),) -> MyPaperPackage.observable(model, x, y), tuple.(xs, ys'))
        jldopen(outfile, "a+") do f         # reopen the file, add this case, close it again:
            f[name] = result                # each case is saved as soon as it is ready
        end
    end

# Loading the results later, e.g. in analysis/ (paths from the repository root):
#   using JLD2
#   xs, ys, meta = load("data/job.example.fig1.jld2", "xs", "ys", "meta")
#   clean        = load("data/job.example.fig1.jld2", "clean")      # one case
#   everything   = load("data/job.example.fig1.jld2")               # Dict of all entries: everything["disordered"]
