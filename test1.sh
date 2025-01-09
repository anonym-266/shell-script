#!/bin/bash

function usage(){
    echo "usage:"
    echo "      $0 /path/to/directory [options]"
    echo "Flags"
    echo " -f, --fix            Delete duplicate files"
    echo " -e, --empty          Delete empty files"
    echo " -h, --help           Help for $0"  
}

function displayDuplicates(){

    echo "|file          |   Duplicate"
    echo "-------------------------------"
    for file in "${!singlefileHarshes[@]}"; do
        for anotherFile in "${!duplicateFileHarshes[@]}"; do
            if [ "$file" = "$anotherFile" ]; then
                # if [ -z "$file" ] || [ -z "$anotherFile" ]; then
                #     continue
                # else
                    echo "|$(basename ${singlefileHarshes["$file"]})        |  yes ($(basename ${duplicateFileHarshes[$anotherFile]})) |"
                    # echo "${duplicateFileHarshes["$file"]}  |   ${singlefileHarshes[$anotherFile]}"
                    # echo "${!singlefileHarshes["$file"]}  |  ${duplicateFileHarshes["$anotherFile"]}"
                # fi
            else
                echo "|$(basename ${singlefileHarshes[$anotherFile]})        |  no"
                # echo "${singlefileHarshes[$anotherFile]}    |   no"
            fi
        done
    done
}
if [ -z "$1" ]; then
    usage
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
elif [ -d "$1" ]; then
    # declaring associative arrays that will store the paths to all files with keys being their file harshes
    declare -A singlefileHarshes
    declare -A duplicateFileHarshes
    echo -e "scanning through directory: $1 \n"
    for file in $(find $1 -type f); do
    # find $1 -type f | while IFS= read -r -d'' file; do
        echo "processing file: $file"
        fileHarsh=$(md5sum "$file" | awk '{print $1}')

        if [[ "${singlefileHarshes[$fileHarsh]}" ]]; then
            echo -e "duplicate file: $file found \n"
            duplicateFileHarshes[$fileHarsh]+="$file"
        else
            echo -e "unique file: $file found \n" 
            singlefileHarshes[$fileHarsh]+=$file
        fi
    done
    echo ${singlefileHarshes[@]}
    echo -e "\n"
    echo ${duplicateFileHarshes[@]}
    displayDuplicates
else
    echo directory: $1 does not exist
fi

# function to delete duplicate files
function deleteDuplicates(){
    for file in "${duplicateFileHarshes[@]}"; do
        echo "deleting file $file"
        if rm $file; then
            echo -e "file $file deleted sucessfully \n"
        else
            echo -e "couldn't delete file: $file \n"
        fi
    done
}

#function to delete empty files
function deleteEmptyFiles(){
for file in $(find $1 -type f); do
    if [ ! -s "$file" ]; then
        if rm $file; then
        echo " empty file: $file deleted succesfully"
        else
            echo "couldn't delete file: $file"
        fi
    fi
done
}

# for the first option entered
if [[ $2 ]]; then
    if [ "$2" = "-f" ] || [ "$2" = "--fix" ]; then
        deleteDuplicates
    elif [ "$2" = "-e" ] || [ "$2" = "--empty" ]; then
        deleteEmptyFiles
    else
        usage
    fi
fi
