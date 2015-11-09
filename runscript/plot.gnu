# Comments begin with the hash/pound sign
# Tell gnuplot that you want a line graph
set style data lines

# Set the X and Y axis label
set xlabel "Number Of Containers per Server"
set ylabel "Time (seconds)"

# Make the X and Y axes be logrithmic
set nologscale x
set logscale y

set xtics 0,1

# Set the key to be in the top right of the graph
set key top right

# Output to a PDF file
set terminal dumb 
set output "out.dumb"

# Plot the data:
# The first line will take the values from the 1st and 2nd column in the
# sm-data.txt file and label the line "sm" in the key.
# Similarly, the 2nd line will be from 1st/2nd col in vader-data.txt, 
# labeled "vader" in the key.
plot times using 1:2

# Quit gnuplot
exit
