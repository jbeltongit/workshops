#!/bin/bash

# define variables
pre="<tr><td>"
post="<\/td><\/tr>"
mid="<\/td><td>"

# view contents of file, show only lines containing td tag, remove all instances of variables, align output in columns
cat attacks.html | grep "<td>" | sed -e "s/$pre//g; s/$post//g; s/$mid/ /g" | awk 'BEGIN{printf "%-20s %-10s \n", "Attacks", "Instances(Q3)"}{printf "%-20s %-10s \n", $1, ($2+$3+$4)}'

exit 0