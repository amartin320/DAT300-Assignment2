#!/bin/bash
## Author: Aitor Martin Rodriguez (University of Stavanger)
## This script plots the received data rate in Mbit/s in each time interval, from an iperf3 output file in json format. 

# Check input arguments and provide usage help
if [ $(($# < 1)) -eq 1 ]; then
	echo "missing arguments."
	echo "usage: ./plot_datarate.sh <iperf3_sender_data.json>"

fi

base=$(basename $1 .json)

mbps=$(jq -r '.end.sum_received.bits_per_second/1000000' $1)
echo "Average download throughput: $mbps Mbps "

# Extract timestamps and data rate values from JSON and save to a temporary file
jq -r '.intervals[].streams[0] | "\(.start) \(.bits_per_second/1000000)"' $1 > mbps.dat


# Generate gnuplot script to create the plot
cat > plot_datarate.gp <<EOF
set term pdf
set grid
set output "plots/${base}_datarate.pdf"
set xlabel 'Time (seconds)'
set ylabel 'Data rate (Mbit/s)'
set yrange [0:25]
set title 'Data rate evolution over time'
plot 'mbps.dat' using 1:2 pt 7 ps 0.1 with lines
EOF

#cat mbps.dat
# Generate the plot using gnuplot
gnuplot plot_datarate.gp

# Clean up temporary files
rm mbps.dat plot_datarate.gp

echo "Plot created as plots/${base}_datarate.pdf"

