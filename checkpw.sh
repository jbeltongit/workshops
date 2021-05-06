#!/bin/bash

awk 'NR>1 { # target all rows except first one
        if ( $2 ~ /\S{8,}/ && $2 ~ /.*[0-9].*/ && $2 ~ /.*[A-Z].*/ ) # check password matches conditions
            { 
                print $2 " - meets password strength requirements" 
            }  
        else
            {
                print $2 " - does NOT meet password strength requirements"
            }
    }' usrpwords.txt # obtain data to work on from this file

exit 0