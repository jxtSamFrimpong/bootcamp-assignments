#! /usr/bin/bash

#IFS=''
for i in $(find "somefolder" -type f)
do
    echo "$i"
done