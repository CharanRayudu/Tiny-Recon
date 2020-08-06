#!/bin/bash

if [ -z "$1" ]
then
        echo "Usage: ./basicrecon.sh <example.com>"
        exit 1
fi

printf "\n----- NMAP -----\n\n" > results

echo "Running Nmap..."
nmap $1 | tail -n +5 | head -n -3 >> results

while read line
do
        if [[ $line == *open* ]] && [[ $line == *http* ]]
        then
                echo "Running Gobuster..."
                gobuster dir -u $1 -w /usr/share/wordlists/dirb/common.txt -qz > temp1

        echo "Running WhatWeb..."
        whatweb $1 -v > temp2
        fi
done < results

if [ -e temp1 ]
then
        printf "\n----- DIRS -----\n\n" >> results
        cat temp1 >> results
        rm temp1
fi

if [ -e temp2 ]
then
    printf "\n----- WEB -----\n\n" >> results
        cat temp2 >> results
        rm temp2
fi

printf "\n----- Getting Subdomains -----\n\n"  >> results

curl -s https://crt.sh/\?q\=\%.$1\&output\=json | grep name_value | tr , '\n' | grep name_value | sed 's/name_value//g' | sed "s/\"//g" | sed 's/://g' | sed 's/\n/,/' | sed 's/\\n/,/g' | tr , '\n' | sed 's/*//g' | sed 's/^\.//g' | sort -u >> results

cat results
