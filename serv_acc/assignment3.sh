# Student name: Joel Belton (10523443)

#!/bin/bash

declare -a array=() # create an empty array that will store output of case statement later on in the program

echo -e "\nWelcome to the server access log analysis tool, Vince!\n"

while [[ $REPLY != [Qq] ]]; do # declare while loop that will only end when user inputs Q/q
    read -p "Would you like to search all server access logs in current directory (a), or only search one (b)? " server
    until [[ $server == [a,b] ]]; do
        read -p "$(echo -e "\nInvalid input. Please enter your choice again (a or b): ")" server # note that the echo inside of read allows for escape character n, newline
    done

    if [ $server == a ]; then 
        sel_log=serv_acc_log_* # if user chooses option a, store all things starting with 'serv_acc_log_' in variable             
    elif [ $server == b ]; then 
        read -p "Enter name of access log: " access_log # otherwise, prompt user to type name of specific access log
        until [[ -f $access_log && "$access_log" =~ ^serv_acc_log_ ]]; do # declare until loop that only ends when an existing access log is entered    
            read -p "$(echo -e "\nInvalid access log. Please enter name of access log again: ")" access_log         
        done
        sel_log=$access_log # store specific access log in variable instead
    fi

    read -p "How many fields would you like to filter by (1, 2 or 3)? " field
    until [[ $field == [1-3] ]]; do # declare until loop that only ends when the number 1, 2 or 3 is entered
        read -p "$(echo -e "\nInvalid input. Please enter 1, 2 or 3: ")" field
    done
    echo -e "\nChoose from the following fields:\n1) PROTOCOL\n2) SRC IP\n3) SRC PORT\n4) DEST IP\n5) DEST PORT\n6) PACKETS\n7) BYTES"
    
    for ((i=1;i<=$field;i++)); do # loop for however many fields the user chooses, i.e. 1,2 or 3 times            
        read -p "$(echo -e "\nEnter field number $i: ")" field_num # prompt user to enter a field by choosing from the field options above      
        while ! [[ $field_num =~ ^[1-7]$ ]]; do # declare while loop that will repeat if the user enters something other than 1-7
            read -p "$(echo -e "\nInvalid field - please enter a number between 1 and 7\n\nEnter field number $i: ")" field_num
        done

        case $field_num in
            1) read -p "What would you like to filter the PROTOCOL field by? " protocol; # store the user's search pattern in variable
            protocol=$(echo "$protocol" | tr a-z A-Z); # convert user input within the variable to uppercase
            array+=("awk '{FS=\",\"} \$3 ~ /^$protocol\\s*$/'");; # have an awk command, that searches the specified column for rows containing that exact input (whitespaces have been accounted for), as a string and append to the array we created
            2) read -p "What would you like to filter the SRC IP field by? " src_ip;
            src_ip=$(echo "$src_ip" | tr a-z A-Z); # convert user input to uppercase
            array+=("awk '{FS=\",\"} \$4 ~ /$src_ip/'");; # have an awk command, that searches the specified column for rows containing that input, as a string and append to the array
            3) read -p "What would you like to filter the SRC PORT field by? " src_port;
            array+=("awk -v sp=$src_port '{FS=\",\"} \$5 == sp'");; # have an awk command, that searches the specified column for rows containing that exact input, as a string and append to the array
            4) read -p "What would you like to filter the DEST IP field by? " dest_ip;
            dest_ip=$(echo "$dest_ip" | tr a-z A-Z); # convert user input to uppercase
            array+=("awk '{FS=\",\"} \$6 ~ /$dest_ip/'");; # have an awk command, that searches the specified column for rows containing that input, as a string and append to the array
            5) read -p "What would you like to filter the DEST PORT field by? " dest_port;
            array+=("awk -v dp=$dest_port '{FS=\",\"} \$7 == dp'");; # have an awk command, that searches the specified column for rows containing that exact input, as a string and append to the array
            6) echo -e "\nWhat is the packet range you are searching for?";
            read -p "Please enter a less than (<), greater than (>), equal to (==), or not equal to (!=) symbol followed by a value [e.g. ==100]: " packet_range;                
            until [[ $packet_range =~ ^[\<,\>,=,!]={0,1}[0-9]+$ ]]; do # declare until loop that only ends when user has entered correct symbol and value with no space between (note that the regex also allows for <= and >=)
                read -p "Invalid packet range. Please enter a less than (<), greater than (>), equal to (==), or not equal to (!=) symbol followed by a value [e.g. ==100]: " packet_range
            done;
            array+=("awk '{FS=\",\"} \$8$packet_range'");; # have an awk command, that filters the specified column rows by the number range that was input, as a string and append to the array
            7) echo -e "\nWhat is the byte range you are searching for?";
            read -p "Please enter a less than (<), greater than (>), equal to (==), or not equal to (!=) symbol followed by a value [e.g. ==100]: " byte_range;
            until [[ $byte_range =~ ^[\<,\>,=,!]={0,1}[0-9]+$ ]]; do # declare until loop that only ends when user has entered correct symbol and value with no space between (note that the regex also allows for <= and >=)
                read -p "Invalid byte range. Please enter a less than (<), greater than (>), equal to (==), or not equal to (!=) symbol followed by a value [e.g. ==100]: " byte_range
            done;
            array+=("awk '{FS=\",\"} \$9$byte_range'");; # have an awk command, that filters the specified column rows by the number range that was input, as a string and append to the array
        esac

    done

    # create variable to store the output    
    search_results=$(cat $sel_log | # view the contents of access log(s) based on previous user input
    grep -v "normal\|PROTOCOL" | # show all lines except those with header information and where class is normal
    eval $(IFS="|"; echo "${array[*]}") | # separate array values by '|' rather than space and evaluate array values as commands piped together
    awk -v pr=$packet_range -v br=$byte_range 'BEGIN {FS=","; printf "%-20s%-20s%-20s%-20s%-20s%-20s%-20s\n\n", "PROTOCOL", "SRC IP", "SRC PORT", "DEST IP", "DEST PORT", "PACKETS", "BYTES"} # display header above output aligned in columns
    {for(i=3;i<=9;i++){printf "%-20s", $i}; printf "\n"}{packet_total+=$8; byte_total+=$9} # only show fields 3-9 in the output, align these in columns, and add each row for the last two fields and store in variable
    END {if(pr != ""){print "\nTotal packets: "packet_total}if(br != ""){print "\nTotal bytes: "byte_total}}') # if user had chosen one or both of the last 2 fields, display a total below the output using the above variable
    count_results=$(grep -c "TCP\|UDP\|ICMP" <<< "$search_results") # do a line count on the previous output, don't include lines that are BEGIN/END awk statements

    if [ $count_results == 0 ]; then 
        read -p "$(echo -e "\nNo results were found.\n\nEnter the letter 'q' if you would like to exit the program, otherwise enter any other key to make another search: ")"
        continue # if there were no lines in the previous output, skip the rest of the code (saving results in a directory/file) and loop back to start
    else
        read -p "$(echo -e "\nWhat directory do you want to save these in? ")" directory        
        while [[ $directory == "" ]]; do # declare while loop that keeps repeating if user doesn't enter anything
            read -p "$(echo -e "\nDirectory name cannot be empty. Please enter it again: ")" directory
        done
        
        if [ ! -d $directory ]; then
            mkdir $directory # if directory doesn't exist, create it
        fi
        
        cd $directory # move from pwd to this directory
        read -p "What name would you like to save the search results as? " file
        while [[ $file == "" ]]; do # declare while loop that keeps repeating if user doesn't enter anything
            read -p "$(echo -e "\nFile name cannot be empty. Please enter it again: ")" file
        done

        if [ -f $file.txt ]; then
            echo "$search_results" >> $file.txt # if file already exists, append the results to it
        else
            echo "$search_results" > $file.txt # otherwise, save the results in the new file
        fi
        
        cd $OLDPWD # go back to previous directory containing server access logs for next search
        echo -e "\nSearch results have been saved in a file called '$file' within the $directory directory.\n"
        read -p "Enter the letter 'q' if you would like to exit the program, otherwise enter any other key to make another search: "
    fi

done
  
exit 0