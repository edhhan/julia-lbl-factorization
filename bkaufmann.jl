using LinearAlgebra
include("max_subdiagonal.jl")

"""
Partial pivoting strategy
"""
function bkaufmann(A::Hermitian{T}) where T

    α = (1+sqrt(17))/8
    n = size(A,1)
    pivot = []

    # FIRST SEARCH : looks for the largest absolute value in the subdiagonal element of column 1 
    ω_1, r = max_subdiagonal(A, 1)
    a_11 = abs(A[1,1])
    
    # Early stopping : no pivoting required and trivial solution for the factorization (special case)
    if (ω_1 == 0)
        pivot_size = 0
        return pivot, pivot_size
    end

    # The pivot is a_11 (no pivoting)
    if a_11 >= α*ω_1
        pivot_size = 1
        append!(pivot, (1,1))
        
    else
        # SECOND SEARCH
        ω_r, r = max_subdiagonal(A, r)

        # The pivot is a_11 (no pivoting)
        if (a_11*ω_r >= α*ω_1^2) 
            pivot_size = 1
            append!(pivot, (1,1))

        # The pivot is a_rr 
        elseif abs(A[r,r]) >= α*ω_r
            pivot_size = 1
            append!(pivot, (1,r))

        # Pivoting between 2 and r (line and column)
        else
            pivot_size = 2
            append!(pivot, (2,r))
        end
    end


    return pivot, pivot_size
end
