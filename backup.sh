#!/bin/bash

#to do list

backupDir=/home/nico/backups/ #backups will be saved here
shortendir=/home/nico/ #this string will be removed from filename for every backuped file
filelist=${backupDir}filelist

function backup {
    wholeName=$1
    fileLong=${wholeName#$shortendir}
    dir=${wholeName%/*}/
    dir=${dir#$shortendir}
    if [ ! -d $backupDir$dir ]
    then
        mkdir $backupDir$dir
    fi
    # if [ $wholeName -nt $backupDir$fileLong ] #check if file is newer than backup
    cmp -s $wholeName  $backupDir$fileLong #check if file and backup differ
    diff=$?
    if [ $diff -gt 0 ]
    then
        if [ -e $backupDir$fileLong ]
        then
            date=$(date -r $backupDir$fileLong +%F)
            type=.${fileLong##.}
            if [ $type == .$fileLong ] # handel files without filetype
            then
                type=""
                fileShort=$fileLong
            else
                fileShort=${fileLong%$type}
            fi
            newName=$backupDir$fileShort$date$type
                    mv $backupDir$fileLong $newName
            echo "Moved old file: $backupDir$fileLong to $newName"
        fi
            cp $wholeName $backupDir$fileLong
        echo "Backuped $wholeName to $backupDir$fileLong"
    fi
}
line=1
while read -r currentfile
do
    if [ ! -e $currentfile ]
    then
        echo "The file: $currentfile does not exist, it will be removed from the filelist"
        # delete line $line from file
        sed -i -e "${line}d" $filelist 
        line=$((line-1))
        continue
    fi
    if [ -d $currentfile ] # backup directorys
    then
        filesInDir=$(find $currentfile -type f -name '*' )
        for f in $filesInDir
        do
            backup $f
        done
    elif [ -f $currentfile ] # backup regular files
    then
        backup $currentfile
    fi
    line=$((line+1))
done < $filelist
