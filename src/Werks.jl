module Werks

using ArchGDAL
using CSV
using DataFrames
using Dates
using GeoInterface
using GeoJSON
using JSON3
using Pkg
using Plots
using Statistics
using Polynomials

export add_col_totals, add_row_totals, add_totals
export drop_first, drop_last, head, tail
export dms_to_decimal, count_coords, intersect_multipolygons
export cleveland_dot_plot, convert_to_integer!, gini
export create_bullseye_map, get_package_uuids

"""
    add_col_totals(df::DataFrame; 
                  total_col_name="Total",
                  cols_to_sum=nothing)
    
Add a column of row totals to a DataFrame.

# Arguments
- `df`: Input DataFrame
- `total_col_name`: Name for the new column with row totals (default: "Total")
- `cols_to_sum`: Columns to include in summation (default: all numeric columns)

# Returns
- A new DataFrame with an additional column containing row totals
"""
function add_col_totals(df::DataFrame; 
                      total_col_name="Total",
                      cols_to_sum=nothing)
    
    # Create a copy of the input dataframe
    result_df = copy(df)
    
    # Determine which columns to sum
    if isnothing(cols_to_sum)
        cols_to_sum = names(df)[eltype.(eachcol(df)) .<: Number]
    end
    
    # Add column with row totals
    if !isempty(cols_to_sum)
        result_df[!, total_col_name] = sum.(eachrow(result_df[:, cols_to_sum]))
    end
    
    return result_df
end

"""
    add_row_totals(df::DataFrame; 
                  total_row_name="Total",
                  cols_to_sum=nothing)
    
Add a row of column totals to a DataFrame.

# Arguments
- `df`: Input DataFrame
- `total_row_name`: Label for the row with column totals (default: "Total")
- `cols_to_sum`: Columns to include in summation (default: all numeric columns)

# Returns
- A new DataFrame with an additional row containing column totals
"""
function add_row_totals(df::DataFrame; 
                      total_row_name="Total",
                      cols_to_sum=nothing)
    
    # Create a copy of the input dataframe
    result_df = copy(df)
    
    # Determine which columns to sum
    if isnothing(cols_to_sum)
        cols_to_sum = names(df)[eltype.(eachcol(df)) .<: Number]
    end
    
    # Create a new row with column totals
    new_row = Dict{Symbol, Any}()
    
    # For each column in the dataframe
    for col in names(df)
        if col in cols_to_sum
            # Sum numeric columns
            new_row[Symbol(col)] = sum(skipmissing(df[!, col]))
        else
            # Use the margin name for non-numeric columns
            new_row[Symbol(col)] = total_row_name
        end
    end
    
    # Append the totals row
    push!(result_df, new_row)
    
    return result_df
end

"""
    add_totals(df::DataFrame; 
              total_row_name="Total", 
              total_col_name="Total",
              cols_to_sum=nothing)
    
Add both row and column totals to a DataFrame.

# Arguments
- `df`: Input DataFrame
- `total_row_name`: Label for the row with column totals (default: "Total")
- `total_col_name`: Name for the column with row totals (default: "Total")
- `cols_to_sum`: Columns to include in summation (default: all numeric columns)

# Returns
- A new DataFrame with both row and column totals added
"""
function add_totals(df::DataFrame; 
                  total_row_name="Total", 
                  total_col_name="Total",
                  cols_to_sum=nothing)
    
    # First add column of row totals
    result_df = add_col_totals(df; total_col_name=total_col_name, cols_to_sum=cols_to_sum)
    
    # Then add row of column totals, including the new total column
    result_df = add_row_totals(result_df; total_row_name=total_row_name, cols_to_sum=cols_to_sum)
    
    # Update the grand total (bottom-right cell)
    if !isnothing(cols_to_sum) && !isempty(cols_to_sum)
        result_df[end, total_col_name] = sum(result_df[1:end-1, total_col_name])
    end
    
    return result_df
end

