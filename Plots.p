reset

set terminal pngcairo color size 8.0in,8.0in lw 1

load './Data/BGY.p'

set grid

set xl 'x'
set yl 'y'
set zl 'v'

set cbr [0:1]
set zr [0:1]

set size ratio -1

set pm3d map
set pm3d interpolate 0, 0

count = 0

do for [t=1:10001:100] {
    set output sprintf('./Frames/Frame%03.0f.png', count)
		sp './Data/pde_solution'.t.'.dat' matrix u ($1 / 50.0):($2 / 50.0):3 not
    set out
	count = count + 1
}

unset size
set xyplane 0
set pm3d
set pm3d interpolate 0, 0
set view 30,40

count = 0

do for [t=1:10001:100] {
    set output sprintf('./3D_Frames/Frame%03.0f.png', count)
		sp './Data/pde_solution'.t.'.dat' matrix u ($1 / 50.0):($2 / 50.0):3 not w l lc 8 lw 0.1
    set out
	count = count + 1
}
