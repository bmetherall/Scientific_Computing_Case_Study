## Animation

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

## 3D Plot
# reset

# set terminal epslatex color size 5.0in,3.125in standalone font 12

# load 'Data/Viridis.p'

# set grid
# set xyplane 0
# set view 60, 320

# set xl '$x$' offset 0.25, -0.25
# set yl '$y$' offset -0.25, -0.25
# set zl '$u$' offset 3, 0
# set cbl'$T$ $(\times 100)$' offset 0.5, 0

# set tics out
# set cbtics in

# set cbtics 2
# set xtics offset 0.25, -0.25
# set ytics offset -0.25, -0.35
# set ztics offset 0.3, 0
# set cbtics offset -0.25, 0

# set xr [0:5.25]

# set pm3d
# set pm3d interpolate 0, 0

# set output 'Coupled.tex'
# 	set multiplot
# 	set size 1.04, 1.2
# 	set origin -0.03, -0.1
# 	sp 'Coupled_Solution_Long.dat' u 1:2:3:(100*$4) w l lc 8 lw 0.1 not
# 	unset multiplot
# set out


## 2D Plot
# reset
# set terminal epslatex color size 4.0in,3.5in standalone font 12

# load 'Data/Viridis.p'

# set pm3d
# set pm3d interpolate 0,0
# set view map
# set grid

# set format x '%.1f'
# set format y '%.1f'
# set format cb '%.1f'

# set xl '$x$'
# set yl rotate by 0 '$y$'
# set cbl '$v$ $(\times 100)$'

# set size ratio -1

# set contour
# set cntrparam levels incremental 2, 0.2, 4
# unset cl

# set lmargin screen 0.0

# unset surface

# set output 'Flat.tex'
# 	sp 'Data/pde_solution10001.dat' matrix u ($1/50):($2/50):(100*$3) w l lc 8 lw 0.25 not
# set out

## Coupled Convergence
# reset
# set terminal epslatex color size 5.0in,3.125in standalone font 12

# set grid

# set xtics 20000

# set xl 'Time Steps'
# set yl 'Relative Difference'

# set format x '$%.0t\cdot10^{%01T}$'
# set format y '$10^{%01T}$'

# set logscale y

# set output 'Coupled_Convergence.tex'
# 	p 'Convergence.dat' u 1:2 w l lw 3 t 'Potential', \
# 	'' u 1:3 w l dt 5 lw 3 t 'Temperature'
# set out

