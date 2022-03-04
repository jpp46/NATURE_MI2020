# plot.gnu
set terminal qt size 600,400 enhanced font 'Verdana,12'

# Set line styles to blue (#0060ad), red (#dd181f), green (#00FF00)
set style line 1 \
    linecolor rgb '#0060ad' \
    linetype 1 linewidth 2 \
    #pointtype 0
set style line 2 \
    linecolor rgb '#dd181f' \
    linetype 1 linewidth 2 \
    #pointtype 0
set style line 3 \
    linecolor rgb '#00FF00' \
    linetype 1 linewidth 2 \
    #pointtype 0

# Legend
set key bottom right
# Axes label
set xlabel 'Generations'
set ylabel 'Normalized Mean vs Max Fitness'
# Axes tics
set tics scale 1
unset xtics

set output "graphs/flat.png"
set title "Flat Surface"
set xrange [0:200]
set yrange [0.2:1.01]
set style fill transparent solid 0.15 # partial transparency
set style fill noborder # no separate top/bottom lines
plot \
	'data/mean_results.dat' index 0 using 1:3:4 with filledcurves lc "blue" notitle, \
    '' index 1 using 1:3:4 with filledcurves lc "green" notitle, \
    '' index 2 using 1:3:4 with filledcurves lc "red" notitle, \
    \
    '' index 0 using 1:2 with lines lc "blue" title "Orientation, Shape, Control", \
    '' index 1 using 1:2 with lines lc "green" title "Shape, Control", \
    '' index 2 using 1:2 with lines lc "red" title "Control", \
    'data/max_results.dat' index 0 using 1:2 with lines lc "blue" dashtype '--' notitle, \
    '' index 1 using 1:2 with lines lc "green" dashtype '--' notitle, \
    '' index 2 using 1:2 with lines lc "red" dashtype '--' notitle

set output "graphs/hill.png"
set title "Inclined Surface"
set xrange [0.2:200]
set yrange [0.7:1.01]
set xlabel 'Generations'
set ylabel 'Normalized Mean vs Max Fitness'
unset ylabel
set style fill transparent solid 0.15 # partial transparency
set style fill noborder # no separate top/bottom lines
plot \
    'data/mean_results.dat' index 3 using 1:3:4 with filledcurves lc "blue" notitle, \
     '' index 4 using 1:3:4 with filledcurves lc "green" notitle, \
     '' index 5 using 1:3:4 with filledcurves lc "red" notitle, \
     \
     '' index 3 using 1:2 with lines lc "blue" title "Orientation, Shape, Control", \
     '' index 4 using 1:2 with lines lc "green" title "Shape, Control", \
     '' index 5 using 1:2 with lines lc "red" title "Control", \
     'data/max_results.dat' index 3 using 1:2 with lines lc "blue" dashtype '--' notitle, \
    '' index 4 using 1:2 with lines lc "green" dashtype '--' notitle, \
    '' index 5 using 1:2 with lines lc "red" dashtype '--' notitle



