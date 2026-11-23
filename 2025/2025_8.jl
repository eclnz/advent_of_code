function parse_point(point::String)::NTuple{3, Int}
	vec_str_point = split(point, ",")
	x = parse(Int,vec_str_point[1])
	y = parse(Int,vec_str_point[2])
	z = parse(Int,vec_str_point[3])
	return (x, y, z)
end

function get_points(points::Vector{String})
	p_arr = Array{Int}(undef,3,length(points)) 
	for (p_i, point) in enumerate(points)
		p_arr[:,p_i] .= parse_point(point)
	end
	return p_arr
end

function get_diff_mat(points::Array{Int})
	dim_axes = axes(points)
	diff = Array{Int}(undef,3,maximum(dim_axes[2]),maximum(dim_axes[2]))
	for dim in dim_axes[1]
		diff[dim,:, :] .= (points[dim,:] .- points[dim,:]')
	end
    	return diff
end

function get_dist_mat(diff::Array{Int})
	dim_axes = axes(diff)
	dist = Array{Int}(undef,3,maximum(dim_axes[2]),maximum(dim_axes[2]))
	# Apply ^2
	for dim in dim_axes[1]
		dist[dim,:, :] .= diff[dim,:,:].^2
	end
	sqrt.(sum(dist, dims=1)[1,:,:])
end

function get_sorted_indices(mat::Matrix)
    mat_copy = copy(mat)
    mat_copy[mat_copy .== 0] .= Inf
    n = size(mat_copy, 1)
    inds = Vector{NTuple{2,Int}}()
    sizehint!(inds, n/2)
    @inbounds for i in 1:n
        for j in 1:i-1
            if mat_copy[i, j] != Inf
                push!(inds, (i, j))
            end
        end
    end
    sort!(inds, by = x -> mat_copy[x...])
    return inds
end


test = [
	"162,817,812", # <- 1 (1), 2
	"57,618,57",
	"906,360,560",
	"592,479,940",
	"352,342,300",
	"466,668,158",
	"542,29,236",
	"431,825,988", # <- 2 (8)
	"739,650,466",
	"52,470,668",
	"216,146,977",
	"819,987,18",
	"117,168,530",
	"805,96,715",
	"346,949,466",
	"970,615,88",
	"941,993,340",
	"862,61,35",
	"984,92,344",
	"425,690,689" # <- 1 (20)
]
arr = get_points(test)
diff = get_diff_mat(arr)
dist = get_dist_mat(diff)
inds = get_sorted_indices(dist)