"""
    drop_first(df::DataFrame, n::Int=1)

Delete the first n rows of a DataFrame.

# Arguments
- `df`: Input DataFrame
- `n`: Number of rows to delete (default: 1)

# Returns
- A new DataFrame with the first n rows removed
"""
function drop_first(df::DataFrame, n::Int=1)
    n = min(n, nrow(df))
    return n == nrow(df) ? DataFrame(names(df) .=> [[] for _ in names(df)]) : df[n+1:end, :]
end

"""
    drop_last(df::DataFrame, n::Int=1)

Delete the last n rows of a DataFrame.

# Arguments
- `df`: Input DataFrame
- `n`: Number of rows to delete (default: 1)

# Returns
- A new DataFrame with the last n rows removed
"""
function drop_last(df::DataFrame, n::Int=1)
    n = min(n, nrow(df))
    return n == nrow(df) ? DataFrame(names(df) .=> [[] for _ in names(df)]) : df[1:end-n, :]
end

"""
    head(df::DataFrame, n::Int=6)

Display the first n rows of a DataFrame.

# Arguments
- `df`: Input DataFrame
- `n`: Number of rows to display (default: 6)

# Returns
- A new DataFrame containing the first n rows
"""
function head(df::DataFrame, n::Int=6)
    n = min(n, nrow(df))
    return df[1:n, :]
end

"""
    tail(df::DataFrame, n::Int=6)

Display the last n rows of a DataFrame.

# Arguments
- `df`: Input DataFrame
- `n`: Number of rows to display (default: 6)

# Returns
- A new DataFrame containing the last n rows
"""
function tail(df::DataFrame, n::Int=6)
    n = min(n, nrow(df))
    return df[end-n+1:end, :]
end

# Get the UUID of a registered package
function get_package_uuids(pkg_names::Vector{String})
    result = Dict{String, Base.UUID}()
    
    for (uuid, pkg) in Pkg.dependencies()
        if pkg.name in pkg_names
            result[pkg.name] = uuid
        end
    end
    
    return result
end

"""
    get_package_uuids(pkg_names::Vector{String}) -> Dict{String, UUID}

Get UUIDs for multiple package names.

# Arguments
- `pkg_names`: Vector of package names to find UUIDs for

# Returns
- Dictionary with package names as keys and UUIDs as values
- Any package names not found in dependencies will not be included in the result

# Example
```julia
uuids = get_package_uuids(["DataFrames", "CSV", "Plots"])
```
"""
function get_package_uuids(pkg_names::Vector{String})
    result = Dict{String, Base.UUID}()
    
    for (uuid, pkg) in Pkg.dependencies()
        if pkg.name in pkg_names
            result[pkg.name] = uuid
        end
    end
    
    return result
end

function filter_dataframes()
    # Get variable names in the current namespace
    df_names = filter(name -> isa(getfield(Main, name), DataFrame), names(Main))
    return df_names
end

