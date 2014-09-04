#!/bin/bash 

function usage()
{

        echo "Usage $(basename $(which $0)) <file.rrd> <DS1> <DS2>....<DSn>"
        echo "$(basename $(which $0)) <file.rrd> - will scan for all available DSs"
        exit 2
}

if [ ! $1 ]
then
        usage
else
        if [ ! -r "$1" ]
        then
                echo "$1 is not readable. Bailing out!"
                exit 2
        fi
fi

type rrdtool >/dev/null 2>&1 || { echo "rrdtool not available?"; exit 2; }
type gnuplot >/dev/null 2>&1 || { echo "gnuplot not available?"; exit 2; }

file=$1

rrd_data=$(rrdtool fetch $file AVERAGE | tail -n +3 | grep -v 'nan' | sed 's/^/"/g;s/:/"/g')

shift 

if [ $# -gt 0 ]
then
        while [[ $# > 0 ]]
        do
                echo "$rrd_data" | gnuplot -e "set terminal dumb 100 25; plot '< cat -' using $(($1+1)) notitle with lines" 2> /dev/null
                sleep 1
                shift
        done
else
        DS_no=$(echo "$rrd_data" | head -n 1 | awk '{print NF}')
        for i in $(seq 1 $DS_no)
        do
                echo "$rrd_data" | gnuplot -e "set terminal dumb 100 25; plot '< cat -' using $i notitle with lines" 2> /dev/null
                sleep 1
        done
fi
