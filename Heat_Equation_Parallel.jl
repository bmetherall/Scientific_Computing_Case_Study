
# numerical fun with Brady, Georgia and Markus USING JULIA
# insert comments and notes in this cell

using Distributed
@everywhere using DelimitedFiles
@everywhere using SharedArrays

# define initial and coefficient functions for PDE

@everywhere function alpha(x, y)
	"""alpha must be a continuous and strictly positive function on Omega = [0,1]^2 """
	
	#val = (x-1)^2 + (y-1)^2 + 1
	
	val = 1.0
	
	return val
end

@everywhere function v_0(x::Float64, y::Float64)::Float64
	"""initial function for v at t = 0. we assume that v_0 is C^1 on Omega = [0,1]^2"""
	
	val = (x-0.5)^2 + (y-0.5)^2
	
	#val = 1.0
	
	return val
end
	
# define auxiliary functions
@everywhere function cart_coord(m::Int64, n::Int64, t::Int64; h::Float64 = h, tau::Float64 = tau)
	"""Get cartesian coordinates from indices"""
	
	x = h*(m-1)
	y = h*(n-1)
	tt = tau*(t-1)
	
	return (x,y,tt)
end

# function plot_sol(S; h=h)
#	 x = 0:h:1
#	 y = x'
	
#	 z = S
#	 surf(x,y,z)
# end

# define main function
function solve_pde(;N::Int64 = 11, t_max::Float64 = 1.0, N_time::Int64 = 1001, beta::Float64 = 1.0, gamma::Float64 = 1.0, alpha = alpha, v_0 = v_0)
	
	# define spatial and temporal stepsize
	h = 1/(N-1)
	tau = t_max/(N_time - 1)
	
	# define list, will be filled with N_times matrices, each matrix corresponding to one spatial slice at constant t
	pde_solution = []
	
	# compute solutions by stepping through time
    for t = 1:N_time
        
        if mod(t, 500) == 0
            println(t)
        end

        S_current = SharedArray{Float64, 2}((N, N))

		# compute initial values at t = 0 via v_0
		if t == 1
			for m = 1:N, n = 1:N
				(x,y,tt) = cart_coord(m, n, t; h = h, tau = tau)			  
				S_current[m,n] = v_0(x,y)
			end		
		else
			# compute inner spatial points for t = 2
			S_old = pde_solution[t-1]
			
            @sync @distributed for m = 2:N-1
                for n = 2:N-1
					
                    (x,y,tt) = cart_coord(m, n, t; h = h, tau = tau)
                    (x_plus,y_plus,tt) = cart_coord(m + 1, n + 1, t; h = h, tau = tau)
                    (x_minus, y_minus, tt) = cart_coord(m - 1, n - 1, t; h = h, tau = tau)
                        
                    A = alpha(x,y)*(S_old[m+1,n] + S_old[m-1,n] - 4*S_old[m,n] + S_old[m,n+1] + S_old[m,n-1])
                        
                    B = (1/4)*(alpha(x_plus,y) - alpha(x_minus,y))*(S_old[m+1,n] - S_old[m-1,n])
                        
                    C = (1/4)*(alpha(x,y_plus) - alpha(x,y_minus))*(S_old[m,n+1]-S_old[m,n-1])
                        
                    bracket = A + B + C
                        
                    S_current[m,n] = S_old[m,n] + (tau/(gamma*(h^2))) * bracket
				end
			end
			
			# compute boundary values using boundary condition
			for n = 2:N-1
				(x,y,tt) = cart_coord(0, n, t; h = h, tau = tau)
				S_current[1,n] = -(S_current[3,n] - 4*S_current[2,n])/(3 + (2*h*beta/alpha(0,y)))
				S_current[N,n] = (4*S_current[N-1,n] - S_current[N-2,n])/(3 + (2*h*beta/alpha(1,y)))
			end
			
			for m = 2:N-1
				(x,y,tt) = cart_coord(m, 0, t; h = h, tau = tau)
				S_current[m,1] = -(S_current[m,3] - 4*S_current[m,2])/(3 + (2*h*beta/alpha(x,0)))
				S_current[m,N] = (4*S_current[m,N-1] - S_current[m,N-2])/(3 + (2*h*beta/alpha(x,1)))
			end
			
			# compute values at the four corners averaging their two neighbours
			S_current[1,1] = (S_current[1,2] + S_current[2,1])/2
			S_current[1, N] = (S_current[2,N] + S_current[1,N-1])/2
			S_current[N,1] = (S_current[N-1,1] + S_current[N,2])/2
			S_current[N,N] = (S_current[N-1,N] + S_current[N,N-1])/2	 
        end
        
        # store current solution
        push!(pde_solution, S_current)
            
	end

	return pde_solution

end

# define parameters

# We solve the PDE on $[0,1]^2 \times [0,T]$

N = 50 + 1 # we assume M = N and the index for our spatial points goes 1,...,N, so 2,...,N-1 are the inner spatial points
h = 1.0 / (N-1) # spatial step size

t_max = 1.0
N_time = 10000 + 1 # the index for our time points goes 1,...,N_time, so 2,...,N_time-1 are the inner time points
tau = t_max / (N_time - 1) # temporal step size

beta = 1 # we assume beta to be positive
gamma = 1 # we assume gamma to be positive

println("tau = ", tau)
println("h = ", h)

@time solve_pde(N = 2, t_max = 0.01, N_time = 2) # Compile

@time pde_solution = solve_pde(N = N, t_max = t_max, N_time = N_time, gamma = 10.0);

# Print output for plotting
print_step = 100
for t = 1:N_time
	if mod(t, print_step) == 1
		writedlm(string("./Data/pde_solution", t, ".dat"), pde_solution[t] , ' ')
	end
end