"""
    create_bullseye_map(capital_name::String, capital_coords::String, 
                      file_path::String="bullseye.html", 
                      bands::String="50, 100, 200",
                      color_scheme::Int=4)

Creates an HTML file with a Leaflet map showing concentric circles around a center point.

# Arguments
- `capital_name`: Name of the central location to display in popup
- `capital_coords`: Coordinates of the center point in DMS format
- `file_path`: Path to save the HTML file (default: "bullseye.html")
- `bands`: Comma-separated distances for the concentric circles in miles (default: "50, 100, 200")
- `color_scheme`: Index of the color palette to use (1-5, default: 4)

# Returns
- Path to the created HTML file
"""
function create_bullseye_map(capital_name::String, capital_coords::String, 
                           file_path::String="bullseye.html", 
                           bands::String="50, 100, 200",
                           color_scheme::Int=4)
    
    pal = ("'Red', 'Green', 'Yellow', 'Blue', 'Purple'",
        "'#E74C3C', '#2ECC71', '#3498DB', '#F1C40F', '#9B59B6'",
        "'#FF4136', '#2ECC40', '#0074D9', '#FFDC00', '#B10DC9'",
        "'#D32F2F', '#388E3C', '#1976D2', '#FBC02D', '#7B1FA2'",
        "'#FF5733', '#C70039', '#900C3F', '#581845', '#FFC300'")
    
    centerpoint = dms_to_decimal(capital_coords)
    from = capital_name
    band_colors = pal[color_scheme]
    
    bullseye = """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Leaflet Template</title>
      <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
      <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
      <style>
        body, html {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
        }
        .flex-container {
            display: flex;
            align-items: flex-start;
            width: 100%;
            height: 100%;
        }
        #map {
            flex: 1;
            height: 100vh;
            margin: 0;
        }
        .tables-container {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            padding: 20px;
        }
        table {
            border-collapse: collapse;
            width: 200px;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: right;
        }
        .legend {
            padding: 6px 8px;
            background: white;
            background: rgba(255,255,255,0.9);
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
            border-radius: 5px;
            line-height: 24px;
        }
    </style>
    </head>
    <body>
    <div class="flex-container">
      <div id="map">
      </div>
      <div class="tables-container">
      </div>
    </div>
    <script>
    var mapOptions = {
       center: [$centerpoint],
       zoom: 7
    };
    var map = new L.map('map', mapOptions);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
        maxZoom: 19
    }).addTo(map);

    var marker = L.marker([$centerpoint]);
    marker.addTo(map);
    marker.bindPopup('$from').openPopup();

    function milesToMeters(miles) {
       return miles * 1609.34;
    }

    var colors = [$band_colors];
    var radii = [$bands].map(Number);

    radii.forEach(function(radius, index) {
        var circle = L.circle([$centerpoint], {
            radius: milesToMeters(radius),
            color: colors[index],
            weight: 2,
            fill: true,
            fillColor: colors[index],
            fillOpacity: 0.05,
            interactive: false
        }).addTo(map);
        console.log('Added circle:', radius, 'miles');
    });

    var legend = L.control({position: 'bottomleft'});
    legend.onAdd = function (map) {
        var div = L.DomUtil.create('div', 'legend');
        div.innerHTML = '<strong>Miles from center</strong><br>';
        radii.forEach(function(radius, i) {
            div.innerHTML +=
                '<i style="background:' + colors[i] + '; width: 18px; height: 18px; float: left; margin-right: 8px; opacity: 0.7;"></i> ' +
                radius + '<br>';
        });
        return div;
    };
    legend.addTo(map);

    // Add resize handler to ensure map fills container after window resize
    window.addEventListener('resize', function() {
        map.invalidateSize();
    });
    </script>
    </body>
    </html>
    """

    open(file_path, "w") do file
        write(file, bullseye)
    end
    
    return file_path
end

"""
    dms_to_decimal(coords::AbstractString) -> AbstractString

Convert latitude and longitude coordinates from degrees, minutes, seconds (DMS) format 
to decimal degrees (DD) format as a string.

# Arguments
- `coords`: A string representing the latitude and longitude coordinates in the format 
  "41° 15′ 31″ N, 95° 56′ 15″ W".

# Returns
- A string containing the latitude and longitude coordinates in decimal degrees format,
  separated by a comma, e.g., "41.258611111, -95.9375".

# Example
```julia
coord  = "52.189902,-1.607106"
result = dms_to_decimal(coords)
println(result)  # Output: "41.258611111111111, -95.9375"
"""
function dms_to_decimal(coord::AbstractString)
    # Split the input string into latitude and longitude parts
    lat_dms, lon_dms = split(coord, ",")
    
    # Helper function to convert DMS to decimal
    function to_decimal(dms::AbstractString)
        # Remove any extra whitespace
        dms = strip(dms)
        
        # Extract the degree, minute, and second values
        deg, min, sec, dir = match(r"(\d+).\s*(\d+)′\s*(\d+(?:\.\d+)?)″\s*([NSEW])", dms).captures
        
        # Convert the values to floats
        deg = parse(Float64, deg)
        min = parse(Float64, min)
        sec = parse(Float64, sec)
        
        # Calculate the decimal degrees
        decimal = deg + (min / 60) + (sec / 3600)
        
        # Adjust the sign based on the direction
        decimal *= (dir == "S" || dir == "W") ? -1 : 1
        
        return decimal
    end
    
    # Convert latitude and longitude to decimal degrees
    lat_decimal = to_decimal(lat_dms)
    lon_decimal = to_decimal(lon_dms)
    
    # Format the output string
    result = "$(lat_decimal), $(lon_decimal)"
    
    return result
