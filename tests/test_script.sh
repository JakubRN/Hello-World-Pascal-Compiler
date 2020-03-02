#!/bin/bash

cd .. && make && cd tests
mkdir -p out_mine
mkdir -p out_gwj
# rm differences.txt > /dev/null 2>&1
# touch differences.txt
for i in *.pas; do
    output_filename="${i%.*}.asm"
    echo $i
    ../komp $i "out_mine/$output_filename" > /dev/null 2>&1
    ./komp $i "out_gwj/$output_filename" > /dev/null 2>&1
    # diff -s -y -a -w --color "out_mine/$output_filename" "out_gwj/$output_filename" > differences.txt
done

