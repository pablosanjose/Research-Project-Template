"""
    MyPaperPackage

The models and computations behind the paper. Everything that defines *what* is computed
lives here (versioned, testable, shared by all job and plotting scripts); the scripts in
simulations/run/ and analysis/ only decide *which* cases to compute and how to plot them.
"""
module MyPaperPackage

export build_model, observable

"""
    build_model(; disorder = 0.0)

Example model: replace with the project's own model builder.
"""
build_model(; disorder = 0.0) = (; disorder)

"""
    observable(model, x, y)

Example observable: replace with the project's own computations.
"""
observable(model, x, y) = sin(3x) * cos(3y) + model.disorder * sin(17x * y)

end # module