end

function count_coords(geometry)
    # Get coordinates array from GeoJSON geometry
    coords = GeoInterface.coordinates(geometry)
    
    # For MultiPolygon, first level is array of polygons
    first_poly = first(coords)
    # For Polygon, first level is array of rings
    first_ring = first(first_poly)
    
    return length(first_ring)
end

function intersect_multipolygons(geojson1::String, geojson2::String)
    # Parse strings into GeoJSON geometry objects
    mp1 = GeoJSON.read(geojson1)
    mp2 = GeoJSON.read(geojson2)
    
    # Create ArchGDAL geometries
    geom1 = ArchGDAL.creategeom(ArchGDAL.wkbMultiPolygon)
    geom2 = ArchGDAL.creategeom(ArchGDAL.wkbMultiPolygon)
    
    # Add the polygon geometries from GeoJSON to ArchGDAL geometries
    for coords in GeoInterface.coordinates(mp1)
        poly = ArchGDAL.creategeom(ArchGDAL.wkbPolygon)
        for ring_coords in coords
            ring = ArchGDAL.creategeom(ArchGDAL.wkbLinearRing)
            for (x, y) in ring_coords
                ArchGDAL.addpoint!(ring, x, y)
            end
            # Ensure ring is closed
            first_point = first(ring_coords)
            if first_point != last(ring_coords)
                ArchGDAL.addpoint!(ring, first_point[1], first_point[2])
            end
            ArchGDAL.addgeom!(poly, ring)
        end
        ArchGDAL.addgeom!(geom1, poly)
    end
    
    for coords in GeoInterface.coordinates(mp2)
        poly = ArchGDAL.creategeom(ArchGDAL.wkbPolygon)
        for ring_coords in coords
            ring = ArchGDAL.creategeom(ArchGDAL.wkbLinearRing)
            for (x, y) in ring_coords
                ArchGDAL.addpoint!(ring, x, y)
            end
            # Ensure ring is closed
            first_point = first(ring_coords)
            if first_point != last(ring_coords)
                ArchGDAL.addpoint!(ring, first_point[1], first_point[2])
            end
            ArchGDAL.addgeom!(poly, ring)
        end
        ArchGDAL.addgeom!(geom2, poly)
    end
    
    # Perform intersection
    intersection = ArchGDAL.intersection(geom1, geom2)
    
    # Convert result back to GeoJSON dictionary format
    result_coords = []
    for i in 1:ArchGDAL.ngeom(intersection)
        poly = ArchGDAL.getgeom(intersection, i-1)
        poly_coords = []
        for j in 1:ArchGDAL.ngeom(poly)
            ring = ArchGDAL.getgeom(poly, j-1)
            # Get coordinates directly from the ring
            num_points = count_coords(ring)
            ring_coords = []
            for k in 0:(num_points-1)
                x = ArchGDAL.getx(ring, k)
                y = ArchGDAL.gety(ring, k)
                push!(ring_coords, [x, y])
            end
            push!(poly_coords, ring_coords)
        end
        push!(result_coords, poly_coords)
    end
    
    result_dict = Dict(
        "type" => "MultiPolygon",
        "coordinates" => result_coords
    )
    
    return JSON3.write(result_dict)
end

# Example usage:
multipolygon1 = """
{
    "type": "MultiPolygon",
    "coordinates": [[[[0,0], [0,2], [2,2], [2,0], [0,0]]]]
}"""

multipolygon2 = """
{
    "type": "MultiPolygon",
    "coordinates": [[[[1,1], [1,3], [3,3], [3,1], [1,1]]]]
}"""

