#! /usr/bin/bash

let RECURSIVE=0
let TIMEOUT=48
while getopts 'rt:' OPTION;
do
    case "$OPTION" in

    r)
        let RECURSIVE=1
        #echo "recursive value: $RECURSIVE"
        ;;

    t)
        let TIMEOUT=$OPTARG
        #echo "timeout value: $TIMEOUT"
        ;;
    
    ?)
        #echo "Invalid Flags"
        echo "Usage: freespace [-r] [-t ###] file [file...]"
        exit 1
        ;;

    esac
done
shift "$(($OPTIND -1))"

#echo "what is given $@"
let SING_ARG=$#
#echo "sing arg $SING_ARG"


DEPENDENCY_CHECK(){
    ZIP_EXISTS=$(which zip | grep -c "usr")

    if ! [ $ZIP_EXISTS -eq 1 ]
    then
        sudo apt install zip
    fi
}

FC_NAMEING_CHECK(){
    FILENAME=$(file -i "$1" | cut -f 1 -d ":" | rev | cut -f 1 -d "/" | rev)
    #echo "filename: $FILENAME"

    mypattern="\fc-"

    if [[ $FILENAME =~ $mypattern ]]
    then
        #echo "match"
        #is it old enough to be deleted?
        let AGE_CHECK="$TIMEOUT*60"
        #echo "agecheck: $AGE_CHECK"
        echo "what to check $1"
        FILE_OLD=$(find "$1" -mmin +"$AGE_CHECK" | grep -c "")
        #if test ``
        if [ $FILE_OLD -gt 0 ]
        then
            #echo "old enough"
            rm -f "$1"
        #
        fi

    else
        #echo "no match"
        FILETYPE=$(file -i "$1" | cut -f 2 -d ":" | cut -f 1 -d ";")
        #echo "filetye of no match: $FILETYPE"
        let ZIPPED=$(echo $FILETYPE | grep -c 'application/zip')
        let XCOMPRESSED=$(echo $FILETYPE | grep -c 'application/x-compress')
        let BZIPPED=$(echo $FILETYPE | grep -c 'application/x-bzip2')
        let GZIPPED=$(echo $FILETYPE | grep -c 'application/gzip')
        let ANY_ZIPPED="$ZIPPED+$XCOMPRESSED+$BZIPPED+$GZIPPED"
        #echo "anyzipped: $ANY_ZIPPED"

        #ABSPATH=$(realpath -s "$1")
        #echo "$ABSPATH"
        #NEEDPATH=$(echo "$ABSPATH" | nawk '{match($1, "^.*/"); print substr($1, 1, RLENGTH-1)}')
        NEEDPATH=$(dirname "$1")
        echo "$1"
        echo "fullpsth $NEEDPATH"
        echo "filename: $FILENAME"

        if [ $ANY_ZIPPED -gt 0 ]
        then
            #echo "zipped file"
            mv "$1" "$NEEDPATH/fc-$FILENAME"
            touch "$NEEDPATH/fc-$FILENAME"
        else
            echo "file not ziped $NEEDPATH/fc-$FILENAME.zip"
            zip "$NEEDPATH/fc-$FILENAME.zip" "$1"
            rm -f "$1"
        fi

    fi
}

FILE_DIRECTORY_CHECK(){
    #check to see if its directory
    #CURRENT=pwd
    IS_DIRECTORY=$(file -i "$1" | grep -c "inode/directory")
    let SING_REC_TIG="$SING_ARG + $RECURSIVE"
    
    if [ $IS_DIRECTORY -eq 1 ]
    then
        echo "$1 is a directory"
        IFS=''
        if [ $SING_REC_TIG -gt 0 ]
        then
            #echo "give directory/recursive treatment"
            let SING_ARG=0
            IFS=''
            for j in "$1"/*
            do
                ITERATE_THROUGH_FILES_GIVEN "$j"
            done
            #ITERATE_THROUGH_FILES_GIVEN "$1/"*
        fi
        #echo "recursive $RECURSIVE"

        # if [ $RECURSIVE -eq 1 ]
        # then
        #     #IFS=''
        #     for i in $(find "$1" -type f)
        #     do
        #         echo "echo recursive $i"
        #         FC_NAMEING_CHECK "$i"
        #     done
        # else
        #     #IFS=''
        #     for i in $(find "$1" -maxdepth 1 -type f)
        #     do
        #         echo "no recurvise $1"
        #         FC_NAMEING_CHECK "$i"
        #     done
        # fi
    else
        echo "give file treatment to $1"
        FC_NAMEING_CHECK "$1"
    fi
}


ITERATE_THROUGH_FILES_GIVEN(){

    #echo "i recieved $# items: $@"
    if [ $# -eq 1 ]
    then
        #echo "$1 it is a singular argument"
        FILE_DIRECTORY_CHECK "$1"
    else
        #echo "more than 1 argument"
        IFS=''
        for F_ in "$@"
        do
            ITERATE_THROUGH_FILES_GIVEN "$F_"
        done
    fi
}


DEPENDENCY_CHECK

ITERATE_THROUGH_FILES_GIVEN "$@"

#echo "return value: $?"