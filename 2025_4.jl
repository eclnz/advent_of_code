function init_matrix(input::Vector{String})::Matrix{Int}
    nrow = length(input)
    ncol = last(length.(input))
    mat = zeros(Int, nrow, ncol)
    @inbounds for i in 1:nrow
        for j in 1:ncol
            c = input[i][j]
            mat[i,j] = (c == '.') ? 0 : (c == '@') ? 1 : 0
        end
    end
    return mat
end

function conv_matrix(mat::Matrix{Int})
    kernel = ones(Int, 3, 3)
    filtered_mat = zeros(Int, size(mat))
    pad = 1
    padded_mat = zeros(Int, size(mat) .+ 2*pad)
    padded_mat[1+pad:end-pad, 1+pad:end-pad] .= mat
    @inbounds for i in 1:size(mat,1)
        for j in 1:size(mat,2)
            region = padded_mat[i:i+2, j:j+2]
            filtered_mat[i, j] = sum(region .* kernel)
        end
    end
    return filtered_mat
end

is_accessible(mat::Matrix{Int}) = (conv_matrix(mat) .< 5) .* mat

function total_rolls(input::Vector{String})
    mat = init_matrix(input)
    return sum(is_accessible(mat))
end

function total_iter_rolls(input::Vector{String})
    mat = init_matrix(input)
    access_matrix = is_accessible(mat)
    accessible = sum(access_matrix)
    total_accessible = accessible
    while accessible > 0
        mat .= mat .* ((access_matrix .-1) * .-1)
        access_matrix = is_accessible(mat)
        accessible = sum(access_matrix)
        total_accessible += accessible
    end
    return total_accessible
end

@assert total_rolls(test) == 13
@assert total_iter_rolls(test) == 43

lines = readlines("input/2025_4.txt")
println(total_rolls(lines))
println(total_iter_rolls(lines))