"""
    cleveland_dot_plot(df::DataFrame, value_col::Symbol, label_col::Symbol; 
                      xlabel::String="", title::String="Cleveland Dot Plot")

Create a Cleveland dot plot with polynomial trend line and reference features.

# Arguments
- `df::DataFrame`: Input DataFrame containing the data
- `value_col::Symbol`: Column name for the values to be plotted on x-axis
- `label_col::Symbol`: Column name for the labels to be shown on y-axis
- `xlabel::String`: Label for x-axis (default: "")
- `title::String`: Title for the plot (default: "Cleveland Dot Plot")

# Features
- Sorts data by value in descending order
- Adds a 3rd-degree polynomial trend line
- Shows 80% threshold line
- Includes reference lines to y-axis
- Formats x-axis labels in thousands (K)

# Returns
- A Plots.Plot object

# Example
p = cleveland_dot_plot(ne_pop, :total_population, :name, 
                      xlabel="Population", 
                      title="Population of New England Counties")
"""
function cleveland_dot_plot(df::DataFrame, 
                          value_col::Symbol, 
                          label_col::Symbol;  
                          xlabel::String="",
                          title::String="Cleveland Dot Plot")
    
    # Drop any rows with missing values and sort
    df_clean  = dropmissing(df, [value_col, label_col])
    df_sorted = sort(df_clean, value_col, rev=true)
    
    # Calculate 80% threshold using non-missing values
    value_threshold = sum(skipmissing(df_clean[:, value_col])) * 0.8
    
    # Create positions array for curve fitting
    positions = 1:nrow(df_sorted)
    values    = collect(df_sorted[:, value_col])
    
    # Fit polynomial curve
    poly_fit  = Polynomials.fit(positions, Float64.(values), 3)
    
    # Create interpolated points for smoother curve
    x_smooth  = range(1, nrow(df_sorted), length=100)
    y_smooth  = poly_fit.(x_smooth)
    
    # Fixed x-axis limits
    x_min = 0
    x_max = 1_600_000
    
    p = Plots.plot(
        values,
        positions,
        seriestype = :scatter,
        marker     = (:circle, 8),
        color      = :blue,
        legend     = false,
        xlabel     = xlabel,
        title      = title,
        yticks     = (1:nrow(df_sorted), df_sorted[:, label_col]),
        yflip      = true,
        grid       = (:x, :gray, 0.2),
        size       = (1000, max(400, 20 * nrow(df_sorted))),
        margin     = 25mm,
        xlims      = (x_min, x_max),
        xticks     = 0:200_000:1_600_000,
        formatter  = :plain,
        xformatter = x -> string(round(Int, x/1000), "K")
    )
    
    # Add the fitted curve
    Plots.plot!(y_smooth, x_smooth, 
        color     = :red, 
        linewidth = 2, 
        alpha     = 0.6,
        label     = "Trend"
    )
    
    # Add vertical line at 80% threshold
    Plots.vline!([value_threshold], 
        color     = :green, 
        linewidth = 2, 
        linestyle = :dash,
        label     = "80% of Total"
    )
    
    # Add reference lines connecting to y-axis
    for i in 1:nrow(df_sorted)
        Plots.plot!(
            [0, values[i]], 
            [i, i], 
            color     = :gray, 
            alpha     = 0.3,
            linewidth = 0.5
        )
    end
    
    return p
end

function convert_to_integer!(df::DataFrame, column::Symbol)
    # Replace commas and convert to integer
    df[!, column] .= parse.(Int, replace.(df[!, column], "," => ""))
end

function gini(v::Vector{Int})
    # Ensure the input vector is sorted
    sorted_v = sort(v)
    
    # Calculate the cumulative sum of the sorted vector
    S = cumsum(sorted_v)
    
    # Calculate the Gini coefficient using the formula
    n = length(v)
    numerator = 2 * sum(i * y for (i, y) in enumerate(sorted_v))
    denominator = n * sum(sorted_v)
    
    # Return the Gini coefficient
    return (numerator / denominator - (n + 1)) / n
end

end # module Werks