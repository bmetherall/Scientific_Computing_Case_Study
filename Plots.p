# reset

# set terminal pngcairo color size 8.0in,8.0in lw 1

# load './Data/BGY.p'

# set grid

# set xl 'x'
# set yl 'y'
# set zl 'v'

# set cbr [0:1]
# set zr [0:1]

# set size ratio -1

# set pm3d map
# set pm3d interpolate 0, 0

# count = 0

# do for [t=1:10001:100] {
#     set output sprintf('./Frames/Frame%03.0f.png', count)
# 		sp './Data/pde_solution'.t.'.dat' matrix u ($1 / 50.0):($2 / 50.0):3 not
#     set out
# 	count = count + 1
# }

# unset size
# set xyplane 0
# set pm3d
# set pm3d interpolate 0, 0
# set view 30,40

# count = 0

# do for [t=1:10001:100] {
#     set output sprintf('./3D_Frames/Frame%03.0f.png', count)
# 		sp './Data/pde_solution'.t.'.dat' matrix u ($1 / 50.0):($2 / 50.0):3 not w l lc 8 lw 0.1
#     set out
# 	count = count + 1
# }


reset

set terminal epslatex color size 5.0in,3.125in standalone font 12

load 'Data/Viridis.p'

set grid
set xyplane 0
set view 60, 320

set xl '$x$' offset 0.25, -0.25
set yl '$y$' offset -0.25, -0.25
set zl '$u$' offset screen 0.06, 0
set cbl rotate by 0 '$T$'

set tics out
set cbtics in

set cbtics 0.02
set xtics offset 0.25, -0.25
set ytics offset -0.25, -0.35
set ztics offset 0.3, 0

set xr [0:5.25]

set pm3d
set pm3d interpolate 0, 0

set output 'Coupled.tex'
	set multiplot
	set size 0.97, 1.2
	set origin -0.03, -0.1
	sp 'Coupled_Solution_Long.dat' u 1:2:3:4 w l lc 8 lw 0.1 not
	unset multiplot
set out

#sp 'Coupled_Solution.dat' u 1:2:3 w image