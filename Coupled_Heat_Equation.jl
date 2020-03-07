
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

	M = trunc(Int, 5.25 / h + 1) # Apsect ratio of domain
	M_left = trunc(Int, M / 3.0)
	M_right = trunc(Int, 2 * M / 3.0)
	N_mid = trunc(Int, N / 2.0)
	
	# define list, will be filled with N_times matrices, each matrix corresponding to one spatial slice at constant t
	potential = []
	temperature = []

	u_current = zeros((M, N))
	theta_current = zeros((M, N))
	
	# compute solutions by stepping through time
    for t = 1:N_time
        
        if mod(t, 250) == 0
            println(t)
        end

		u_current = zeros((M, N))
		theta_current = zeros((M, N))

		# compute initial values at t = 0 via v_0
		if t == 1
			for m = 1:M, n = 1:N
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
			
			# Interior points
            for m = 2:M-1
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
				# Left Boundary
				u_current[1,n] = 0.0
				theta_current[1,n] = 0.0
				# Right Boundary
				u_current[M,n] = (4*u_current[M-1,n] - u_current[M-2,n])/(3 + (2*h*beta/alpha(theta_old[M,n])))
				theta_current[M,n] = (4*theta_current[M-1,n] - theta_current[M-2,n])/(3 + (2*h*beta/alpha(theta_old[M,n])))
			end
			
			# Bottom Boundary
			for m = 2:M-1
				u_current[m,1] = -(u_current[m,3] - 4*u_current[m,2])/(3 + (2*h*beta/alpha(theta_old[m,1])))
				theta_current[m,1] = -(theta_current[m,3] - 4*theta_current[m,2])/(3 + (2*h*beta/alpha(theta_old[m,1])))
			end

			# Top Left Boundary
			for m = 2:M_left-1
				u_current[m,N] = (4*u_current[m,N-1] - u_current[m,N-2])/(3 + (2*h*beta/alpha(theta_old[m,N])))
				theta_current[m,N] = (4*theta_current[m,N-1] - theta_current[m,N-2])/(3 + (2*h*beta/alpha(theta_old[m,N])))
			end

			# Top Middle
			for m = M_left:M_right-1
				u_current[m,N_mid] = (4*u_current[m,N_mid-1] - u_current[m,N_mid-2])/(3 + (2*h*beta/alpha(theta_old[m,N_mid])))
				theta_current[m,N_mid] = (4*theta_current[m,N_mid-1] - theta_current[m,N_mid-2])/(3 + (2*h*beta/alpha(theta_old[m,N_mid])))
			end

			# Top Right Boundary
			for m = M_right:M-1 
				u_current[m,N] = 1.0
				theta_current[m,N] = 0.0
			end

			# Middle Left Boundary
			for n = N_mid:N-1
				u_current[M_left,n] = (4*u_current[M_left-1,n] - u_current[M_left-2,n])/(3 + (2*h*beta/alpha(theta_old[M_left,n])))
				theta_current[M_left,n] = (4*theta_current[M_left-1,n] - theta_current[M_left-2,n])/(3 + (2*h*beta/alpha(theta_old[M_left,n])))
			end

			# Middle Right Boundary
			for n = N_mid:N-1
				u_current[M_right,n] = -(u_current[M_right+2,n] - 4*u_current[M_right+1,n])/(3 + (2*h*beta/alpha(theta_old[M_right,n])))
				theta_current[M_right,n] = -(theta_current[M_right+2,n] - 4*theta_current[M_right+1,n])/(3 + (2*h*beta/alpha(theta_old[M_right,n])))
			end
			
			# compute values at the four corners averaging their two neighbours
			# Bottom Left
			u_current[1,1] = (u_current[1,2] + u_current[2,1])/2
			theta_current[1,1] = (theta_current[1,2] + theta_current[2,1])/2
			# Bottom Right
			u_current[1,N] = (u_current[2,N] + u_current[1,N-1])/2
			theta_current[1,N] = (theta_current[2,N] + theta_current[1,N-1])/2
			# Top Left
			u_current[M,1] = (u_current[M-1,1] + u_current[M,2])/2
			theta_current[M,1] = (theta_current[M-1,1] + theta_current[M,2])/2
			# Top Right
			u_current[M,N] = (u_current[M-1,N] + u_current[M,N-1])/2
			theta_current[M,N] = (theta_current[M-1,N] + theta_current[M,N-1])/2
		end

		# Print how it's converging
		if mod(t, 1000) == 0
			println("Potential ", sum(abs.(u_current .- u_old)))
			println("Temperature ", sum(abs.(theta_current .- theta_old)))
		end

		for m = 1:M-1
			for n = 1:N-1
				if m > M_left && m < M_right && n > N_mid
					u_current[m,n] = NaN
					theta_current[m,n] = NaN
				end
			end
		end
		        
        # store current solution
		push!(potential, u_current)
		push!(temperature, theta_current)
            
	end

	return potential, temperature

end

# define parameters

# We solve the PDE on $[0,1]^2 \times [0,T]$

N = 20 + 1 # we assume M = N and the index for our spatial points goes 1,...,N, so 2,...,N-1 are the inner spatial points
h = 1.0 / (N-1) # spatial step size

t_max = 1.0
N_time = 10000 + 1 # the index for our time points goes 1,...,N_time, so 2,...,N_time-1 are the inner time points
tau = t_max / (N_time - 1) # temporal step size

beta = 1 # we assume beta to be positive
gamma = 1 # we assume gamma to be positive

println("tau = ", tau)
println("h = ", h)

@time solve_pde(N = 6, t_max = 0.01, N_time = 2) # Compile

@time potential, temperature = solve_pde(N = N, t_max = t_max, N_time = N_time);

writedlm("Potential.dat", transpose(potential[end]), ' ')
writedlm("Temperature.dat", transpose(temperature[end]), ' ')

f = open("Coupled_Solution.dat", "w");

for i in 1:trunc(Int, 5.25 / h + 1)
	for j in 1:N
		(x, y, t) = cart_coord(i, j, 1; h = h)
		writedlm(f, [x y potential[end][i,j] temperature[end][i,j]])
	end
	println(f, "")
end

close(f)

# # Print output for plotting
# print_step = 100
# for t = 1:N_time
# 	if mod(t, print_step) == 0
# 		writedlm(string("./Data/pde_solution", t, ".dat"), pde_solution[t] , ' ')
# 	end
# end
