#!/bin/bash

#echo hello
for i in {1..100}
do
        if [ $(expr $i % 7) -eq 0 ]
        then
                #echo "7 $i"
                echo 7 >> check.txt
        else
                #echo "$i"
                echo $i >> check.txt
        fi
done
