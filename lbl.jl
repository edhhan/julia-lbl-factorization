include("bkaufmann.jl")
include("bparlett.jl")
include("rookpivoting.jl")

using LinearAlgebra


"""
Wrapper function for pivoting strategy
"""
function pivoting(A::Hermitian{T}, strategy::String) where T

    if strategy == "rook"
        pivot, pivot_size = rook(A)
    elseif strategy == "bparlett"
        pivot, pivot_size = bparlett(A)
    elseif stragy == "bkaufmann"
        pivot, pivot_size = bkaufmann(A)
    end

    return pivot, pivot_size
end


"""
"""
function inv_E(E::AbstractMatrix{T}, s::Int) where T

    if s==1
        return 1/E
    elseif s==2
        
        # Swap diagonal-element
        temp = E[1,1]  # element A
        E[1,1] = E[2,2]
        E[2,2] = temp

        # Change sign on off diagonal
        E[1,2] = -E[1,2]
        E[2,1] = -E[2,1]
        
        return 1/det(E) * E
    end

end


"""
PAP^T = [E C^* ; C B]

LBL^* Factorization based on 
"""
function lbl(A::Hermitian{T} ; strategy::String="rook") where T

    if !(strategy in ["rook", "bparlett", "bkaufmann"])
        @error("Invalid pivoting strategy.\nChoose string::strategy ∈ {rook, bparlett, bkaufmann}.")
    end

    # Initialize matrix
    hat_A = deecopy(A)
    n = size(A)
    L = zeros(n,n)
    B = zeros(n,n)


    # Initialize loop variable : undefinite number of iteration
    s = 1

    while s <= n # s<n ?

        hat_n = size(hat_A)[1]

        # Pivoting
        pivot, pivot_size = pivoting(hat_A, strategy) 

        # Special case for E and L : skip, no permutation matrix required A = [E C^* ; C B]
        if pivot_size == 0 
            E = hat_A[1,1]
            L_special_case = vcat(1, zeros(hat_n-1)) #Special case on L

        else

            # If pivot==[(1,1)] then permutation matrix is identity, so we skip that case A = [E C^* ; C B]
            if !(pivot == [(1,1)])

                # Construct permutation matrix P
                P = Matrix(1.0*I, hat_n, hat_n)

                # p is a tuple of two indices and pivot is an array of 1 or 2 tuples p
                for p in pivot
                    idx1 = p[1]
                    idx2 = p[2]

                    # Permutation on columns
                    temp = P[:,idx1]
                    P[:, idx1] = P[:, idx2]
                    P[:, idx2] = temp

                    # Permuation on lines
                    temp = P[idx1, :]
                    P[idx1, :] = P[idx2, :]
                    P[idx2, :] = temp
                end
            end

            # With permutation get bloc-matrices from PAP^T = [E C^* ; C B]
            E = hat_A[1:pivot_size, 1:pivot_size]
            C = hat_A[(pivot_size+1):end, 1:pivot_size]
            B = hat_A[(pivot_size+1):end, (pivot_size):end]
        end

        # Construction of columns of L and B matrices
        
        
        # Special case, where s=1 and no permutation was required
        if pivot_size==0
            B[s,s] = E
            L[(n_hat+1):end,s] = L_special_case   # TODO : verify if L[n_hat:end,s] = L_special_case instead
        else
            # If pivot_size=1, then s+pivot_size-1 = s      =>     s:(s+pivot_size-1) == s:s
            # If pivot_size=2, then s+pivot_size-1 = s+1    =>     s:(s+pivot_size-1) == s:s+1
            
            B[s:(s+pivot_size-1), s:(s+pivot_size-1)] = E
            L[(n_hat+1):end, s:(s+pivot_size-1) ] = vcat(Matrix(1.0*I, pivot_size, pivot_size), C*inv_E(E, pivot_size) )
        end
         

        # Incremental step depends on the size of pivoting
        if pivot_size==1 || pivot_size==0
            s += 1
        elseif pivot_size==2
            s += 2
        end


    end


    return L,B
end



