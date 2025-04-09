# Werks.jl

[![Build Status](https://github.com/technocrat/Werks.jl/workflows/CI/badge.svg)](https://github.com/technocrat/Werks.jl/actions)
[![Documentation](https://github.com/technocrat/Werks.jl/workflows/Documentation/badge.svg)](https://technocrat.github.io/Werks.jl/dev/)

A collection of utility functions for data analysis and visualization in Julia.

## Features

- DataFrame utilities: adding totals, row/column operations
- GIS and spatial utilities: coordinate conversion, geometry operations
- Visualization: Cleveland dot plots, bullseye maps
- Package management utilities

## Installation

```julia
using Pkg
Pkg.add("Werks")
```

## Documentation

For full documentation, see [https://technocrat.github.io/Werks.jl/dev/](https://technocrat.github.io/Werks.jl/dev/)

## Quick Example

```julia
using Werks, DataFrames

# Create a dataframe with totals
df = DataFrame(A = [1, 2, 3], B = [4, 5, 6], C = ["a", "b", "c"])
df_with_totals = add_totals(df)

# Get UUIDs for packages
pkg_uuids = get_package_uuids(["DataFrames", "CSV", "Plots"])
```
