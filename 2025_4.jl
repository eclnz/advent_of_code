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

function total_rolls(input::Vector{String})
    mat = init_matrix(input)
    conv_mat = conv_matrix(mat)
    return sum((conv_mat .< 5) .* mat)
end

total_rolls(test)

lines = readlines("input/2025_4.txt")
total_rolls(lines)