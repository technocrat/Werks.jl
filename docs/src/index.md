```@meta
CurrentModule = Werks
```

# Werks.jl

*A collection of utility functions for data analysis and visualization in Julia*

## Overview

Werks.jl provides a collection of utility functions for working with:

- DataFrames (adding totals, dropping rows)
- GIS and spatial data (coordinate conversion, geometry operations)
- Data visualization (Cleveland dot plots)
- Julia package management utilities

## Installation

```julia
using Pkg
Pkg.add("Werks")
```

## Quick Start

```julia
using Werks

# Example: Create a dataframe with totals
using DataFrames
df = DataFrame(A = [1, 2, 3], B = [4, 5, 6], C = ["a", "b", "c"])
df_with_totals = add_totals(df)

# Example: Get UUIDs for packages
pkg_uuids = get_package_uuids(["DataFrames", "CSV", "Plots"])

# Example: Convert DMS coordinates to decimal
coords = "41° 15′ 31″ N, 95° 56′ 15″ W"
decimal_coords = dms_to_decimal(coords)
```

## Features

- DataFrame utilities: `add_col_totals`, `add_row_totals`, `add_totals`, `drop_first`, `drop_last`, `head`, `tail`
- Coordinate conversion: `dms_to_decimal`
- GIS utilities: `count_coords`, `intersect_multipolygons`
- Visualization: `cleveland_dot_plot`, `create_bullseye_map`
- Misc utilities: `convert_to_integer!`, `gini`, `get_package_uuids`

## Authors

- [Richard Careaga](https://github.com/technocrat) 