#!/bin/bash

read -p "File name? " file_name # prompt user for a file to work on
until [ -f $file_name ]; do # keep prompting user for a file if the entered file doesn't exit
    read -p "File does not exist. Enter file name again? " file_name
done

getprop() { # create getprop function

word_count=$(wc -w $file_name | awk '{print $1}') # count words in file and store in variable
file_size=$(du -b $file_name | awk '{printf "%.2f", $1/1024}') # calculate file size and convert to KB, store in variable
last_modified_date=$(date -r $file_name "+%d-%m-%Y %H:%M:%S") # convert last modified date and store in variable

echo "The file $file_name contains $word_count words and is ${file_size}KB in size and was last modified $last_modified_date" # output to the screen

}

getprop # call function

exit 0