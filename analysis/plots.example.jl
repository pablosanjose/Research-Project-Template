# Figures for the paper, from the data in data/ and the functions in MyPaperPackage.
#
# Environment: analysis/ (its Project.toml points MyPaperPackage to ../simulations).
# Copy it to a new name (e.g. plots.jl) and adapt the figures.
# Run it whole:      julia --project=analysis analysis/plots.jl
# or interactively in VS Code, one ## cell at a time (select the analysis environment first).
# Figures go to analysis/output/; copy the final ones to manuscript/figures/ by hand.
#
# Each figure has a builder function: data as positional arguments, visual options as
# keyword arguments. Tweak the look with keywords, without touching the data or the code.

## Preamble
    using CairoMakie            # vector PDFs for the paper (WGLMakie or GLMakie for interactive exploration)
    using JLD2
    using MyPaperPackage

    datadir   = joinpath(@__DIR__, "..", "data")
    outputdir = mkpath(joinpath(@__DIR__, "output"))

    set_theme!(theme_latexfonts(); fontsize = 10)   # matches LaTeX text in the paper

    # Load a data file and warn if it was computed from uncommitted code.
    function loaddata(file)
        data = load(joinpath(datadir, file))
        meta = data["meta"]
        meta.gitdirty && @warn "$file was computed with uncommitted changes (commit $(meta.gitcommit))"
        return data
    end

## Figure 1: from data computed on the cluster (simulations/run/job.example.jl)
    function figure1(xs, ys, panels...;
            titles = ("clean", "disordered"), colormap = :viridis,
            size = (246, 160), xlabel = L"x", ylabel = L"y")
        fig = Figure(; size)    # in pt when saved with pt_per_unit = 1 (246 pt = one journal column)
        for (i, (zs, title)) in enumerate(zip(panels, titles))
            ax = Axis(fig[1, i]; xlabel, ylabel, title)
            heatmap!(ax, xs, ys, zs; colormap)
            i > 1 && hideydecorations!(ax; grid = false)
        end
        return fig
    end

    d = loaddata("job.example.fig1.jld2")
    fig = figure1(d["xs"], d["ys"], d["clean"], d["disordered"]; colormap = :inferno)

    save(joinpath(outputdir, "fig1.pdf"), fig; pt_per_unit = 1)

## Figure 2: computed directly with MyPaperPackage (no data file needed)
    function figure2(xs, fs;
            color = :black, linewidth = 1.5,
            size = (246, 160), xlabel = L"x", ylabel = L"f(x)")
        fig = Figure(; size)
        ax = Axis(fig[1, 1]; xlabel, ylabel)
        lines!(ax, xs, fs; color, linewidth)
        return fig
    end

    model = MyPaperPackage.build_model(; disorder = 0.0)
    xs = range(-1, 1, length = 100)
    fs = [MyPaperPackage.observable(model, x, 0.0) for x in xs]
    fig = figure2(xs, fs; color = :crimson)

    save(joinpath(outputdir, "fig2.pdf"), fig; pt_per_unit = 1)
