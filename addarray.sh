#!/bin/bash

declare -a ass1
declare -a ass2
ass1=(12 18 20 10 12 16 15 19 8 11) # create first array
ass2=(22 29 30 20 18 24 25 26 29 30) # create second array

for ((i=0; i<10; i++)); do # iterate over each number in array
    echo "Student_$((i+1)) Result:  $(( ${ass1[$i]} + ${ass2[$i]} ))" # add number in first array to corresponding number in second array
done | awk 'BEGIN{FS="  "}{printf "%-20s %-10s \n", $1, $2}' # align output in two columns

exit 0