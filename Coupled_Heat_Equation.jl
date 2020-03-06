
# numerical fun with Brady, Georgia and Markus USING JULIA
# insert comments and notes in this cell

using DelimitedFiles

# define initial and coefficient functions for PDE

function alpha(theta)
	"""alpha must be a continuous and strictly positive function on Omega = [0,1]^2 """
	
	return 2 - atan(2 * theta)
end

function u_0(x::Float64, y::Float64)::Float64
	"""initial function for v at t = 0. we assume that v_0 is C^1 on Omega = [0,1]^2"""
	return 0.5
end
	
# define auxiliary functions
function cart_coord(m::Int64, n::Int64, t::Int64; h::Float64 = h, tau::Float64 = tau)
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
function solve_pde(;N::Int64 = 11, t_max::Float64 = 1.0, N_time::Int64 = 1001, beta::Float64 = 1.0, gamma::Float64 = 1.0, alpha = alpha, u_0 = u_0)
	
	# define spatial and temporal stepsize
	h = 1/(N-1)
	tau = t_max/(N_time - 1)
	
	# define list, will be filled with N_times matrices, each matrix corresponding to one spatial slice at constant t
	potential = []
	temperature = []

	u_current = zeros((N, N))
	theta_current = zeros((N, N))
	
	# compute solutions by stepping through time
    for t = 1:N_time
        
        if mod(t, 250) == 0
            println(t)
        end

		u_current = zeros((N, N))
		theta_current = zeros((N, N))

		# compute initial values at t = 0 via v_0
		if t == 1
			for m = 1:N, n = 1:N
				(x,y,tt) = cart_coord(m, n, t; h = h, tau = tau)			  
				u_current[m,n] = u_0(x,y)
				theta_current[m,n] = u_0(x,y)
			end
			u_old = u_current
			theta_old = theta_current
		else
			# compute inner spatial points for t = 2
			u_old = potential[t-1]
			theta_old = temperature[t-1]
			
            for m = 2:N-1
                for n = 2:N-1
					# (x,y,tt) = cart_coord(m, n, t; h = h, tau = tau)
                    # (x_plus,y_plus,tt) = cart_coord(m + 1, n + 1, t; h = h, tau = tau)
                    # (x_minus, y_minus, tt) = cart_coord(m - 1, n - 1, t; h = h, tau = tau)
					
					# Electrical potential step
                    A = alpha(theta_old[m,n])*(u_old[m+1,n] + u_old[m-1,n] - 4*u_old[m,n] + u_old[m,n+1] + u_old[m,n-1])
                    B = (1/4)*(alpha(theta_old[m+1,n]) - alpha(theta_old[m-1,n]))*(u_old[m+1,n] - u_old[m-1,n])
                    C = (1/4)*(alpha(theta_old[m,n+1]) - alpha(theta_old[m,n-1]))*(u_old[m,n+1] - u_old[m,n-1])
                        
                    bracket = A + B + C
                        
					u_current[m,n] = u_old[m,n] + (tau/(gamma*(h^2))) * bracket
					
					# Temperature step
					A = (theta_old[m+1,n] + theta_old[m-1,n] - 4*theta_old[m,n] + theta_old[m,n+1] + theta_old[m,n-1])
					B = (1/4)*alpha(theta_old[m,n]) * ((u_old[m+1,n] - u_old[m-1,n])^2 + (u_old[m+1,n] - u_old[m-1,n])^2)
					
					theta_current[m,n] = theta_old[m,n] + (tau/(gamma * h^2)) * (A + B)
				end
			end
			
			# compute boundary values using boundary condition
			for n = 2:N-1
				(x,y,tt) = cart_coord(0, n, t; h = h, tau = tau)
				u_current[1,n] = 0.0
				u_current[N,n] = (4*u_current[N-1,n] - u_current[N-2,n])/(3 + (2*h*beta/alpha(theta_current[end,n])))
				theta_current[1,n] = 0.0
				theta_current[N,n] = (4*theta_current[N-1,n] - theta_current[N-2,n])/(3 + (2*h*beta/alpha(theta_current[end,n])))
			end
			
			for m = 2:N-1
				(x,y,tt) = cart_coord(m, 0, t; h = h, tau = tau)
				u_current[m,1] = -(u_current[m,3] - 4*u_current[m,2])/(3 + (2*h*beta/alpha(theta_current[m,1])))
				u_current[m,N] = 1.0
				theta_current[m,1] = -(theta_current[m,3] - 4*theta_current[m,2])/(3 + (2*h*beta/alpha(theta_current[m,1])))
				theta_current[m,N] = 0.0
			end
			
			# compute values at the four corners averaging their two neighbours
			u_current[1,1] = (u_current[1,2] + u_current[2,1])/2
			u_current[1,N] = (u_current[2,N] + u_current[1,N-1])/2
			u_current[N,1] = (u_current[N-1,1] + u_current[N,2])/2
			u_current[N,N] = (u_current[N-1,N] + u_current[N,N-1])/2
			
			theta_current[1,1] = (theta_current[1,2] + theta_current[2,1])/2
			theta_current[1,N] = (theta_current[2,N] + theta_current[1,N-1])/2
			theta_current[N,1] = (theta_current[N-1,1] + theta_current[N,2])/2
			theta_current[N,N] = (theta_current[N-1,N] + theta_current[N,N-1])/2
		end

		# Print how it's converging
		if mod(t, 1000) == 0
			println("Potential ", sum(abs.(u_current .- u_old)))
			println("Temperature ", sum(abs.(theta_current .- theta_old)))
		end
		        
        # store current solution
		push!(potential, u_current)
		push!(temperature, theta_current)
            
	end

	return potential, temperature

end

# define parameters

# We solve the PDE on $[0,1]^2 \times [0,T]$

N = 50 + 1 # we assume M = N and the index for our spatial points goes 1,...,N, so 2,...,N-1 are the inner spatial points
h = 1.0 / (N-1) # spatial step size

t_max = 1.0
N_time = 20000 + 1 # the index for our time points goes 1,...,N_time, so 2,...,N_time-1 are the inner time points
tau = t_max / (N_time - 1) # temporal step size

beta = 1 # we assume beta to be positive
gamma = 1 # we assume gamma to be positive

println("tau = ", tau)
println("h = ", h)

@time solve_pde(N = 2, t_max = 0.01, N_time = 2) # Compile

@time potential, temperature = solve_pde(N = N, t_max = t_max, N_time = N_time);

writedlm("Potential.dat", potential[end], ' ')
writedlm("Temperature.dat", temperature[end], ' ')

# # Print output for plotting
# print_step = 100
# for t = 1:N_time
# 	if mod(t, print_step) == 0
# 		writedlm(string("./Data/pde_solution", t, ".dat"), pde_solution[t] , ' ')
# 	end
# end
