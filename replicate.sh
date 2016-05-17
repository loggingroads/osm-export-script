#!/bin/bash

# arguments are a list of country iso3 codes
# useful in e.g. a crontab which asks to process several countries

#The replication files are organized according to the url scheme:
#http://planet.openstreetmap.org/replication/[day|hour|minute]/AAA/BBB/CCC.osc.gz
#The AAA/BBB/CCC are equivalent to a sequence number, AAA*1000000 + BBB*1000 + CCC
#The latest osm update file is stored with this sequence number in the filename

#The current country file is stored with the most recent sequence number in the filename
#This script just adds one to the sequence number and applies the relevant update file

#TODO - what happens if file doesn't exist
#TODO - how many updates to keep
#TODO - Convert to o5m should already be done, with only highways
#e.g: 
#osmconvert pbf/"$var".pbf -o="$var".o5m
#osmfilter "$var".o5m --keep="highway=*" --out-o5m > $highway_file


for var in "$@"
do
    echo "processing ""$var"

    unset -v latest
    unset -v prefix
    prefix=current/"$var"_

    # find the most recently updated country o5m file for country
    for file in "$prefix"*; do
        [[ $file -nt $latest ]] && latest=$file
    done

    echo $latest

    current_highway_file=$latest

    # get the seq number
    current_seq_str=${latest#$prefix}
    current_seq_no=${current_seq_str%".o5m"}
    echo "current: " $current_seq_no
    next_seq_no=$((10#$current_seq_no + 1))
    echo "next: " $next_seq_no
    lpad_seq=$(printf "%0*d" 9 $next_seq_no)


    temp_updated_file=/tmp/"$var"_updated.o5m
    updated_highway_file=current/"$var"_"$lpad_seq".o5m
    polygon_file=poly/ne_"$var".poly


    # Apply a changefile 
    osmconvert "$current_highway_file" minute_replication/"$lpad_seq".osc.gz -B=$polygon_file -o=$temp_updated_file
    osmfilter $temp_updated_file --keep="highway=*" --out-o5m > $updated_highway_file 

done
