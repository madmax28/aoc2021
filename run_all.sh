#!/bin/bash
for day in $(seq 1 24); do
    file=$(printf "day%02i.lua" $day)
    if [ -f "$file" ]; then
        echo "=== Day $day ==="
        lua $file
    fi
done
