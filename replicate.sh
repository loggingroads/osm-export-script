#!/bin/bash

# TODO pull in csv list of countries (from e.g. crontab)

# Convert to o5m
osmconvert pbf/COD.pbf -o=cod.o5m

# Filter to highways
osmfilter cod.o5m --keep="highway=*" --out-o5m > codh.o5m



# Loop
# Apply a changefile 
osmconvert codh.o5m test_updates/*.osc.gz -B=poly/ne_COD.poly -o=codn.o5m

# figure out filenames
osmfilter cod.o5m --keep="highway=*" --out-o5m > codh.o5m

