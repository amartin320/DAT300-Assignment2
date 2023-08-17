#!/bin/bash
## Author: Aitor Martin Rodriguez (University of Stavanger)
## This script plots the congestion window (cwnd) values over time from an iperf3 output file in json format. 
## The cwnd values are plotted over time into a PDF file, using gnuplot. 
## NOTE: This script only works on iperf3 files from produced in the sender end-host.

# Check input arguments and provide usage help
if [ $(($# < 1)) -eq 1 ]; then
	echo "missing arguments."
	echo "usage: ./plot_cwnd.sh <iperf3_data.json>"

fi

base=$(basename $1 .json)
echo $base

# Extract timestamps and cwnd values from JSON and save to a temporary file
jq -r '.intervals[].streams[0] | "\(.start) \(.snd_cwnd)"' $1 > cwnd.dat

# Generate gnuplot script to create the plot
cat > plot_cwnd.gp <<EOF
set term pdf
set grid
set output "results/${base}_cwnd.pdf"
set xlabel 'Time (seconds)'
set ylabel 'Congestion Window or cwnd (bytes)'
set title 'cwnd evolution over time'
plot 'cwnd.dat' using 1:2 pt 7 ps 0.05
EOF

cat cwnd.dat
# Generate the plot using gnuplot
gnuplot plot_cwnd.gp

# Clean up temporary files
rm cwnd.dat plot_cwnd.gp

echo "Plot created as results/${base}_cwnd.pdf"

